import 'package:flutter/widgets.dart';

import '../../../api/generated/export.dart' hide Freshness;
import '../../../features/portfolio/portfolio_view.dart';
import 'frames.dart';

// The Portfolio tab (SCREENS.md #20). W07 (margin warning) and W08
// (liquidated) are drawn and live with the other drawn screens.

Map<String, Object?> _ref(String n, String ticker, String name) => {
  'id': '11111111-0000-4000-8000-00000000000$n',
  'ticker': ticker,
  'displayName': name,
  'avatarUrl': null,
};

Map<String, Object?> _position(
  String n,
  String ticker,
  String name, {
  String side = 'LONG',
  String status = 'OPEN',
  String quantity = '12',
  String price = '124.10',
  String pnl = '73.20',
  String pnlPct = '5.17',
  Map<String, Object?>? short,
}) => {
  'id': '55555555-0000-4000-8000-00000000000$n',
  'listing': _ref(n, ticker, name),
  'side': side,
  'status': status,
  'quantity': quantity,
  'avgPrice': '118.00',
  'marketPrice': price,
  'marketValue': '1489.20',
  'unrealizedPnl': pnl,
  'unrealizedPnlPct': pnlPct,
  'short': short,
  'openedAt': '2026-10-22T01:00:00Z',
  'closedAt': status == 'OPEN' ? null : '2026-10-24T04:12:00Z',
};

Map<String, Object?> _order(String n) => {
  'id': '66666666-0000-4000-8000-00000000000$n',
  'listing': _ref('4', r'$ELI', 'Eli'),
  'type': 'LIMIT_BUY',
  'quantity': '10',
  'triggerPrice': '85.00',
  'status': 'RESTING',
  'reservedCash': '855.13',
  'createdAt': '2026-10-24T09:00:00Z',
  'filledAt': null,
  'fillPrice': null,
  'rejectCode': null,
};

Portfolio _portfolio({
  List<Map<String, Object?>> positions = const [],
  List<Map<String, Object?>> orders = const [],
  String cash = '2264.50',
  String reserved = '0.00',
}) => Portfolio.fromJson({
  'asOf': '2026-10-24T10:41:00Z',
  'marketState': 'OPEN',
  'nextChangeAt': null,
  'exchangeId': '7c1d2e3f-0a1b-4c5d-8e9f-a0b1c2d3e4f5',
  'cash': cash,
  'reservedCash': reserved,
  'netWorth': '12486.20',
  'seasonChangeAbs': '2486.20',
  'seasonChangePct': '24.86',
  'dayChangeAbs': '312.40',
  'dayChangePct': '2.57',
  'positions': positions,
  'openOrders': orders,
  'canDeclareBankruptcy': false,
});

final _anna = _position('1', r'$ANNA', 'Anna');
final _jakeShort = _position(
  '2',
  r'$JAKE',
  'Jake',
  side: 'SHORT',
  quantity: '60',
  price: '112.30',
  pnl: '-888.00',
  pnlPct: '-15.18',
  short: {
    'collateral': '8775.00',
    'collateralRatioPct': '130.00',
    'warningRatioPct': '140.00',
    'maintenanceRatioPct': '125.00',
    'liquidationPrice': '117.00',
    'borrowFeeDailyPct': '0.60',
  },
);
final _samLiquidated = _position(
  '6',
  r'$SAM',
  'Sam',
  side: 'SHORT',
  status: 'LIQUIDATED',
  quantity: '20',
  price: '121.40',
  pnl: '-412.60',
  pnlPct: '-20.63',
);

Widget _view(Portfolio? p) => PortfolioView(
  model: p == null ? null : portfolioModel(p),
  onToggleHidden: _noop,
  onBannerAction: _noop,
  onPosition: (_) {},
  onOrder: (_) {},
  onBrowse: _noop,
  onTab: (_) {},
);

/// S20a: positions and cash, a short near liquidation, one liquidated.
Widget portfolioPositions() =>
    _view(_portfolio(positions: [_anna, _jakeShort, _samLiquidated]));

/// S20b: open orders, with what they hold from your cash.
Widget portfolioOrders() => _view(
  _portfolio(
    positions: [_anna],
    orders: [_order('1')],
    cash: '1409.37',
    reserved: '855.13',
  ),
);

/// S20c: all cash.
Widget portfolioEmpty() => _view(_portfolio(cash: '10000.00'));

/// S20d: loading.
Widget portfolioLoading() => _view(null);

/// S20e: cancelling an order.
Widget portfolioCancel() => sheetOver(
  portfolioOrders(),
  CancelOrderSheet(
    order: portfolioModel(_portfolio(orders: [_order('1')])).orders.single,
    onCancel: _noop,
    onKeep: _noop,
  ),
);

void _noop() {}
