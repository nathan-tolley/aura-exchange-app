import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../api/client.dart';
import '../../api/errors.dart';
import '../../api/generated/export.dart' hide Freshness;
import '../../data/exchange_data.dart';
import '../../data/lifecycle.dart';
import '../../data/listing_data.dart';
import '../../data/me.dart';
import '../../format/time.dart';
import '../../data/repositories.dart';
import '../../design/sheet_route.dart';
import '../../design/widgets/aura_tab_bar.dart';
import '../../router.dart';
import '../stock/short_model.dart';
import '../stock/short_view.dart';
import '../stock/stock_screen.dart';
import '../system/load_failure.dart';
import 'liquidated_model.dart';
import 'liquidated_view.dart';
import 'portfolio_view.dart';

/// The Portfolio tab, live from `GET /portfolio` (refetched as prices move).
class PortfolioScreen extends ConsumerStatefulWidget {
  const PortfolioScreen({super.key});

  @override
  ConsumerState<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends ConsumerState<PortfolioScreen> {
  bool _hidden = false;

  void _cancel(String exchangeId, OrderRow order) {
    Navigator.of(context).push(
      AuraSheetRoute<void>(
        builder: (sheet) => _CancelSheet(
          order: order,
          onDone: () {
            ref.invalidate(portfolioProvider(exchangeId));
            Navigator.of(sheet).pop();
          },
          onKeep: () => Navigator.of(sheet).pop(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    void onTab(AuraTab tab) => goTab(context, tab);
    final exchangeId = ref.watch(currentExchangeIdProvider);
    if (exchangeId == null) return PortfolioView(model: null, onTab: onTab);
    final portfolio = ref.watch(portfolioProvider(exchangeId));
    final p = portfolio.value;
    if (p == null) {
      final failure = firstFailure([portfolio]);
      if (failure != null) {
        return LoadFailureView(
          error: failure,
          onRetry: () => ref.invalidate(portfolioProvider(exchangeId)),
        );
      }
      return PortfolioView(model: null, onTab: onTab);
    }
    final model = portfolioModel(p);
    return PortfolioView(
      model: model,
      hidden: _hidden,
      onToggleHidden: () => setState(() => _hidden = !_hidden),
      onBannerAction: () {
        final id = model.bannerPositionId;
        if (id != null) context.push(Routes.position(id));
      },
      onPosition: (x) => context.push(
        x.short ? Routes.position(x.id) : Routes.stock(x.listingId),
      ),
      onOrder: (o) => _cancel(exchangeId, o),
      onBrowse: () => goTab(context, AuraTab.market),
      onTab: onTab,
    );
  }
}

/// Cancels the order with one key for the attempt; a failure leaves the
/// sheet up to try again.
class _CancelSheet extends ConsumerStatefulWidget {
  const _CancelSheet({required this.order, this.onDone, this.onKeep});

  final OrderRow order;
  final VoidCallback? onDone;
  final VoidCallback? onKeep;

  @override
  ConsumerState<_CancelSheet> createState() => _CancelSheetState();
}

class _CancelSheetState extends ConsumerState<_CancelSheet> {
  final _key = IdempotencyKey();
  bool _busy = false;

  Future<void> _cancel() async {
    setState(() => _busy = true);
    try {
      await ref
          .read(tradingRepositoryProvider)
          .cancelOrder(widget.order.id, _key);
      widget.onDone?.call();
    } on ApiError {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => CancelOrderSheet(
    order: widget.order,
    busy: _busy,
    onCancel: _cancel,
    onKeep: widget.onKeep,
  );
}

/// One position (`GET /positions/{id}`), refetched on resume.
final positionProvider = FutureProvider.autoDispose.family<Position, String>((
  ref,
  positionId,
) {
  ref.watch(refetchSignalProvider);
  return ref.read(tradingRepositoryProvider).position(positionId);
});

/// A position (`/positions/:id`): an open short is W07, with its margin
/// detail and Cover; a liquidated one is its receipt (W08), once the server
/// sends how it settled; anything else is its stock page.
class PositionScreen extends ConsumerWidget {
  const PositionScreen({super.key, required this.positionId});

  final String positionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final position = ref.watch(positionProvider(positionId));
    final p = position.value;
    void back() => context.canPop() ? context.pop() : context.go(Routes.home);
    if (p == null) {
      final failure = firstFailure([position]);
      if (failure != null) {
        return LoadFailureView(
          error: failure,
          onRetry: () => ref.invalidate(positionProvider(positionId)),
        );
      }
      return const ColoredBox(
        color: Color(0xFF0B0C0E),
        child: SizedBox.expand(),
      );
    }
    if (p.status == PositionStatus.liquidated && p.liquidation != null) {
      return _Liquidated(position: p, onClose: back);
    }
    final listing = ref.watch(listingProvider(p.listing.id)).value;
    if (p.short == null || p.status != PositionStatus.open || listing == null) {
      return StockScreen(listingId: p.listing.id);
    }
    final quantity = int.tryParse(p.quantity.split('.').first) ?? 1;
    return ShortPageView(
      model: shortPageModel(listing: listing, position: p),
      onBack: back,
      onCoverPart: () => context.push(
        Routes.trade(p.listing.id, Side.cover, quantity: (quantity / 2).ceil()),
      ),
      onCoverAll: () => context.push(
        Routes.trade(p.listing.id, Side.cover, quantity: quantity),
      ),
    );
  }
}

/// W08 for a liquidated short, in the exchange's time, with the tape's line
/// about it once the stock's tape has it.
class _Liquidated extends ConsumerWidget {
  const _Liquidated({required this.position, required this.onClose});

  final Position position;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exchangeId = ref.watch(currentExchangeIdProvider);
    final exchange = exchangeId == null
        ? null
        : ref.watch(exchangeProvider(exchangeId)).value;
    if (exchangeId == null || exchange == null) {
      return const ColoredBox(
        color: Color(0xFF0B0C0E),
        child: SizedBox.expand(),
      );
    }
    final listingId = position.listing.id;
    final tape = ref.watch(listingTapeProvider((exchangeId, listingId))).value;
    return LiquidatedView(
      model: liquidatedModel(
        position: position,
        tape: liquidationTapeItem(tape ?? const [], position),
        zone: exchangeZone(exchange.timezone),
      ),
      onClose: onClose,
      onSeeStock: () => context.push(Routes.stock(listingId)),
      onPortfolio: () => goTab(context, AuraTab.portfolio),
    );
  }
}
