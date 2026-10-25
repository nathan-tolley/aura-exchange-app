import 'package:decimal/decimal.dart';

/// The real minus sign. Negative numbers never use a hyphen (DESIGN.md → Numbers).
const minus = '−';

/// The currency mark on every Aura Bucks amount.
const currency = r'A$';

/// An A$ amount split for display: on big numbers the `A$` and the cents
/// (with their dot) step back to `inkTertiary`.
///
/// `−A$1,271.43` → sign `−`, whole `1,271`, cents `.43`.
class MoneyParts {
  const MoneyParts({
    required this.sign,
    required this.whole,
    required this.cents,
  });

  /// `''` or [minus].
  final String sign;

  /// The whole Aura Bucks with thousands separators, e.g. `12,486`.
  final String whole;

  /// The dot and two decimals, e.g. `.20`.
  final String cents;

  @override
  String toString() => '$sign$currency$whole$cents';
}

/// Splits [value] into sign, whole and cents, at exactly two decimals
/// (half-up, like the server). Never rounds to whole Aura Bucks.
MoneyParts moneyParts(Decimal value) {
  final fixed = value.abs().round(scale: 2).toStringAsFixed(2);
  final dot = fixed.indexOf('.');
  final rounded = Decimal.parse(fixed);
  return MoneyParts(
    sign: value.sign < 0 && rounded != Decimal.zero ? minus : '',
    whole: _group(fixed.substring(0, dot)),
    cents: fixed.substring(dot),
  );
}

/// `A$12,486.20`, `−A$888.00`.
String formatMoney(Decimal value) => moneyParts(value).toString();

/// An amount without the currency mark: `2,486.20`, `−9,935.88`.
String formatAmount(Decimal value) {
  final p = moneyParts(value);
  return '${p.sign}${p.whole}${p.cents}';
}

/// A share count, up to four decimals with trailing zeros dropped:
/// `20`, `12.5`, `1,200`, `0.0125`.
String formatQuantity(Decimal value) {
  var fixed = value.abs().round(scale: 4).toStringAsFixed(4);
  fixed = fixed.replaceFirst(RegExp(r'\.?0+$'), '');
  final dot = fixed.indexOf('.');
  final whole = dot < 0 ? fixed : fixed.substring(0, dot);
  final fraction = dot < 0 ? '' : fixed.substring(dot);
  final sign = value.sign < 0 && fixed != '0' ? minus : '';
  return '$sign${_group(whole)}$fraction';
}

String _group(String digits) {
  final out = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) out.write(',');
    out.write(digits[i]);
  }
  return out.toString();
}
