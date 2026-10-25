import '../../api/errors.dart';
import '../../api/generated/export.dart' hide Freshness;
import '../../data/freshness.dart';
import '../../data/live_market.dart';
import '../../features/home/home_model.dart';
import '../../features/home/home_view.dart';
import '../../features/portfolio/liquidated_model.dart';
import '../../features/portfolio/liquidated_view.dart';
import '../../features/stock/short_model.dart';
import '../../features/stock/short_view.dart';
import '../../features/stock/halted_model.dart';
import '../../features/stock/halted_view.dart';
import '../../features/trade/trade_model.dart';
import '../../features/trade/trade_sheet_view.dart';
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
            'The group chat prepares for its first listings. Analysts '
            'expect volatility, poor decisions and at least one short '
            'squeeze.',
        teaserSource: analystAtTheOpen,
      ),
    ),
  );
}

Quote _quote({
  required String side,
  required String quantity,
  required String price,
  required String gross,
  required String fee,
  required String total,
  required String cashAfter,
  required DateTime now,
  Map<String, Object?>? previous,
}) => Quote.fromJson({
  'asOf': now.toIso8601String(),
  'marketState': 'OPEN',
  'nextChangeAt': null,
  'id': '22222222-0000-4000-8000-000000000001',
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
  'expiresAt': now.add(const Duration(seconds: 15)).toIso8601String(),
  'previous': previous,
  'short': null,
  'cashAfter': cashAfter,
});

/// W05: buying 20 $ANNA with A$2,264.50 in cash. Sunday 1 pm in Sydney, so
/// Monday's 9 am stimulus check is tomorrow's.
TradeTicketModel tradeRejected() {
  final now = DateTime.utc(2026, 10, 25, 2);
  return tradeTicketModel(
    quote: _quote(
      side: 'BUY',
      quantity: '20',
      price: '124.10',
      gross: '2482.00',
      fee: '12.41',
      total: '2494.41',
      cashAfter: '-229.91',
      now: now,
    ),
    ticker: r'$ANNA',
    rejection: const ApiError(
      code: 'INSUFFICIENT_CASH',
      params: {
        'needed': '2494.41',
        'available': '2264.50',
        'shortBy': '229.91',
        'maxQuantity': '18',
        'nextStimulusAt': '2026-10-25T22:00:00Z',
      },
      retryable: false,
      action: ApiAction.reduceQuantity,
      status: 422,
    ),
    context: ErrorContext(zone: sydney, now: now),
  );
}

/// W06: someone bought $ANNA between the quote and the slide.
RequoteModel requote() => requoteModel(
  quote: _quote(
    side: 'BUY',
    quantity: '12',
    price: '125.36',
    gross: '1504.32',
    fee: '7.52',
    total: '1511.84',
    cashAfter: '752.66',
    now: fixtureNow,
    previous: {
      'quoteId': '22222222-0000-4000-8000-000000000000',
      'price': '124.10',
      'total': '1496.65',
      'changePct': '1.02',
    },
  ),
  stale: const ApiError(
    code: 'QUOTE_STALE',
    params: {'oldPrice': '124.10', 'newPrice': '125.36', 'changePct': '1.02'},
    retryable: true,
    action: ApiAction.requote,
    status: 409,
  ),
  ticker: r'$ANNA',
  now: fixtureNow,
);

const _mia = '11111111-0000-4000-8000-000000000005';
const _miaEvent = '33333333-0000-4000-8000-000000000001';

/// W10: $MIA halted at 4:51 pm for a +22 merger ruling; 4 of 6 have voted
/// and the vote closes in 24:10.
(ListingDetail, EventSummary) haltedMia() {
  final event = <String, Object?>{
    'id': _miaEvent,
    'subject': {
      'id': _mia,
      'ticker': r'$MIA',
      'displayName': 'Mia',
      'avatarUrl': null,
    },
    'status': 'HALTED',
    'teaser': 'Something big about Mia is under review.',
    'headline': 'Mia announces merger; regulators reviewing',
    'impactFinal': 22,
    'category': 'MERGER',
    'createdAt': '2026-10-24T05:50:00Z',
  };
  final listing = ListingDetail.fromJson({
    'asOf': fixtureNow.toIso8601String(),
    'marketState': 'OPEN',
    'nextChangeAt': null,
    'id': _mia,
    'ticker': r'$MIA',
    'displayName': 'Mia',
    'avatarUrl': null,
    'price': '96.20',
    'changeAbs': '0.00',
    'changePct': '0.00',
    'state': 'HALTED',
    'badges': <Object?>[],
    'sparkline': <Object?>[],
    'isMine': false,
    'myPosition': null,
    'prevClose': '96.20',
    'open': '96.20',
    'dayHigh': '96.20',
    'dayLow': '96.20',
    'seasonHigh': '104.00',
    'seasonLow': '91.30',
    'volume': '412',
    'shortInterestPct': '3.10',
    'borrowFeeDailyPct': '0.05',
    'indicatedPrice': null,
    'indicatedChangePct': null,
    'halt': {
      'id': '44444444-0000-4000-8000-000000000001',
      'scope': 'LISTING',
      'listingId': _mia,
      'reason': 'NEWS_PENDING',
      'status': 'VOTING',
      'startedAt': '2026-10-24T05:51:00Z',
      'endsAt': fixtureNow
          .add(const Duration(minutes: 24, seconds: 10))
          .toIso8601String(),
      'eventId': _miaEvent,
      'vote': {
        'confirm': 2,
        'decline': 1,
        'reconsider': 1,
        'eligible': 6,
        'mine': null,
        'reward': '100.00',
      },
      'ifConfirmedMovePct': '16.20',
    },
    'lastTradeAt': '2026-10-24T05:51:00Z',
    'events': [event],
    'analyst': null,
  });
  return (listing, EventSummary.fromJson(event));
}

HaltedStockModel halted() {
  final (listing, event) = haltedMia();
  return haltedStockModel(
    listing: listing,
    event: event,
    zone: sydney,
    now: fixtureNow,
  );
}

Map<String, Object?> _jakeShort({required String status}) => {
  'id': '55555555-0000-4000-8000-000000000001',
  'listing': {
    'id': _jake,
    'ticker': r'$JAKE',
    'displayName': 'Jake',
    'avatarUrl': null,
  },
  'side': 'SHORT',
  'status': status,
  'quantity': '60',
  'avgPrice': '97.50',
  'marketPrice': '112.30',
  'marketValue': '6738.00',
  'unrealizedPnl': '-888.00',
  'unrealizedPnlPct': '-15.18',
  'short': {
    'collateral': '8775.00',
    'collateralRatioPct': '130.00',
    'warningRatioPct': '140.00',
    'maintenanceRatioPct': '125.00',
    'liquidationPrice': '117.00',
    'borrowFeeDailyPct': '0.60',
  },
  'openedAt': '2026-10-20T01:00:00Z',
  'closedAt': status == 'OPEN' ? null : '2026-10-24T04:12:00Z',
};

/// W07: short 60 $JAKE from A$97.50; it's at A$112.30, 4.2% from the
/// A$117.00 liquidation price, with the collateral at 130%.
ShortPageModel shortNearLiquidation() => shortPageModel(
  listing: ListingDetail.fromJson({
    'asOf': fixtureNow.toIso8601String(),
    'marketState': 'OPEN',
    'nextChangeAt': null,
    'id': _jake,
    'ticker': r'$JAKE',
    'displayName': 'Jake',
    'avatarUrl': null,
    'price': '112.30',
    'changeAbs': '10.40',
    'changePct': '10.21',
    'state': 'ACTIVE',
    'badges': ['HARD_TO_BORROW'],
    'sparkline': <Object?>[],
    'isMine': false,
    'myPosition': {'side': 'SHORT', 'quantity': '60'},
    'prevClose': '101.90',
    'open': '102.10',
    'dayHigh': '112.80',
    'dayLow': '101.40',
    'seasonHigh': '118.20',
    'seasonLow': '88.40',
    'volume': '1840',
    'shortInterestPct': '31.00',
    'borrowFeeDailyPct': '0.60',
    'indicatedPrice': null,
    'indicatedChangePct': null,
    'halt': null,
    'lastTradeAt': fixtureNow.toIso8601String(),
    'events': <Object?>[],
    'analyst': null,
  }),
  position: Position.fromJson(_jakeShort(status: 'OPEN')),
);

/// W08: the same short, liquidated at 3:12 pm when $JAKE crossed A$117.00.
LiquidatedModel liquidated() => liquidatedModel(
  liquidation: Liquidation(
    position: Position.fromJson(_jakeShort(status: 'LIQUIDATED')),
    at: DateTime.utc(2026, 10, 24, 4, 12),
    triggerPrice: '117.00',
    maintenanceRatioPct: '125.00',
    price: '118.10',
    cost: '7086.00',
    feeRatePct: '0.50',
    fee: '35.43',
    returned: '1653.57',
    realizedPnl: '-1271.43',
    realizedPnlPct: '-21.73',
  ),
  tape: TapeItem.fromJson({
    'id': '66666666-0000-4000-8000-000000000001',
    'type': 'LIQUIDATION',
    'at': '2026-10-24T04:12:00Z',
    'listing': {
      'id': _jake,
      'ticker': r'$JAKE',
      'displayName': 'Jake',
      'avatarUrl': null,
    },
    'headline':
        r'Bears obliterated as $JAKE rips 15%. One short seller forcibly '
        'removed from the position.',
    'body': null,
    'impact': null,
    'priceMovePct': '15.00',
    'eventId': null,
    'haltId': null,
  }),
  zone: sydney,
);
