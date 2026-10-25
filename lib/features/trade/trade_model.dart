import 'package:decimal/decimal.dart';

import '../../api/errors.dart';
import '../../api/generated/export.dart' hide Freshness;
import '../../design/tone.dart';
import '../../design/widgets/aura_banner.dart';
import '../../design/widgets/aura_receipt.dart';
import '../../format/money.dart';
import '../../l10n/strings.dart';
import '../shared/banner_model.dart';
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

List<AuraReceiptRow> _priceRows(Quote quote) => [
  AuraReceiptRow(
    quantityAt(Decimal.parse(quote.quantity), Decimal.parse(quote.price)),
    _money(quote.gross),
  ),
  AuraReceiptRow(feeLabel(Decimal.parse(quote.feeRate)), _money(quote.fee)),
];

String _money(String amount) => formatMoney(Decimal.parse(amount));
