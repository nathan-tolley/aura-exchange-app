import 'package:decimal/decimal.dart';
import 'package:flutter/widgets.dart';

import '../../../api/errors.dart';
import '../../../api/generated/export.dart' hide Freshness;
import '../../../features/stock/stock_header.dart';
import '../../../features/trade/trade_flow.dart';
import '../../../features/trade/trade_model.dart';
import '../../../features/trade/trade_outcome_view.dart';
import '../../../features/trade/trade_sheet_view.dart';
import '../../../l10n/strings.dart';
import '../../widgets/aura_status_chip.dart';
import 'frames.dart';

// The trade sheet's states (SCREENS.md #9, #10) beyond W05 and W06, each
// over the stock page as the app presents it.

final _now = DateTime.utc(2026, 10, 24, 10, 41);
const _anna = '11111111-0000-4000-8000-000000000001';

Quote _quote({
  String side = 'BUY',
  String quantity = '12',
  String price = '124.10',
  String gross = '1489.20',
  String fee = '7.45',
  String total = '1496.65',
  int holds = 12,
  Map<String, Object?>? short,
}) => Quote.fromJson({
  'asOf': _now.toIso8601String(),
  'marketState': 'OPEN',
  'nextChangeAt': null,
  'id': '22222222-0000-4000-8000-000000000002',
  'listingId': _anna,
  'side': side,
  'quantity': quantity,
  'price': price,
  'gross': gross,
  'feeRate': '0.50',
  'fee': fee,
  'total': total,
  'priceImpactPct': '0.40',
  'currentPrice': price,
  'expiresAt': _now.add(Duration(seconds: holds)).toIso8601String(),
  'previous': null,
  'short': short,
  'cashAfter': '767.85',
});

Widget _over(TradeTicketModel model, {String? price}) => Controlled(
  texts: [price ?? ''],
  builder: (context, c) => _onPage(
    TradeTicketView(
      model: model,
      price: c[0],
      onClose: _noop,
      onOrderType: (_) {},
      onQuantity: (_) {},
      onBannerAction: _noop,
      onTrade: _noop,
    ),
  ),
);

/// The stock page under the sheet, below the status bar as in W05.
Widget _onPage(Widget sheet) => Builder(
  builder: (context) => sheetOver(
    Padding(
      padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
      child: StockHeader(
        status: AuraStatus.open,
        line: stockLine(r'$ANNA', 'Anna'),
        price: Decimal.parse('124.10'),
        onBack: _noop,
      ),
    ),
    sheet,
  ),
);

TradeTicketModel _ticket(
  TradeFlowState state, {
  bool holds = true,
  DateTime? now,
}) => liveTicketModel(
  state: state,
  ticker: r'$ANNA',
  lastPrice: Decimal.parse('124.10'),
  holdsPosition: holds,
  now: now ?? _now,
);

ApiError _refused(String code, Map<String, String> params) => ApiError(
  code: code,
  params: params,
  retryable: false,
  action: ApiAction.reduceQuantity,
  status: 422,
);

/// S09a: buying, priced, the slide ready.
Widget tradeBuy() => _over(
  _ticket(
    TradeFlowState(
      side: Side.buy,
      orderType: orderMarket,
      quantity: 12,
      quote: _quote(),
    ),
  ),
);

/// S09b: selling what you hold, with Stop on offer.
Widget tradeSell() => _over(
  _ticket(
    TradeFlowState(
      side: Side.sell,
      orderType: orderMarket,
      quantity: 12,
      quote: _quote(side: 'SELL', total: '1481.75', fee: '7.45'),
    ),
  ),
);

/// S09c: a short, with the collateral it holds and its liquidation price.
Widget tradeShort() => _over(
  _ticket(
    TradeFlowState(
      side: Side.short,
      orderType: orderMarket,
      quantity: 12,
      quote: _quote(
        side: 'SHORT',
        total: '1481.75',
        short: {'collateralRequired': '2233.80', 'liquidationPrice': '148.92'},
      ),
    ),
    holds: false,
  ),
);

/// S09d: covering a short.
Widget tradeCover() => _over(
  _ticket(
    TradeFlowState(
      side: Side.cover,
      orderType: orderMarket,
      quantity: 12,
      quote: _quote(side: 'COVER'),
    ),
  ),
);

/// S09e: a limit order before the open.
Widget tradeLimit() => _over(
  _ticket(
    const TradeFlowState(
      side: Side.buy,
      orderType: orderLimit,
      quantity: 12,
      price: '118.00',
    ),
  ),
  price: '118.00',
);

/// S09f: a stop-loss on what you hold.
Widget tradeStopLoss() => _over(
  _ticket(
    const TradeFlowState(
      side: Side.sell,
      orderType: orderStop,
      quantity: 12,
      price: '110.00',
    ),
  ),
  price: '110.00',
);

/// S10a: the quote about to run out.
Widget tradeExpiring() => _over(
  _ticket(
    TradeFlowState(
      side: Side.buy,
      orderType: orderMarket,
      quantity: 12,
      quote: _quote(holds: 4),
    ),
  ),
);

/// S10b: refused: more than the pool allows.
Widget tradeTooLarge() => _over(
  _ticket(
    TradeFlowState(
      side: Side.buy,
      orderType: orderMarket,
      quantity: 500,
      quote: _quote(
        quantity: '500',
        gross: '62050.00',
        fee: '310.25',
        total: '62360.25',
      ),
      problem: _refused('ORDER_TOO_LARGE', {'maxQuantity': '400'}),
    ),
  ),
);

/// S10c: refused: the short cap.
Widget tradeShortCap() => _over(
  _ticket(
    TradeFlowState(
      side: Side.short,
      orderType: orderMarket,
      quantity: 80,
      quote: _quote(
        side: 'SHORT',
        quantity: '80',
        gross: '9928.00',
        fee: '49.64',
        total: '9878.36',
        short: {'collateralRequired': '14892.00', 'liquidationPrice': '148.92'},
      ),
      problem: _refused('SHORT_CAP', {'maxQuantity': '40', 'capPct': '25'}),
    ),
    holds: false,
  ),
);

/// S10d: filled: the receipt.
Widget tradeFilled() => _onPage(
  TradeOutcomeView(
    model: filledModel(
      Trade.fromJson({
        'id': '33333333-0000-4000-8000-000000000001',
        'quoteId': '22222222-0000-4000-8000-000000000002',
        'listing': {
          'id': _anna,
          'ticker': r'$ANNA',
          'displayName': 'Anna',
          'avatarUrl': null,
        },
        'side': 'BUY',
        'quantity': '12',
        'price': '124.10',
        'fee': '7.45',
        'total': '1496.65',
        'cashAfter': '767.85',
        'position': null,
        'executedAt': _now.toIso8601String(),
      }),
      canStopLoss: true,
    ),
    onClose: _noop,
    onPrimary: _noop,
    onSecondary: _noop,
  ),
);

/// S10e: a resting limit order.
Widget tradeResting() => _onPage(
  TradeOutcomeView(
    model: restingModel(
      Order.fromJson({
        'id': '66666666-0000-4000-8000-000000000001',
        'listing': {
          'id': _anna,
          'ticker': r'$ANNA',
          'displayName': 'Anna',
          'avatarUrl': null,
        },
        'type': 'LIMIT_BUY',
        'quantity': '12',
        'triggerPrice': '118.00',
        'status': 'RESTING',
        'reservedCash': '1437.24',
        'createdAt': _now.toIso8601String(),
        'filledAt': null,
        'fillPrice': null,
        'rejectCode': null,
      }),
    ),
    onClose: _noop,
    onPrimary: _noop,
    onSecondary: _noop,
  ),
);

/// S10f: the first price on its way.
Widget tradeQuoting() => _over(
  _ticket(
    const TradeFlowState(
      side: Side.buy,
      orderType: orderMarket,
      quantity: 12,
      quoting: true,
    ),
  ),
);

/// S10g: the slide landed with no connection; Retry won't trade twice.
Widget tradeNoNetwork() => _over(
  _ticket(
    TradeFlowState(
      side: Side.buy,
      orderType: orderMarket,
      quantity: 12,
      quote: _quote(),
      problem: const ApiError.offline(),
    ),
  ),
);

void _noop() {}
