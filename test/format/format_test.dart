import 'package:aura_exchange/format/change.dart';
import 'package:aura_exchange/format/countdown.dart';
import 'package:aura_exchange/format/money.dart';
import 'package:aura_exchange/format/ticker.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

/// Examples from design/DESIGN.md → Numbers and the drawn screens (W01–W13).
void main() {
  Decimal d(String s) => Decimal.parse(s);

  group('money', () {
    test('A\$ with two decimals and thousands separators', () {
      expect(formatMoney(d('12486.20')), r'A$12,486.20');
      expect(formatMoney(d('124.10')), r'A$124.10');
      expect(formatMoney(d('10000')), r'A$10,000.00');
      expect(formatMoney(d('64.12')), r'A$64.12');
      expect(formatMoney(d('1653.57')), r'A$1,653.57');
      expect(formatMoney(d('124100000')), r'A$124,100,000.00');
    });

    test('negatives put the real minus sign before A\$', () {
      expect(formatMoney(d('-888.00')), '−A\$888.00');
      expect(formatMoney(d('-7086')), '−A\$7,086.00');
      expect(formatMoney(d('-35.43')), isNot(contains('-')));
    });

    test('splits whole and cents so the cents can step back', () {
      final parts = moneyParts(d('12486.20'));
      expect(parts.sign, '');
      expect(parts.whole, '12,486');
      expect(parts.cents, '.20');
      expect(moneyParts(d('-1271.43')).sign, minus);
    });

    test('rounds half-up at two decimals, never to whole A\$', () {
      expect(formatMoney(d('0.005')), r'A$0.01');
      expect(formatMoney(d('99.999')), r'A$100.00');
      expect(formatMoney(d('-0.001')), r'A$0.00');
    });

    test('quantities show up to four decimals', () {
      expect(formatQuantity(d('20')), '20');
      expect(formatQuantity(d('12.5')), '12.5');
      expect(formatQuantity(d('0.0125')), '0.0125');
      expect(formatQuantity(d('1200')), '1,200');
      expect(formatQuantity(d('-60')), '−60');
    });
  });

  group('change', () {
    test('arrow, sign and amount with the percent in parentheses', () {
      expect(
        formatChange(abs: d('7.79'), pct: d('6.70'), period: 'today'),
        '↑ +7.79 (+6.70%) today',
      );
      expect(formatChange(abs: d('-10.50'), pct: d('-9.34')), '↓ −10.50 (−9.34%)');
      expect(
        formatChange(abs: d('2486.20'), pct: d('24.86'), period: 'this season'),
        '↑ +2,486.20 (+24.86%) this season',
      );
      expect(
        formatChange(abs: d('-9935.88'), pct: d('-99.36'), period: 'this season'),
        '↓ −9,935.88 (−99.36%) this season',
      );
    });

    test('percent only', () {
      expect(formatChange(pct: d('3.10')), '↑ +3.10%');
      expect(formatChange(pct: d('-2.40')), '↓ −2.40%');
      expect(formatChange(pct: d('-12.20')), '↓ −12.20%');
    });

    test('zero has no arrow and no sign', () {
      expect(formatChange(pct: d('0')), '0.00%');
      expect(formatChange(pct: d('-0.001')), '0.00%');
    });

    test('screen readers hear a word, never the arrow', () {
      expect(
        changeLabel(abs: d('7.79'), pct: d('6.70'), period: 'today'),
        'Up 7.79 (6.70%) today',
      );
      expect(changeLabel(pct: d('-2.40')), 'Down 2.40%');
      expect(changeLabel(pct: d('0.00')), 'Unchanged 0.00%');
    });

    test('impact scores are signed integers', () {
      expect(formatImpact(-18), '−18');
      expect(formatImpact(22), '+22');
      expect(formatImpact(0), '0');
    });

    test('the tape uses triangles and unsigned percents', () {
      expect(formatTapeChange(d('6.70')), '▲ 6.70%');
      expect(formatTapeChange(d('-9.34')), '▼ 9.34%');
      expect(formatTapeChange(d('0.00')), '0.00%');
    });

    test('no hyphen ever stands in for a minus', () {
      final outputs = [
        formatSigned(d('-1')),
        formatPercent(d('-12.19')),
        formatChange(abs: d('-4.74'), pct: d('-4.90')),
        formatImpact(-8),
      ];
      for (final s in outputs) {
        expect(s, isNot(contains('-')), reason: s);
      }
    });
  });

  test('tickers are \$ plus uppercase', () {
    expect(formatTicker(r'$ANNA'), r'$ANNA');
    expect(formatTicker('jake'), r'$JAKE');
  });

  test('countdowns are m:ss, or h:mm:ss from an hour', () {
    expect(formatCountdown(const Duration(minutes: 6, seconds: 42)), '6:42');
    expect(formatCountdown(const Duration(seconds: 9)), '0:09');
    expect(formatCountdown(const Duration(minutes: 24, seconds: 10)), '24:10');
    expect(
      formatCountdown(const Duration(hours: 4, minutes: 18, seconds: 2)),
      '4:18:02',
    );
    expect(formatCountdown(const Duration(seconds: -3)), '0:00');
  });
}
