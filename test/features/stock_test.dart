import 'package:aura_exchange/api/generated/export.dart' hide Freshness;
import 'package:aura_exchange/data/freshness.dart';
import 'package:aura_exchange/design/widgets/aura_banner.dart';
import 'package:aura_exchange/design/widgets/aura_status_chip.dart';
import 'package:aura_exchange/features/stock/stock_model.dart';
import 'package:aura_exchange/format/time.dart';
import 'package:aura_exchange/l10n/strings.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

/// The stock page (SCREENS.md #7, #8).
void main() {
  final zone = exchangeZone('Australia/Sydney');
  final now = DateTime.utc(2026, 10, 24, 10, 41);

  ListingDetail detail({
    String marketState = 'OPEN',
    String state = 'ACTIVE',
    bool mine = false,
    String? position,
    List<String> badges = const [],
    String? indicated,
    List<Map<String, Object?>> events = const [],
  }) => ListingDetail.fromJson({
    'asOf': now.toIso8601String(),
    'marketState': marketState,
    'nextChangeAt': '2026-10-24T20:00:00Z',
    'id': '11111111-0000-4000-8000-000000000002',
    'ticker': r'$JAKE',
    'displayName': 'Jake',
    'avatarUrl': null,
    'price': '112.40',
    'changeAbs': '1.00',
    'changePct': '0.90',
    'state': state,
    'badges': badges,
    'sparkline': <String>[],
    'isMine': mine,
    'myPosition': position == null
        ? null
        : {'side': position, 'quantity': '12'},
    'prevClose': '111.40',
    'open': null,
    'dayHigh': '113.00',
    'dayLow': '110.00',
    'seasonHigh': '131.40',
    'seasonLow': '88.12',
    'volume': '1840',
    'shortInterestPct': '31.00',
    'borrowFeeDailyPct': '0.60',
    'indicatedPrice': indicated,
    'indicatedChangePct': indicated == null ? null : '-12.19',
    'halt': null,
    'lastTradeAt': '2026-10-24T04:58:00Z',
    'events': events,
    'analyst': null,
  });

  StockPageModel model(ListingDetail d, {bool offline = false}) =>
      stockPageModel(
        detail: d,
        live: null,
        freshness: Freshness(
          asOf: d.asOf,
          marketState: d.marketState,
          nextChangeAt: d.nextChangeAt,
        ),
        liveness: offline ? Liveness.delayed : Liveness.live,
        offline: offline,
        candles: null,
        range: '1D',
        tab: StockTab.overview,
        tape: null,
        zone: zone,
        now: now,
      );

  test('the trade bar follows your position', () {
    String bar(String? position) =>
        model(detail(position: position)).actions.map((a) => a.label).join('/');
    expect(bar(null), '$short/$buy');
    expect(bar('LONG'), '$sell/$buy');
    expect(bar('SHORT'), '$shortMore/$coverLabel');
    expect(model(detail(position: 'SHORT')).actions.last.side, Side.cover);
  });

  test('your own stock and a delisted one have no bar, and say why', () {
    final yours = model(detail(mine: true));
    expect(yours.actions, isEmpty);
    expect(yours.note, youCantTradeYourself);
    final gone = model(detail(state: 'DELISTED'));
    expect(gone.actions, isEmpty);
    expect(gone.note, delistedNoTrading);
    expect(gone.banner?.title, r'$JAKE is delisted');
  });

  test('closed with an indicated price shows it as ≈, and why', () {
    final m = model(
      detail(
        marketState: 'CLOSED',
        badges: ['QUEUED_FOR_OPEN'],
        indicated: '98.70',
      ),
    );
    expect(m.price, Decimal.parse('98.70'));
    expect(m.approx, isTrue);
    expect(m.changePct, Decimal.parse('-12.19'));
    expect(m.changePeriod, indicated);
    expect(m.status, AuraStatus.closed);
    expect(m.banner?.body, startsWith(r'A ruling on $JAKE lands at the open'));
    expect(m.note, closedOrdersNote);
    expect(m.line, contains('last trade 3:58 pm'));
  });

  test('a pending rumor gets the rumor banner, which opens it', () {
    final m = model(
      detail(
        badges: ['RUMOR_PENDING'],
        events: [
          {
            'id': '44444444-0000-4000-8000-000000000003',
            'subject': {
              'id': '11111111-0000-4000-8000-000000000002',
              'ticker': r'$JAKE',
              'displayName': 'Jake',
              'avatarUrl': null,
            },
            'status': 'RUMOR',
            'teaser': 'Unconfirmed: something.',
            'headline': null,
            'impactFinal': null,
            'category': null,
            'createdAt': '2026-10-24T10:37:00Z',
          },
        ],
      ),
    );
    expect(m.banner?.tone, AuraBannerTone.rumor);
    expect(m.bannerEventId, '44444444-0000-4000-8000-000000000003');
    expect(m.events.single.subtitle, 'Unconfirmed · 4 min ago');
  });

  test('offline stamps the chip and says trading waits', () {
    final m = model(detail(), offline: true);
    expect(m.status, AuraStatus.delayed);
    expect(m.banner?.tone, AuraBannerTone.offline);
    expect(m.note, offlineNoTrading);
  });

  test('the spec sheet says what has and hasn\'t happened today', () {
    final stats = Map.fromEntries(
      model(detail()).stats.map((s) => MapEntry(s.$1, s.$2)),
    );
    expect(stats[statOpen], notYet);
    expect(stats[statShortInterest], '31%');
    expect(stats[statBorrowFee], '0.6% a day');
  });
}
