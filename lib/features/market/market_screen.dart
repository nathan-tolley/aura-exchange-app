import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/freshness.dart';
import '../../data/live_market.dart';
import '../../data/me.dart';
import '../../design/widgets/aura_tab_bar.dart';
import '../../format/time.dart';
import '../../router.dart';
import '../system/load_failure.dart';
import 'market_model.dart';
import 'market_view.dart';

/// The Market tab, live: every listing by today's change, searchable by
/// name or ticker on the phone (the list is the whole exchange, so there's
/// nothing to ask the server).
class MarketScreen extends ConsumerStatefulWidget {
  const MarketScreen({super.key});

  @override
  ConsumerState<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends ConsumerState<MarketScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void onTab(AuraTab tab) => goTab(context, tab);
    final exchangeId = ref.watch(currentExchangeIdProvider);
    if (exchangeId == null) return MarketView(model: null, onTab: onTab);
    final market = ref.watch(marketProvider(exchangeId));
    final exchange = ref.watch(exchangeProvider(exchangeId));
    final m = market.value;
    final e = exchange.value;
    if (m == null || e == null) {
      final failure = firstFailure([market, exchange]);
      if (failure != null) {
        return LoadFailureView(
          error: failure,
          onRetry: () {
            ref.invalidate(marketProvider(exchangeId));
            ref.invalidate(exchangeProvider(exchangeId));
          },
        );
      }
      return MarketView(model: null, onTab: onTab);
    }
    return MarketView(
      model: marketListModel(
        market: m,
        liveness:
            ref.watch(marketLivenessProvider(exchangeId)) ?? Liveness.live,
        query: _search.text,
        zone: exchangeZone(e.timezone),
        now: ref.watch(clockProvider),
      ),
      search: _search,
      onSearch: (_) => setState(() {}),
      onRetry: () => ref.read(marketProvider(exchangeId).notifier).refresh(),
      onRow: (id) => context.push(Routes.stock(id)),
      onTab: onTab,
    );
  }
}
