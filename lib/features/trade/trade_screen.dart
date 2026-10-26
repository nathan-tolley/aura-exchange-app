import 'package:decimal/decimal.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/errors.dart';
import '../../api/generated/export.dart' hide Freshness;
import '../../data/exchange_data.dart';
import '../../data/freshness.dart';
import '../../data/listing_data.dart';
import '../../data/live_market.dart';
import '../../data/me.dart';
import '../../design/widgets/aura_sheet.dart';
import '../../design/widgets/aura_skeleton.dart';
import '../../format/ticker.dart';
import '../../l10n/strings.dart';
import 'trade_flow.dart';
import 'trade_model.dart';
import 'trade_outcome_view.dart';
import 'trade_sheet_view.dart';

/// The trade sheet (`/trade/:listingId?side=`), over the stock page: the
/// ticket, then the requote (W06), the rejection (W05), the fill's receipt
/// or the resting order. Closing after a fill returns the [Trade], so the
/// stock page can say what happened.
class TradeSheet extends ConsumerStatefulWidget {
  const TradeSheet({super.key, required this.listingId, required this.side});

  final String listingId;
  final Side side;

  @override
  ConsumerState<TradeSheet> createState() => _TradeSheetState();
}

class _TradeSheetState extends ConsumerState<TradeSheet> {
  final _price = TextEditingController();

  @override
  void dispose() {
    _price.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(listingProvider(widget.listingId)).value;
    final exchangeId = ref.watch(currentExchangeIdProvider);
    final market = exchangeId == null
        ? null
        : ref.watch(marketProvider(exchangeId)).value;
    if (detail == null) {
      return AuraSheet(
        title: ' ',
        onClose: () => Navigator.of(context).maybePop(),
        children: const [AuraSkeleton(height: 260)],
      );
    }
    final state0 = market?.freshness.marketState ?? detail.marketState;
    final args = (
      listingId: widget.listingId,
      side: widget.side,
      marketOpen: state0 == MarketState.open,
    );
    final state = ref.watch(tradeFlowProvider(args));
    final flow = ref.read(tradeFlowProvider(args).notifier);
    final now = ref.watch(clockProvider);
    final ticker = formatTicker(detail.ticker);
    final live = market?.listings
        .where((l) => l.id == widget.listingId)
        .firstOrNull;
    final positionId = exchangeId == null
        ? null
        : ref
              .watch(portfolioProvider(exchangeId))
              .value
              ?.positions
              .where((p) => p.listing.id == widget.listingId)
              .firstOrNull
              ?.id;
    void close([Object? result]) => Navigator.of(context).pop(result);

    final filled = state.filled;
    if (filled != null) {
      return TradeOutcomeView(
        model: filledModel(
          filled,
          canStopLoss: filled.side == Side.buy && positionId != null,
        ),
        onClose: () => close(filled),
        onPrimary: () => close(filled),
        onSecondary: flow.toStopLoss,
      );
    }
    final order = state.order;
    if (order != null && !state.canceled) {
      return TradeOutcomeView(
        model: restingModel(order),
        onClose: () => close(order),
        onPrimary: () => close(order),
        onSecondary: flow.cancelOrder,
      );
    }
    if (state.canceled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) close();
      });
    }
    final quote = state.quote;
    final stale = state.stale;
    if (stale != null && quote != null && quote.previous != null) {
      return RequoteView(
        model: requoteModel(
          quote: quote,
          stale: stale,
          ticker: ticker,
          now: now,
        ),
        onClose: close,
        onConfirmed: flow.trade,
        onDecline: flow.declineRequote,
      );
    }
    final problem = state.problem;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: TradeTicketView(
        model: liveTicketModel(
          state: state,
          ticker: ticker,
          lastPrice: live?.price ?? Decimal.parse(detail.price),
          holdsPosition: detail.myPosition != null,
          now: now,
        ),
        price: _price,
        onPrice: flow.setPrice,
        onClose: close,
        onOrderType: flow.setOrderType,
        onQuantity: (q) => flow.setQuantity(q.toBigInt().toInt()),
        onBannerAction: problem?.action == ApiAction.reduceQuantity
            ? flow.applyFix
            : () => flow.retry(positionId: positionId),
        onTrade: state.orderType == orderMarket
            ? flow.trade
            : () => flow.placeOrder(positionId: positionId),
      ),
    );
  }
}

/// The toast the stock page shows after a fill: "Bought 12 $ANNA".
String? tradeToast(Object? result) => switch (result) {
  final Trade t => filledTitle(
    t.side,
    Decimal.parse(t.quantity),
    t.listing.ticker,
  ),
  Order _ => orderPlacedTitle,
  _ => null,
};
