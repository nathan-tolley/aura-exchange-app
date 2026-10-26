import 'package:decimal/decimal.dart';

import '../../api/errors.dart';
import '../../api/generated/export.dart' hide Freshness;
import '../../design/tone.dart';
import '../../design/widgets/aura_banner.dart';
import '../../design/widgets/aura_receipt.dart';
import '../../format/money.dart';
import '../../l10n/strings.dart';
import '../shared/banner_model.dart';
import 'trade_flow.dart';
import 'trade_sheet_view.dart';

/// The ticket from a quote. With a [rejection] (cash, size, short cap and
/// the rest, which the server checks when it prices), the banner says why
/// and offers the fix, and the button is disabled (W05).
///
/// The receipt needs the priced quote and the banner needs the error's
/// params (`maxQuantity`), so a refused quote needs both: contract request
/// #6 asks for them in one answer.
TradeTicketModel tradeTicketModel({
  required Quote quote,
  required String ticker,
  ApiError? rejection,
  String orderType = orderMarket,
  ErrorContext context = const ErrorContext(),
}) {
  final quantity = Decimal.parse(quote.quantity);
  final copy = rejection == null
      ? null
      : errorCopy(
          rejection,
          ErrorContext(side: quote.side, zone: context.zone, now: context.now),
        );
  return TradeTicketModel(
    title: tradeTitle(quote.side, ticker),
    orderType: orderType,
    quantity: quantity,
    quantityNote: sharesAtAbout(Decimal.parse(quote.currentPrice)),
    rows: _priceRows(quote),
    total: AuraReceiptRow(estimatedTotal, _money(quote.total)),
    button: tradeButton(quote.side, quantity, ticker),
    canTrade: rejection == null,
    banner: copy == null
        ? null
        : BannerModel(
            tone: AuraBannerTone.down,
            title: copy.title,
            body: copy.body,
            action: copy.action,
          ),
  );
}

/// The requote from the new quote (which carries what you saw in
/// `previous`) and the `QUOTE_STALE` that sent the app for it (W06).
RequoteModel requoteModel({
  required Quote quote,
  required ApiError stale,
  required String ticker,
  required DateTime now,
}) {
  final quantity = Decimal.parse(quote.quantity);
  final total = Decimal.parse(quote.total);
  final previous = quote.previous;
  final copy = errorCopy(stale, ErrorContext(side: quote.side, now: now));
  return RequoteModel(
    title: tradeTitle(quote.side, ticker, quantity: quantity),
    banner: BannerModel(
      tone: AuraBannerTone.warn,
      title: copy.title,
      body: copy.body,
    ),
    rows: [
      ..._priceRows(quote),
      if (previous != null) AuraReceiptRow(youSaw, _money(previous.total)),
    ],
    total: AuraReceiptRow(
      newTotal,
      previous == null
          ? formatMoney(total)
          : totalWithChange(total, total - Decimal.parse(previous.total)),
      tone: AuraTone.warn,
    ),
    holdsFor: quote.expiresAt.difference(now),
    slide: slideToTradeAt(quote.side, Decimal.parse(quote.price)),
    decline: dontTrade(quote.side),
  );
}

/// The live ticket (SCREENS.md #9) from where the trade is. A good quote
/// ends in the slide with its countdown; a refused one (at quote or at
/// trade) shows why with the fix and the disabled button, over the receipt
/// when there's a quote to show (W05). A limit or stop asks for its price
/// and ends in the slide that places it.
TradeTicketModel liveTicketModel({
  required TradeFlowState state,
  required String ticker,
  required Decimal lastPrice,
  required bool holdsPosition,
  required DateTime now,
}) {
  final quantity = Decimal.fromInt(state.quantity);
  final side = state.side;
  final quote = state.orderType == orderMarket ? state.quote : null;
  final problem = state.problem;
  final banner = _banner(problem, side);
  final types = switch (side) {
    Side.short || Side.cover => const [orderMarket],
    _ when holdsPosition && side == Side.sell => const [
      orderMarket,
      orderLimit,
      orderStop,
    ],
    _ => const [orderMarket, orderLimit],
  };
  final title = tradeTitle(side, ticker);
  if (state.orderType != orderMarket) {
    final stop = state.orderType == orderStop;
    final price = state.priceValue;
    return TradeTicketModel(
      title: stop ? setStopLoss : title,
      orderType: state.orderType,
      orderTypes: types,
      quantity: quantity,
      quantityNote: sharesAtAbout(lastPrice),
      priceField: (
        stop ? stopPriceLabel : limitPriceLabel,
        price == null
            ? enterAPrice
            : stop
            ? stopNote(ticker)
            : limitNote(side, ticker),
      ),
      rows: const [],
      total: const AuraReceiptRow('', ''),
      button: state.busy ? placingOrder : slideToPlaceOrder,
      canTrade: price != null && !state.busy && problem == null,
      slide: slideToPlaceOrder,
      banner: banner,
    );
  }
  final left = quote?.expiresAt.difference(now);
  final expired = left != null && left <= Duration.zero;
  final short = quote?.short;
  return TradeTicketModel(
    title: title,
    orderType: orderMarket,
    orderTypes: types,
    quantity: quantity,
    quantityNote: sharesAtAbout(
      quote == null ? lastPrice : Decimal.parse(quote.currentPrice),
    ),
    rows: quote == null
        ? const []
        : [
            ..._priceRows(quote),
            if (short != null) ...[
              AuraReceiptRow(
                collateralHeldLabel,
                _money(short.collateralRequired),
              ),
              AuraReceiptRow(
                liquidationPriceLabel,
                _money(short.liquidationPrice),
                tone: AuraTone.warn,
              ),
            ],
          ],
    total: quote == null
        ? const AuraReceiptRow('', '')
        : AuraReceiptRow(estimatedTotal, _money(quote.total)),
    loading: quote == null && state.quoting,
    holdsFor: quote == null || expired || problem != null || state.busy
        ? null
        : left,
    refreshing: quote == null && state.quoting
        ? gettingPrice
        : expired
        ? gettingNewPrice
        : null,
    button: tradeButton(side, quantity, ticker),
    canTrade:
        quote != null &&
        problem == null &&
        !state.quoting &&
        !state.busy &&
        !expired,
    slide: slideToTrade(side, quantity, ticker),
    slideDown: side == Side.short,
    banner: banner,
  );
}

/// A failure as the ticket shows it: W11's banner with Retry when offline,
/// otherwise the error's copy with its fix (W05).
BannerModel? _banner(ApiError? problem, Side side) {
  if (problem == null) return null;
  if (problem.code == ApiError.appOffline) {
    return BannerModel(
      tone: AuraBannerTone.offline,
      title: tradeOffline.title,
      body: tradeOffline.body,
      action: tradeOffline.action,
    );
  }
  final copy = errorCopy(problem, ErrorContext(side: side));
  return BannerModel(
    tone: AuraBannerTone.down,
    title: copy.title,
    body: copy.body,
    action: copy.action,
  );
}

List<AuraReceiptRow> _priceRows(Quote quote) => [
  AuraReceiptRow(
    quantityAt(Decimal.parse(quote.quantity), Decimal.parse(quote.price)),
    _money(quote.gross),
  ),
  AuraReceiptRow(feeLabel(Decimal.parse(quote.feeRate)), _money(quote.fee)),
];

String _money(String amount) => formatMoney(Decimal.parse(amount));
