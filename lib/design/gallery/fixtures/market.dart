import 'package:flutter/widgets.dart';

import '../../../api/errors.dart';
import '../../../api/generated/export.dart' hide Freshness;
import '../../../data/freshness.dart';
import '../../../data/live_market.dart';
import '../../../features/market/market_model.dart';
import '../../../features/market/market_view.dart';
import '../../../format/time.dart';
import 'frames.dart';

// The Market tab's states (SCREENS.md #6): the drawn screens' four friends
// plus two more, at 9:41 pm in Sydney.

final _sydney = exchangeZone('Australia/Sydney');
final _now = DateTime.utc(2026, 10, 24, 10, 41);

Map<String, Object?> _listing(
  String n,
  String ticker,
  String name,
  String price,
  String abs,
  String pct, {
  String state = 'ACTIVE',
  bool mine = false,
  String? position,
  List<String> badges = const [],
  List<double> points = const [],
}) => {
  'id': '11111111-0000-4000-8000-00000000000$n',
  'ticker': ticker,
  'displayName': name,
  'avatarUrl': null,
  'price': price,
  'changeAbs': abs,
  'changePct': pct,
  'state': state,
  'badges': badges,
  'sparkline': [for (final p in points) p.toStringAsFixed(2)],
  'isMine': mine,
  'myPosition': position == null ? null : {'side': position, 'quantity': '12'},
};

const _anna = [118.0, 117.6, 118.5, 119.0, 120.5, 121.5, 123.0, 124.1];
const _jake = [112.4, 112.2, 104.0, 103.0, 104.2, 105.1, 104.5, 101.9];
const _eli = [89.7, 89.2, 89.5, 88.6, 88.1, 88.2, 87.7, 87.55];
const _mia = [96.0, 97.2, 98.8, 99.1, 101.4, 103.0, 104.9, 106.2];
const _sam = [104.0, 103.1, 102.0, 101.2, 100.4, 99.8, 99.1, 98.4];

LiveMarket _market({
  String state = 'OPEN',
  bool halted = false,
}) => LiveMarket.from(
  Market.fromJson({
    'asOf': _now.toIso8601String(),
    'marketState': state,
    'nextChangeAt': null,
    'exchangeId': '7c1d2e3f-0a1b-4c5d-8e9f-a0b1c2d3e4f5',
    'index': {'name': 'Aura Composite', 'value': '103.42', 'changePct': '1.12'},
    'listings': [
      _listing(
        '1',
        r'$ANNA',
        'Anna',
        '124.10',
        '7.79',
        '6.70',
        position: 'LONG',
        points: _anna,
      ),
      _listing(
        '2',
        r'$JAKE',
        'Jake',
        '101.90',
        '-10.50',
        '-9.34',
        position: 'SHORT',
        state: halted ? 'HALTED' : 'ACTIVE',
        points: _jake,
      ),
      _listing('3', r'$NATE', 'Nathan', '100.00', '0.00', '0.00', mine: true),
      _listing('4', r'$ELI', 'Eli', '87.55', '-2.15', '-2.40', points: _eli),
      _listing(
        '5',
        r'$MIA',
        'Mia',
        '106.20',
        '10.20',
        '10.63',
        badges: ['RUMOR_PENDING'],
        points: _mia,
      ),
      _listing('6', r'$SAM', 'Sam', '98.40', '-5.60', '-5.38', points: _sam),
    ],
    'queuedEventsCount': 0,
    'tradingEnabled': true,
  }),
);

Widget _view(LiveMarket market, {String query = '', bool live = true}) =>
    Controlled(
      texts: [query],
      builder: (context, c) => MarketView(
        model: marketListModel(
          market: market,
          liveness: live ? Liveness.live : Liveness.delayed,
          query: query,
          zone: _sydney,
          now: live ? _now : _now.add(const Duration(minutes: 7)),
        ),
        search: c[0],
        onSearch: (_) {},
        onRetry: _noop,
        onRow: (_) {},
        onTab: (_) {},
      ),
    );

/// S06a: every listing by today's change, biggest gain first.
Widget marketSorted() => _view(_market());

/// S06b: a halted listing, tagged in warn, its price held.
Widget marketHaltedRow() => _view(_market(halted: true));

/// S06c: searching.
Widget marketSearch() => _view(_market(), query: 'an');

/// S06d: a search with no results.
Widget marketNoResults() => _view(_market(), query: 'zz');

/// S06e: the first numbers loading.
Widget marketLoading() => MarketView(model: null, onTab: (_) {});

/// S06f: offline, every price stamped.
Widget marketOffline() =>
    _view(_market().withProblem(const ApiError.offline()), live: false);

void _noop() {}
