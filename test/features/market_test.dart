import 'package:aura_exchange/api/errors.dart';
import 'package:aura_exchange/api/generated/export.dart' hide Freshness;
import 'package:aura_exchange/data/freshness.dart';
import 'package:aura_exchange/data/live_market.dart';
import 'package:aura_exchange/design/tone.dart';
import 'package:aura_exchange/design/widgets/aura_banner.dart';
import 'package:aura_exchange/design/widgets/aura_status_chip.dart';
import 'package:aura_exchange/features/market/market_model.dart';
import 'package:aura_exchange/format/time.dart';
import 'package:aura_exchange/l10n/strings.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/api_json.dart';

/// The Market tab (SCREENS.md #6).
void main() {
  final zone = exchangeZone('Australia/Sydney');
  final now = DateTime.utc(2026, 10, 24, 10, 41);
  LiveMarket market({String state = 'OPEN', bool halted = false}) =>
      LiveMarket.from(
        Market.fromJson({
          ...marketJson(
            marketState: state,
            listings: [
              listingJson(r'$ANNA', 'Anna', price: '124.10', pct: '6.70'),
              listingJson(
                r'$JAKE',
                'Jake',
                price: '101.90',
                pct: '-9.34',
                state: halted ? 'HALTED' : 'ACTIVE',
              ),
              listingJson(r'$NATE', 'Nathan', mine: true),
            ],
          ),
          'nextChangeAt': '2026-10-24T20:00:00Z',
        }),
      );
  MarketListModel model(
    LiveMarket m, {
    String query = '',
    Liveness liveness = Liveness.live,
  }) => marketListModel(
    market: m,
    liveness: liveness,
    query: query,
    zone: zone,
    now: now,
  );

  test("sorts by today's change, biggest gain first", () {
    final m = model(market());
    expect(m.rows.map((r) => r.ticker), [r'$ANNA', r'$NATE', r'$JAKE']);
    expect(m.heading, allStocks);
    expect(m.status, AuraStatus.open);
    expect(m.banner, isNull);
  });

  test('tags a halted row in warn, and you as You', () {
    final rows = model(market(halted: true)).rows;
    final jake = rows.firstWhere((r) => r.ticker == r'$JAKE');
    expect((jake.tag, jake.tagTone), (tagHalted, AuraTone.warn));
    expect(rows.firstWhere((r) => r.ticker == r'$NATE').tag, tagYou);
  });

  test(r'searches names and tickers, with or without the $', () {
    expect(model(market(), query: 'an').rows.map((r) => r.ticker), [
      r'$ANNA',
      r'$NATE',
    ]);
    expect(model(market(), query: r'$jake').rows.single.ticker, r'$JAKE');
    final none = model(market(), query: 'zz');
    expect(none.rows, isEmpty);
    expect(none.heading, resultsCount(0));
    expect(none.empty?.$1, 'Nobody matches “zz”');
  });

  test('one banner: offline over closed; closed says when it opens', () {
    final closed = model(market(state: 'CLOSED'));
    expect(closed.banner?.title, 'Closed until 7:00 am');
    expect(closed.statusLabel, 'Closed · opens 7:00 am');
    final offline = model(
      market(state: 'CLOSED').withProblem(const ApiError.offline()),
      liveness: Liveness.delayed,
    );
    expect(offline.banner?.tone, AuraBannerTone.offline);
    expect(offline.status, AuraStatus.delayed);
    expect(offline.statusLabel, 'As of 9:41 pm');
  });

  test('the whole exchange halted is a warn banner', () {
    final m = model(market(state: 'HALTED'));
    expect(m.banner?.tone, AuraBannerTone.warn);
    expect(m.status, AuraStatus.halted);
  });
}
