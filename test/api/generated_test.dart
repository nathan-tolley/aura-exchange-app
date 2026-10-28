import 'dart:convert';
import 'dart:io';

import 'package:aura_exchange/api/generated/export.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

/// The generated client decodes the spec's own examples (captured from Prism
/// into test/fixtures/api), and money stays a string until the app parses it
/// as a Decimal. Fails if a regeneration changes the shapes the app reads.
void main() {
  Map<String, Object?> fixture(String name) =>
      jsonDecode(File('test/fixtures/api/$name.json').readAsStringSync())
          as Map<String, Object?>;

  test('Market: freshness, index and listings', () {
    final market = Market.fromJson(fixture('market'));
    expect(market.asOf, DateTime.utc(2026, 10, 24, 13, 21));
    expect(market.marketState, MarketState.pre);
    final anna = market.listings.single;
    expect(anna.ticker, r'$ANNA');
    expect(Decimal.parse(anna.price), Decimal.parse('124.10'));
    expect(anna.state, ListingState.active);
    // An inline LONG/SHORT enum once overwrote the trade Side (see
    // swagger_parser.yaml); both must survive regeneration.
    expect(anna.myPosition?.side, PositionSide.long);
    expect(Side.$valuesDefined.map((s) => s.json), [
      'BUY',
      'SELL',
      'SHORT',
      'COVER',
    ]);
  });

  test('Quote: every amount is a decimal string', () {
    final quote = Quote.fromJson(fixture('quote'));
    expect(quote.side, Side.buy);
    expect(quote.total, '2494.41');
    expect(quote.cashAfter, '-229.91');
    expect(quote.short?.liquidationPrice, '117.00');
    expect(quote.previous?.changePct, '1.02');
  });

  test('Portfolio: cash, net worth and positions', () {
    final portfolio = Portfolio.fromJson(fixture('portfolio'));
    expect(portfolio.netWorth, '12486.20');
    expect(portfolio.positions.first.unrealizedPnl, '-888.00');
    expect(portfolio.nextStimulusAt, DateTime.utc(2026, 10, 26, 13));
  });

  test('Position: how a liquidation settled (draft.7, feeRate)', () {
    final position = Portfolio.fromJson(fixture('portfolio')).positions.first;
    final l = position.liquidation!;
    expect(l.feeRate, '0.50');
    expect(l.collateral, '8745.75');
    expect(l.returned, '1633.36');
  });

  test('Health: minimum build', () {
    final health = Health.fromJson(fixture('health'));
    expect(health.status, HealthStatus.ok);
    expect(health.minBuild, 1);
  });

  test('unknown enum values parse instead of throwing', () {
    final json = fixture('market')..['marketState'] = 'LUNCH';
    expect(Market.fromJson(json).marketState, MarketState.$unknown);
  });
}
