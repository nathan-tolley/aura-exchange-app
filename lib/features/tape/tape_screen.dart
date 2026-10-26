import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../api/client.dart';
import '../../api/errors.dart';
import '../../data/freshness.dart';
import '../../data/inbox_data.dart';
import '../../data/live_market.dart';
import '../../data/me.dart';
import '../../data/repositories.dart';
import '../../design/widgets/aura_tab_bar.dart';
import '../../format/ticker.dart';
import '../../format/time.dart';
import '../../l10n/strings.dart';
import '../../router.dart';
import '../events/file_sheet.dart';
import '../system/load_failure.dart';
import 'tape_view.dart';

/// The Tape tab, live: the first page with the stream's items on top, the
/// filter, older pages on request, and what's new since you last looked.
class TapeScreen extends ConsumerStatefulWidget {
  const TapeScreen({super.key});

  @override
  ConsumerState<TapeScreen> createState() => _TapeScreenState();
}

class _TapeScreenState extends ConsumerState<TapeScreen> {
  String _filter = tapeFilterAll;

  /// When you looked before this visit: newer items are dotted.
  DateTime? _seenBefore;

  @override
  void initState() {
    super.initState();
    _seenBefore = ref.read(tapeSeenProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(tapeSeenProvider.notifier).seen(ref.read(clockProvider));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    void onTab(AuraTab tab) => goTab(context, tab);
    final exchangeId = ref.watch(currentExchangeIdProvider);
    if (exchangeId == null) {
      return TapeView(rows: null, filter: _filter, onTab: onTab);
    }
    final key = (exchangeId, tapeFilters[_filter]);
    final tape = ref.watch(tapeProvider(key));
    final items = tape.value;
    if (items == null) {
      final failure = firstFailure([tape]);
      if (failure != null) {
        return LoadFailureView(
          error: failure,
          onRetry: () => ref.invalidate(tapeProvider(key)),
        );
      }
    }
    final zone = exchangeZone(
      ref.watch(exchangeProvider(exchangeId)).value?.timezone ?? 'UTC',
    );
    return TapeView(
      rows: items == null
          ? null
          : tapeRows(
              items,
              seen: _seenBefore,
              zone: zone,
              now: ref.watch(clockProvider),
            ),
      filter: _filter,
      hasMore: ref.read(tapeProvider(key).notifier).hasMore,
      onFilter: (f) => setState(() => _filter = f),
      onRow: (r) => context.push(r.link!),
      onMore: () => ref.read(tapeProvider(key).notifier).loadMore(),
      onFile: () => openFiling(context),
      onTab: onTab,
    );
  }
}

/// The route inside the app for a notification's `aura://` link.
String routeFor(String deepLink) {
  final uri = Uri.tryParse(deepLink);
  if (uri == null || uri.scheme != 'aura') return deepLink;
  return Uri(
    path: '/${uri.host}${uri.path}',
    query: uri.query.isEmpty ? null : uri.query,
  ).toString();
}

/// The notifications inbox (`/notifications`), live. Opening it marks
/// everything read up to the newest.
class InboxScreen extends ConsumerStatefulWidget {
  const InboxScreen({super.key});

  @override
  ConsumerState<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends ConsumerState<InboxScreen> {
  bool _marked = false;

  Future<void> _markRead(String exchangeId, DateTime upTo) async {
    _marked = true;
    try {
      await ref.read(meRepositoryProvider).markRead(upTo, IdempotencyKey());
    } on ApiError {
      // Unread dots stay until the next visit; nothing else depends on it.
    }
  }

  @override
  Widget build(BuildContext context) {
    final exchangeId = ref.watch(currentExchangeIdProvider);
    void back() => context.canPop() ? context.pop() : context.go(Routes.home);
    if (exchangeId == null) return InboxView(model: null, onBack: back);
    final inbox = ref.watch(notificationsProvider(exchangeId));
    final items = inbox.value;
    if (items == null) {
      final failure = firstFailure([inbox]);
      if (failure != null) {
        return LoadFailureView(
          error: failure,
          onRetry: () => ref.invalidate(notificationsProvider(exchangeId)),
        );
      }
      return InboxView(model: null, onBack: back);
    }
    if (!_marked && items.isNotEmpty) {
      Future.microtask(() => _markRead(exchangeId, items.first.at));
    }
    final market = ref.watch(marketProvider(exchangeId)).value;
    final zone = exchangeZone(
      ref.watch(exchangeProvider(exchangeId)).value?.timezone ?? 'UTC',
    );
    return InboxView(
      model: inboxModel(
        items,
        tickers: {
          for (final l in market?.listings ?? const <LiveListing>[])
            l.id: formatTicker(l.summary.ticker),
        },
        quiet: ref.watch(notificationPrefsProvider).value?.quietHours,
        zone: zone,
        now: ref.watch(clockProvider),
      ),
      onBack: back,
      onRow: (r) {
        final link = r.link;
        if (link != null) context.push(routeFor(link));
      },
    );
  }
}
