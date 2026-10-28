import 'package:decimal/decimal.dart';
import 'package:timezone/timezone.dart' as tz;

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

/// A refused quote as W05 draws it: the refused order's receipt and the
/// banner with why and the fix, over the disabled button. `INSUFFICIENT_CASH`
/// and `SHORT_CAP` carry the receipt in their params (contract request #6,
/// option B); a refusal that wasn't priced (`ORDER_TOO_LARGE`) has none.
TradeTicketModel refusedTicketModel({
  required Side side,
  required Decimal quantity,
  required String ticker,
  required Decimal lastPrice,
  required ApiError rejection,
  ErrorContext context = const ErrorContext(),
}) {
  final copy = errorCopy(
    rejection,
    ErrorContext(side: side, zone: context.zone, now: context.now),
  );
  final receipt = refusedReceipt(rejection, quantity);
  return TradeTicketModel(
    title: tradeTitle(side, ticker),
    orderType: orderMarket,
    quantity: quantity,
    quantityNote: sharesAtAbout(lastPrice),
    rows: receipt?.$1 ?? const [],
    total: receipt?.$2 ?? _noTotal,
    button: tradeButton(side, quantity, ticker),
    canTrade: false,
    banner: BannerModel(
      tone: AuraBannerTone.down,
      title: copy.title,
      body: copy.body,
      action: copy.action,
    ),
  );
}

/// The refused order's receipt from the refusal's params (`price`, `gross`,
/// `feeRate`, `fee`, `total`, for the quantity asked), or null when the
/// refusal doesn't carry one.
(List<AuraReceiptRow>, AuraReceiptRow)? refusedReceipt(
  ApiError? rejection,
  Decimal quantity,
) {
  if (rejection?.params case {
    'price': final price,
    'gross': final gross,
    'feeRate': final feeRate,
    'fee': final fee,
    'total': final total,
  }) {
    return (
      [
        AuraReceiptRow(
          quantityAt(quantity, Decimal.parse(price)),
          _money(gross),
        ),
        AuraReceiptRow(feeLabel(Decimal.parse(feeRate)), _money(fee)),
      ],
      AuraReceiptRow(estimatedTotal, _money(total)),
    );
  }
  return null;
}

const _noTotal = AuraReceiptRow('', '');

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
/// when there's one to show: the quote's, or the refusal's own (W05). A
/// limit or stop asks for its price and ends in the slide that places it.
/// [zone] is the exchange's, for "tomorrow's stimulus check".
TradeTicketModel liveTicketModel({
  required TradeFlowState state,
  required String ticker,
  required Decimal lastPrice,
  required bool holdsPosition,
  required DateTime now,
  tz.Location? zone,
}) {
  final quantity = Decimal.fromInt(state.quantity);
  final side = state.side;
  final quote = state.orderType == orderMarket ? state.quote : null;
  final problem = state.problem;
  final banner = _banner(
    problem,
    ErrorContext(side: side, zone: zone, now: now),
  );
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
  final refused = quote == null ? refusedReceipt(problem, quantity) : null;
  return TradeTicketModel(
    title: title,
    orderType: orderMarket,
    orderTypes: types,
    quantity: quantity,
    quantityNote: sharesAtAbout(
      quote == null ? lastPrice : Decimal.parse(quote.currentPrice),
    ),
    rows: quote == null
        ? refused?.$1 ?? const []
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
        ? refused?.$2 ?? _noTotal
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
BannerModel? _banner(ApiError? problem, ErrorContext context) {
  if (problem == null) return null;
  if (problem.code == ApiError.appOffline) {
    return BannerModel(
      tone: AuraBannerTone.offline,
      title: tradeOffline.title,
      body: tradeOffline.body,
      action: tradeOffline.action,
    );
  }
  final copy = errorCopy(problem, context);
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
