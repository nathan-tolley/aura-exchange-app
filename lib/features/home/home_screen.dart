import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/exchange_data.dart';
import '../../data/freshness.dart';
import '../../data/live_market.dart';
import '../../data/me.dart';
import '../../design/widgets/aura_tab_bar.dart';
import '../../format/time.dart';
import '../../router.dart';
import '../events/file_sheet.dart';
import '../system/load_failure.dart';
import 'home_loading_view.dart';
import 'home_model.dart';
import 'home_view.dart';

/// Home (SCREENS.md #5), live: the market with ticks on top, your portfolio
/// as the server values it, and the exchange (its clock, season, and how
/// many are listed). Loading shows skeletons; a first load that fails shows
/// the exchange-down screen (W13) or the problem screen; a refetch that
/// fails keeps the numbers and stamps them (W11).
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _hidden = false;

  @override
  Widget build(BuildContext context) {
    final exchangeId = ref.watch(currentExchangeIdProvider);
    void onTab(AuraTab tab) => goTab(context, tab);
    void onBell() => context.push(Routes.notifications);
    if (exchangeId == null) {
      return HomeLoadingView(onBell: onBell, onTab: onTab);
    }
    final market = ref.watch(marketProvider(exchangeId));
    final portfolio = ref.watch(portfolioProvider(exchangeId));
    final exchange = ref.watch(exchangeProvider(exchangeId));

    void retry() {
      ref.invalidate(marketProvider(exchangeId));
      ref.invalidate(portfolioProvider(exchangeId));
      ref.invalidate(exchangeProvider(exchangeId));
    }

    final m = market.value;
    final p = portfolio.value;
    final e = exchange.value;
    if (m == null || p == null || e == null) {
      final failure = firstFailure([market, portfolio, exchange]);
      if (failure != null) {
        return LoadFailureView(error: failure, onRetry: retry);
      }
      return HomeLoadingView(onBell: onBell, onTab: onTab);
    }

    final now = ref.watch(clockProvider);
    final zone = exchangeZone(e.timezone);
    final ipoDay = e.listedCount < e.minListingsToOpen;
    final teaser = ipoDay
        ? ref.watch(latestTapeProvider(exchangeId)).value?.headline
        : null;
    final model = homeViewModel(
      market: m,
      portfolio: p,
      liveness: ref.watch(marketLivenessProvider(exchangeId)) ?? Liveness.live,
      watchlist: defaultWatchlist(m),
      season: e.season.number,
      zone: zone,
      now: now,
      ipo: ipoDay
          ? homeIpoInput(
              market: m,
              listed: e.listedCount,
              minListings: e.minListingsToOpen,
              teaser: teaser,
            )
          : null,
    );
    final ipoRows = model.ipo?.rows.length ?? 0;
    return HomeView(
      model: model,
      hidden: _hidden,
      onBell: onBell,
      onToggleHidden: () => setState(() => _hidden = !_hidden),
      onFile: () => openFiling(context),
      onTrade: () => goTab(context, AuraTab.market),
      onRetry: () => ref.read(marketProvider(exchangeId).notifier).refresh(),
      onRow: (id) => context.push(Routes.stock(id)),
      onIpoRow: (i) {
        if (i == ipoRows - 1) context.push(Routes.createInvite);
      },
      onTab: onTab,
    );
  }
}
