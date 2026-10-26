import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../api/client.dart';
import '../../api/errors.dart';

import '../../api/generated/export.dart' hide Freshness;
import '../../data/freshness.dart';
import '../../data/listing_data.dart';
import '../../data/live_market.dart';
import '../../data/repositories.dart';
import '../../data/me.dart';
import '../../design/tokens.dart';
import '../../design/widgets/aura_skeleton.dart';
import '../../format/time.dart';
import '../../router.dart';
import '../events/file_sheet.dart';
import '../shared/top_bar.dart';
import '../system/load_failure.dart';
import '../trade/trade_screen.dart';
import 'halted_model.dart';
import 'halted_view.dart';
import 'stock_model.dart';
import 'stock_view.dart';

/// A stock page (`/stock/:id`), live: the listing's stats and events, its
/// price from the exchange's ticks, the chart for the chosen range. While
/// the listing is halted for a news vote, it's W10.
class StockScreen extends ConsumerStatefulWidget {
  const StockScreen({super.key, required this.listingId});

  final String listingId;

  @override
  ConsumerState<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends ConsumerState<StockScreen> {
  String _range = '1D';
  StockTab _tab = StockTab.overview;
  String? _toast;
  Timer? _toastTimer;

  @override
  void dispose() {
    _toastTimer?.cancel();
    super.dispose();
  }

  /// Opens the trade sheet; after a fill or an order, says so for 4 s.
  Future<void> _trade(StockAction action) async {
    final result = await context.push<Object?>(
      Routes.trade(widget.listingId, action.side),
    );
    final message = tradeToast(result);
    if (message == null || !mounted) return;
    _toastTimer?.cancel();
    setState(() => _toast = message);
    _toastTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _toast = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final id = widget.listingId;
    final exchangeId = ref.watch(currentExchangeIdProvider);
    final detail = ref.watch(listingProvider(id));
    final d = detail.value;
    void back() => context.canPop() ? context.pop() : context.go(Routes.home);
    if (d == null) {
      final failure = firstFailure([detail]);
      if (failure != null) {
        return LoadFailureView(
          error: failure,
          onRetry: () => ref.invalidate(listingProvider(id)),
        );
      }
      return _StockLoading(onBack: back);
    }

    final market = exchangeId == null
        ? null
        : ref.watch(marketProvider(exchangeId)).value;
    final live = market?.listings.where((l) => l.id == id).firstOrNull;
    final freshness =
        market?.freshness ??
        Freshness(
          asOf: d.asOf,
          marketState: d.marketState,
          nextChangeAt: d.nextChangeAt,
        );
    final zone = exchangeZone(
      exchangeId == null
          ? 'UTC'
          : ref.watch(exchangeProvider(exchangeId)).value?.timezone ?? 'UTC',
    );
    final now = ref.watch(clockProvider);

    final halt = d.halt;
    final haltEvent = halt == null
        ? null
        : d.events.where((e) => e.id == halt.eventId).firstOrNull;
    if (halt != null && halt.status == HaltStatus.voting && haltEvent != null) {
      return HaltedStockView(
        model: haltedStockModel(
          listing: d,
          event: haltEvent,
          zone: zone,
          now: now,
        ),
        onBack: back,
        onVote: (choice) async {
          try {
            await ref
                .read(eventsRepositoryProvider)
                .haltVote(halt.id, Choice.fromJson(choice), IdempotencyKey());
          } on ApiError {
            // The refetch shows where the vote stands.
          }
          ref.invalidate(listingProvider(id));
        },
      );
    }

    final candles = ref.watch(candlesProvider((id, chartRangeFor[_range]!)));
    final tape = _tab == StockTab.tape && exchangeId != null
        ? ref.watch(listingTapeProvider((exchangeId, id))).value
        : null;
    final offline = stockOffline(market);
    final model = stockPageModel(
      detail: d,
      live: live,
      freshness: freshness,
      liveness: exchangeId == null
          ? Liveness.live
          : ref.watch(marketLivenessProvider(exchangeId)) ?? Liveness.live,
      offline: offline,
      candles: candles.value,
      range: _range,
      tab: _tab,
      tape: tape,
      zone: zone,
      now: now,
    );
    return StockPageView(
      model: model,
      onBack: back,
      onBannerAction: () {
        final event = model.bannerEventId;
        if (event != null) {
          context.push(Routes.event(event));
        } else if (exchangeId != null) {
          ref.read(marketProvider(exchangeId).notifier).refresh();
          ref.invalidate(listingProvider(id));
        }
      },
      onRange: (r) => setState(() => _range = r),
      onTab: (t) => setState(() => _tab = t),
      onEvent: (e) => context.push(Routes.event(e)),
      onFile: () => openFiling(context, subjectId: id),
      onTrade: offline ? null : _trade,
      toast: _toast,
    );
  }
}

/// The stock page while it loads: the top row is real (you can go back),
/// the rest is skeletons at the header's and chart's sizes.
class _StockLoading extends StatelessWidget {
  const _StockLoading({this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return ColoredBox(
      color: AuraColors.bg,
      child: ListView(
        padding: EdgeInsets.only(top: top),
        children: [
          TopBar(onPressed: onBack),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AuraSkeleton(width: 140, height: 10),
                SizedBox(height: 14),
                AuraSkeleton(width: 210, height: 34),
                SizedBox(height: 14),
                AuraSkeleton(width: 150, height: 10),
                SizedBox(height: 36),
                AuraSkeleton(height: 180),
                SizedBox(height: 12),
                AuraSkeleton(height: 32, radius: AuraRadius.full),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
