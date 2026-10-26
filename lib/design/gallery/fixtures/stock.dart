import 'package:flutter/widgets.dart';

import '../../../api/generated/export.dart' hide Freshness;
import '../../../data/freshness.dart';
import '../../../features/stock/stock_model.dart';
import '../../../features/stock/stock_view.dart';
import '../../../format/time.dart';

// The stock page's states (SCREENS.md #7, #8), at 9:41 pm in Sydney. W10
// (halted) is drawn and lives with the other drawn screens.

final _sydney = exchangeZone('Australia/Sydney');
final _now = DateTime.utc(2026, 10, 24, 10, 41);
final _open = DateTime.utc(2026, 10, 23, 22); // 9:00 am

Map<String, Object?> _event(
  String n,
  String status,
  String text, {
  int? impact,
  int hoursAgo = 2,
}) => {
  'id': '44444444-0000-4000-8000-00000000000$n',
  'subject': {
    'id': '11111111-0000-4000-8000-000000000001',
    'ticker': r'$ANNA',
    'displayName': 'Anna',
    'avatarUrl': null,
  },
  'status': status,
  'teaser': text,
  'headline': impact == null ? null : text,
  'impactFinal': impact,
  'category': null,
  'createdAt': _now.subtract(Duration(hours: hoursAgo)).toIso8601String(),
};

ListingDetail _detail({
  String ticker = r'$ANNA',
  String name = 'Anna',
  String price = '124.10',
  String abs = '7.79',
  String pct = '6.70',
  String marketState = 'OPEN',
  String state = 'ACTIVE',
  bool mine = false,
  String? position = 'LONG',
  List<String> badges = const [],
  String? indicated,
  String? indicatedPct,
  List<Map<String, Object?>>? events,
  bool analyst = true,
}) => ListingDetail.fromJson({
  'asOf': _now.toIso8601String(),
  'marketState': marketState,
  'nextChangeAt': marketState == 'CLOSED'
      ? DateTime.utc(2026, 10, 24, 20).toIso8601String()
      : null,
  'id': '11111111-0000-4000-8000-000000000001',
  'ticker': ticker,
  'displayName': name,
  'avatarUrl': null,
  'price': price,
  'changeAbs': abs,
  'changePct': pct,
  'state': state,
  'badges': badges,
  'sparkline': <String>[],
  'isMine': mine,
  'myPosition': position == null ? null : {'side': position, 'quantity': '12'},
  'prevClose': '116.31',
  'open': '117.00',
  'dayHigh': '125.02',
  'dayLow': '116.80',
  'seasonHigh': '131.40',
  'seasonLow': '88.12',
  'volume': '1840',
  'shortInterestPct': '12.00',
  'borrowFeeDailyPct': '0.20',
  'indicatedPrice': indicated,
  'indicatedChangePct': indicatedPct,
  'halt': null,
  'lastTradeAt': DateTime.utc(2026, 10, 24, 4, 58).toIso8601String(),
  'events':
      events ??
      [
        _event(
          '1',
          'RULED',
          'Anna named employee of the month; analysts cite “visibility”',
          impact: 22,
        ),
        _event(
          '2',
          'VOIDED',
          'Unconfirmed: Anna seen leaving the gym before 6 am.',
          hoursAgo: 30,
        ),
      ],
  'analyst': analyst
      ? {
          'rating': 'BUY',
          'priceTarget': '130.00',
          'note':
              'We are raising our target. Management continues to execute '
              'on punctuality, a sector first.',
        }
      : null,
});

const _anna = [
  116.8, 117.0, 117.6, 118.5, 118.2, 119.0, 119.8, 120.5, 121.0, //
  121.5, 122.2, 123.0, 123.4, 124.1,
];

CandleSeries _candles(List<double> closes, {String prevClose = '116.31'}) =>
    CandleSeries.fromJson({
      'asOf': _now.toIso8601String(),
      'marketState': 'OPEN',
      'nextChangeAt': null,
      'interval': '5m',
      'candles': [
        for (final (i, c) in closes.indexed)
          {
            't': _open.add(Duration(minutes: 45 * i)).toIso8601String(),
            'o': c.toStringAsFixed(2),
            'h': c.toStringAsFixed(2),
            'l': c.toStringAsFixed(2),
            'c': c.toStringAsFixed(2),
            'v': '20',
          },
      ],
      'markers': [
        {
          't': _open.add(const Duration(minutes: 45 * 6)).toIso8601String(),
          'eventId': '44444444-0000-4000-8000-000000000001',
          'impact': 22,
          'category': 'PRODUCT_LAUNCH',
        },
      ],
      'prevClose': prevClose,
    });

Widget _page(
  ListingDetail detail, {
  CandleSeries? candles,
  bool chart = true,
  StockTab tab = StockTab.overview,
  List<TapeItem>? tape,
  bool offline = false,
}) {
  final model = stockPageModel(
    detail: detail,
    live: null,
    freshness: Freshness(
      asOf: detail.asOf,
      marketState: detail.marketState,
      nextChangeAt: detail.nextChangeAt,
    ),
    liveness: offline ? Liveness.delayed : Liveness.live,
    offline: offline,
    candles: chart ? candles ?? _candles(_anna) : null,
    range: '1D',
    tab: tab,
    tape: tape,
    zone: _sydney,
    now: offline ? _now.add(const Duration(minutes: 7)) : _now,
  );
  return StockPageView(
    model: model,
    onBack: _noop,
    onBannerAction: _noop,
    onRange: (_) {},
    onTab: (_) {},
    onEvent: (_) {},
    onFile: _noop,
    onTrade: offline ? null : (_) {},
  );
}

/// S07a: Anna, held, the market open, a ruling on the day's chart.
Widget stockDefault() => _page(_detail());

/// S07b: your own stock: no trade bar, and why.
Widget stockYours() => _page(
  _detail(
    ticker: r'$NATE',
    name: 'Nathan',
    mine: true,
    position: null,
    events: const [],
    analyst: false,
  ),
);

/// S07c: closed, with the price it's indicated to open at.
Widget stockClosedIndicated() => _page(
  _detail(
    ticker: r'$JAKE',
    name: 'Jake',
    price: '112.40',
    abs: '0.00',
    pct: '0.00',
    marketState: 'CLOSED',
    position: null,
    badges: ['QUEUED_FOR_OPEN'],
    indicated: '98.70',
    indicatedPct: '-12.19',
  ),
  candles: _candles(const [
    112.4,
    112.4,
    112.6,
    112.3,
    112.4,
  ], prevClose: '112.40'),
);

/// S07d: a rumor pending about the stock.
Widget stockRumorPending() => _page(
  _detail(
    ticker: r'$MIA',
    name: 'Mia',
    price: '106.20',
    abs: '10.20',
    pct: '10.63',
    position: null,
    badges: ['RUMOR_PENDING'],
    events: [
      _event(
        '3',
        'RUMOR',
        'Unconfirmed: reports of a late-night karaoke incident.',
        hoursAgo: 0,
      ),
    ],
  ),
);

/// S07e: delisted: the holders were cashed out, nothing trades.
Widget stockDelisted() => _page(
  _detail(
    ticker: r'$SAM',
    name: 'Sam',
    price: '98.40',
    abs: '0.00',
    pct: '0.00',
    state: 'DELISTED',
    position: null,
    analyst: false,
  ),
);

/// S07f: offline: the numbers stamped, trading off with the reason.
Widget stockOfflineState() => _page(_detail(), offline: true);

/// S07g: the chart still loading.
Widget stockChartLoading() => _page(_detail(), chart: false);

/// S07h: the stock's own tape.
Widget stockTape() => _page(
  _detail(),
  tab: StockTab.tape,
  tape: [
    TapeItem.fromJson({
      'id': '55555555-0000-4000-8000-000000000001',
      'type': 'RULING',
      'at': _now.subtract(const Duration(hours: 2)).toIso8601String(),
      'listing': {
        'id': '11111111-0000-4000-8000-000000000001',
        'ticker': r'$ANNA',
        'displayName': 'Anna',
        'avatarUrl': null,
      },
      'headline':
          'Anna named employee of the month; analysts cite “visibility”',
      'body': null,
      'impact': 22,
      'priceMovePct': '6.70',
      'eventId': '44444444-0000-4000-8000-000000000001',
      'haltId': null,
    }),
  ],
);

/// S07i: the Analyst's note.
Widget stockAnalyst() => _page(_detail(), tab: StockTab.analyst);

/// S08b: the overview with no events yet.
Widget stockNoEvents() => _page(
  _detail(ticker: r'$ELI', name: 'Eli', position: null, events: const []),
);

void _noop() {}
