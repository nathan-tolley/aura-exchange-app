import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../api/client.dart';
import '../../api/errors.dart';
import '../../api/generated/export.dart' hide Freshness;
import '../../api/stream.dart';
import '../../data/freshness.dart';
import '../../data/lifecycle.dart';
import '../../data/listing_data.dart';
import '../../data/live_market.dart';
import '../../data/me.dart';
import '../../data/repositories.dart';
import '../../design/icons.dart';
import '../../design/tokens.dart';
import '../../design/widgets/aura_skeleton.dart';
import '../../format/time.dart';
import '../../router.dart';
import '../shared/top_bar.dart';
import '../system/load_failure.dart';
import '../stock/stock_screen.dart';
import 'about_you_models.dart';
import 'about_you_views.dart';
import 'filing_status.dart';

/// One event (`GET /events/{id}`), refetched on resume and whenever the
/// stream says its status changed (SENDING → RUMOR → RULED).
final eventProvider = FutureProvider.autoDispose.family<Event, String>((
  ref,
  eventId,
) {
  ref.watch(refetchSignalProvider);
  final changes = ref.watch(auraStreamProvider).messages.listen((m) {
    if (m is StatusMessage && m.resource == 'event' && m.id == eventId) {
      ref.invalidateSelf();
    }
  });
  ref.onDispose(() => unawaited(changes.cancel()));
  return ref.read(eventsRepositoryProvider).event(eventId);
});

/// An event (`/events/:id`): your filing's status when you filed it (and
/// the unsend window while it's sending).
class EventScreen extends ConsumerStatefulWidget {
  const EventScreen({super.key, required this.eventId});

  final String eventId;

  @override
  ConsumerState<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends ConsumerState<EventScreen> {
  ApiError? _unsendProblem;

  Future<void> _unsend() async {
    try {
      await ref
          .read(eventsRepositoryProvider)
          .unsend(widget.eventId, IdempotencyKey());
      ref.invalidate(eventProvider(widget.eventId));
    } on ApiError catch (e) {
      if (mounted) setState(() => _unsendProblem = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final event = ref.watch(eventProvider(widget.eventId));
    void close() => context.canPop() ? context.pop() : context.go(Routes.home);
    final e = event.value;
    if (e == null) {
      final failure = firstFailure([event]);
      if (failure != null) {
        return LoadFailureView(
          error: failure,
          onRetry: () => ref.invalidate(eventProvider(widget.eventId)),
        );
      }
      return _EventLoading(onClose: close);
    }
    final exchangeId = ref.watch(currentExchangeIdProvider);
    final zone = exchangeZone(
      exchangeId == null
          ? 'UTC'
          : ref.watch(exchangeProvider(exchangeId)).value?.timezone ?? 'UTC',
    );
    final now = ref.watch(clockProvider);
    // The window's end refetches it, so SENDING turns into RUMOR on time.
    final until = e.unsendUntil;
    if (e.status == EventStatus.sending &&
        until != null &&
        !now.isBefore(until)) {
      Future.microtask(() => ref.invalidate(eventProvider(widget.eventId)));
    }
    if (e.isMine) {
      return FilingStatusView(
        model: filingStatusModel(e, zone: zone, now: now),
        onClose: close,
        onUndo: _unsendProblem == null ? _unsend : null,
      );
    }
    // Halted for a vote: the stock page is where the vote is (W10).
    if (e.status == EventStatus.halted) {
      return StockScreen(listingId: e.subject.id);
    }
    final market = exchangeId == null
        ? null
        : ref.watch(marketProvider(exchangeId)).value;
    final listing = ref.watch(listingProvider(e.subject.id)).value;
    final freshness =
        market?.freshness ??
        (listing == null
            ? Freshness(asOf: now, marketState: MarketState.closed)
            : Freshness(
                asOf: listing.asOf,
                marketState: listing.marketState,
                nextChangeAt: listing.nextChangeAt,
              ));
    final events = ref.read(eventsRepositoryProvider);
    Future<void> act(Future<Object?> Function(IdempotencyKey key) call) async {
      try {
        await call(IdempotencyKey());
      } on ApiError {
        // The refetch below shows where it stands; a failed tap leaves it.
      }
      ref.invalidate(eventProvider(widget.eventId));
    }

    if (e.status == EventStatus.rumor) {
      if (e.isAboutMe) {
        return RumorAboutYouView(
          model: rumorAboutYouModel(
            event: e,
            market: freshness,
            zone: zone,
            now: now,
          ),
          onClose: close,
          onRespond: (i) => switch (i) {
            0 => act((k) => events.statement(e.id, Kind2.noComment, k)),
            1 => act((k) => events.statement(e.id, Kind2.deny, k)),
            _ => close(),
          },
        );
      }
      return RumorView(
        model: rumorModel(event: e, market: freshness, zone: zone, now: now),
        onClose: close,
        onReact: (kind) => act((k) => events.react(e.id, kind, k)),
      );
    }
    if (e.isAboutMe && e.ruling != null && listing != null) {
      final membership = ref.watch(currentMembershipProvider);
      return RulingOnYouView(
        model: rulingOnYouModel(
          event: e,
          listing: listing,
          market: freshness,
          superInjunctionsLeft: membership?.superInjunctionsLeft ?? 0,
          superInjunctionsPerSeason: membership?.superInjunctionsPerSeason,
          zone: zone,
          now: now,
        ),
        onClose: close,
      );
    }
    return RulingView(
      model: rulingModel(
        event: e,
        market: freshness,
        holdsStock: listing?.myPosition != null,
        zone: zone,
        now: now,
      ),
      onClose: close,
      onVote: (i) => act(
        (k) => events.vote(e.id, i == 0 ? Direction.up : Direction.down, k),
      ),
    );
  }
}

class _EventLoading extends StatelessWidget {
  const _EventLoading({this.onClose});

  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AuraColors.bg,
      child: ListView(
        padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
        children: [
          TopBar(icon: AuraIcons.close, label: 'Close', onPressed: onClose),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 14,
              children: [
                AuraSkeleton(width: 220, height: 14),
                AuraSkeleton(height: 10),
                AuraSkeleton(width: 260, height: 10),
                SizedBox(height: 16),
                AuraSkeleton(height: 120),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
