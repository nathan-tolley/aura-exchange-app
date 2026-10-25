import '../../api/errors.dart';
import '../../api/generated/export.dart' hide Freshness;
import '../../data/freshness.dart';
import '../../data/live_market.dart';
import '../../features/home/home_model.dart';
import '../../features/home/home_view.dart';
import '../../format/time.dart';
import '../../l10n/strings.dart';
import '../icons.dart';

// The drawn screens' data (design/reference/screens/W##-*.png), as the API
// would send it. Screens are built from these through the same presenters
// the app uses, so a golden that matches its reference proves the data path
// too. Times: the exchange is in Sydney, and "9:41 pm" is 10:41 UTC on
// Saturday 24 October 2026.

final sydney = exchangeZone('Australia/Sydney');
final fixtureNow = DateTime.utc(2026, 10, 24, 10, 41);
const exchangeId = '7c1d2e3f-0a1b-4c5d-8e9f-a0b1c2d3e4f5';

const _anna = '11111111-0000-4000-8000-000000000001';
const _jake = '11111111-0000-4000-8000-000000000002';
const _nate = '11111111-0000-4000-8000-000000000003';
const _eli = '11111111-0000-4000-8000-000000000004';

Map<String, Object?> _listing(
  String id,
  String ticker,
  String name,
  String price,
  String abs,
  String pct, {
  List<String> badges = const [],
  List<double> sparkline = const [],
  bool mine = false,
  String? position,
}) => {
  'id': id,
  'ticker': ticker,
  'displayName': name,
  'avatarUrl': null,
  'price': price,
  'changeAbs': abs,
  'changePct': pct,
  'state': 'ACTIVE',
  'badges': badges,
  'sparkline': [for (final p in sparkline) p.toStringAsFixed(2)],
  'isMine': mine,
  'myPosition': position == null ? null : {'side': position, 'quantity': '12'},
};

const _annaPoints = [
  118.0, 117.6, 118.5, 118.2, 119.0, 119.8, 120.5, //
  121.0, 121.5, 122.2, 123.0, 123.4, 124.1,
];
const _jakeOffline = [
  112.4, 112.2, 112.5, 104.0, 103.6, 103.0, //
  103.4, 104.2, 105.1, 104.6, 104.9, 104.5,
];

/// W09: flat all day, then the ruling's drop into the close.
const _jakeClosed = [112.4, 112.4, 112.4, 112.4, 112.4, 98.7];
const _eliPoints = [
  89.7, 89.2, 89.5, 88.6, 88.9, 88.1, 87.9, 88.2, 87.7, 87.55, //
];

Market _market({
  required String marketState,
  required DateTime asOf,
  DateTime? nextChangeAt,
  required List<Map<String, Object?>> listings,
  int queued = 0,
  bool tradingEnabled = true,
}) => Market.fromJson({
  'asOf': asOf.toIso8601String(),
  'marketState': marketState,
  'nextChangeAt': nextChangeAt?.toIso8601String(),
  'exchangeId': exchangeId,
  'index': {'name': 'Aura Composite', 'value': '103.42', 'changePct': '1.12'},
  'listings': listings,
  'queuedEventsCount': queued,
  'tradingEnabled': tradingEnabled,
});

Portfolio _portfolio({
  required String netWorth,
  required String seasonAbs,
  required String seasonPct,
  required DateTime asOf,
  required String marketState,
}) => Portfolio.fromJson({
  'asOf': asOf.toIso8601String(),
  'marketState': marketState,
  'nextChangeAt': null,
  'exchangeId': exchangeId,
  'cash': '2264.50',
  'reservedCash': '0.00',
  'netWorth': netWorth,
  'seasonChangeAbs': seasonAbs,
  'seasonChangePct': seasonPct,
  'dayChangeAbs': '0.00',
  'dayChangePct': '0.00',
  'positions': <Object?>[],
  'openOrders': <Object?>[],
  'canDeclareBankruptcy': false,
});

/// W09: Home after the close, with a ruling on $JAKE queued for the open.
HomeViewModel homeClosed() {
  final close = DateTime.utc(2026, 10, 24, 5); // 4:00 pm
  final market = LiveMarket.from(
    _market(
      marketState: 'CLOSED',
      asOf: close,
      nextChangeAt: DateTime.utc(2026, 10, 24, 20), // 7:00 am
      queued: 1,
      listings: [
        _listing(
          _anna,
          r'$ANNA',
          'Anna',
          '124.10',
          '7.79',
          '6.70',
          sparkline: _annaPoints,
          position: 'LONG',
        ),
        _listing(
          _jake,
          r'$JAKE',
          'Jake',
          '98.70',
          '-13.70',
          '-12.19',
          badges: ['QUEUED_FOR_OPEN'],
          sparkline: _jakeClosed,
        ),
        _listing(_nate, r'$NATE', 'Nate', '100.00', '0.00', '0.00', mine: true),
        _listing(
          _eli,
          r'$ELI',
          'Eli',
          '87.55',
          '-2.15',
          '-2.40',
          sparkline: _eliPoints,
        ),
      ],
    ),
  );
  return homeViewModel(
    market: market,
    portfolio: _portfolio(
      netWorth: '12486.20',
      seasonAbs: '2486.20',
      seasonPct: '24.86',
      asOf: close,
      marketState: 'CLOSED',
    ),
    liveness: liveness(market.freshness, connected: true, now: fixtureNow),
    watchlist: [_jake, _anna, _eli],
    season: 1,
    zone: sydney,
    now: fixtureNow,
    tapeUnread: true,
  );
}

/// W11: Home with no connection since 9:41 pm.
HomeViewModel homeOffline() {
  final now = fixtureNow.add(const Duration(minutes: 7));
  final market = LiveMarket.from(
    _market(
      marketState: 'OPEN',
      asOf: fixtureNow,
      listings: [
        _listing(
          _anna,
          r'$ANNA',
          'Anna',
          '124.10',
          '7.79',
          '6.70',
          sparkline: _annaPoints,
          position: 'LONG',
        ),
        _listing(
          _jake,
          r'$JAKE',
          'Jake',
          '101.90',
          '-10.50',
          '-9.34',
          sparkline: _jakeOffline,
          position: 'SHORT',
        ),
        _listing(_nate, r'$NATE', 'Nate', '100.00', '0.00', '0.00', mine: true),
        _listing(
          _eli,
          r'$ELI',
          'Eli',
          '87.55',
          '-2.15',
          '-2.40',
          sparkline: _eliPoints,
        ),
      ],
    ),
  ).withProblem(const ApiError.offline());
  return homeViewModel(
    market: market,
    portfolio: _portfolio(
      netWorth: '12486.20',
      seasonAbs: '2486.20',
      seasonPct: '24.86',
      asOf: fixtureNow,
      marketState: 'OPEN',
    ),
    liveness: liveness(market.freshness, connected: false, now: now),
    watchlist: [_anna, _jake, _eli],
    season: 1,
    zone: sydney,
    now: now,
  );
}

/// W12: the exchange's first day. Only you are listed; it opens at three.
HomeViewModel homeIpoDay() {
  final market = LiveMarket.from(
    _market(
      marketState: 'PRE',
      asOf: fixtureNow,
      tradingEnabled: false,
      listings: [
        _listing(_nate, r'$NATE', 'Nate', '100.00', '0.00', '0.00', mine: true),
      ],
    ),
  );
  return homeViewModel(
    market: market,
    portfolio: _portfolio(
      netWorth: '10000.00',
      seasonAbs: '0.00',
      seasonPct: '0.00',
      asOf: fixtureNow,
      marketState: 'PRE',
    ),
    liveness: liveness(market.freshness, connected: true, now: fixtureNow),
    watchlist: const [],
    season: 1,
    zone: sydney,
    now: fixtureNow,
    ipo: HomeIpoInput(
      heroNote: ipoHeroNote(3),
      section: HomeIpo(
        title: listedOf(1, 3),
        aside: cantTradeYourself,
        rows: [
          const HomeIpoRow(
            icon: AuraIcons.you,
            title: 'Mia',
            subtitle: memberPickingTicker,
            trailing: almost,
          ),
          HomeIpoRow(
            icon: AuraIcons.bell,
            title: 'Jake',
            subtitle: invitedNotOpened(
              formatAgo(
                fixtureNow.subtract(const Duration(hours: 2)),
                sydney,
                now: fixtureNow,
              ),
            ),
            trailing: nudge,
          ),
          const HomeIpoRow(
            icon: AuraIcons.plus,
            title: inviteSomeone,
            subtitle: inviteSomeoneNote,
          ),
        ],
        teaserLabel: firstOnTheTape,
        teaser:
            '“The group chat prepares for its first listings. Analysts '
            'expect volatility, poor decisions and at least one short '
            'squeeze.”',
        teaserSource: analystAtTheOpen,
      ),
    ),
  );
}
