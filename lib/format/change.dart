import 'package:decimal/decimal.dart';

import 'money.dart';

/// Which way a number moved. Color, arrow and sign all come from this.
enum Trend {
  up,
  down,
  flat;

  static Trend of(Decimal value) => switch (value.sign) {
    > 0 => Trend.up,
    < 0 => Trend.down,
    _ => Trend.flat,
  };
}

/// `+7.79`, `−10.50`, `0.00`, `+2,486.20`. Two decimals, real minus sign.
String formatSigned(Decimal value) {
  final amount = formatAmount(value);
  return switch (Trend.of(value.round(scale: 2))) {
    Trend.up => '+$amount',
    Trend.down => amount,
    Trend.flat => amount.replaceFirst(minus, ''),
  };
}

/// A percentage in percent units, as the API sends it (`"6.70"` is 6.70%):
/// `+6.70%`, `−9.34%`, `0.00%`. With [signed] false: `6.70%`.
String formatPercent(Decimal pct, {bool signed = true}) =>
    signed ? '${formatSigned(pct)}%' : '${formatAmount(pct.abs())}%';

/// The one way to show direction (AuraPriceChange): arrow, sign and amount.
///
/// `↑ +7.79 (+6.70%) today`, `↓ −10.50 (−9.34%)`, `↑ +3.10%`, `0.00%`.
/// The trend follows [pct] when given, else [abs]. Zero has no arrow.
String formatChange({Decimal? abs, Decimal? pct, String? period}) {
  assert(abs != null || pct != null, 'Give abs, pct or both');
  final parts = [
    if (abs != null) formatSigned(abs),
    if (pct != null) abs != null ? '(${formatPercent(pct)})' : formatPercent(pct),
  ];
  final arrow = switch (Trend.of((pct ?? abs)!.round(scale: 2))) {
    Trend.up => '↑ ',
    Trend.down => '↓ ',
    Trend.flat => '',
  };
  return '$arrow${parts.join(' ')}${period == null ? '' : ' $period'}';
}

/// What VoiceOver reads for a change: the direction as a word, never the
/// arrow. `Up 7.79 (6.70%) today`, `Down 2.40%`, `Unchanged 0.00%`.
String changeLabel({Decimal? abs, Decimal? pct, String? period}) {
  assert(abs != null || pct != null, 'Give abs, pct or both');
  final word = switch (Trend.of((pct ?? abs)!.round(scale: 2))) {
    Trend.up => 'Up',
    Trend.down => 'Down',
    Trend.flat => 'Unchanged',
  };
  final parts = [
    if (abs != null) formatAmount(abs.abs()),
    if (pct != null)
      abs != null
          ? '(${formatPercent(pct, signed: false)})'
          : formatPercent(pct, signed: false),
  ];
  return '$word ${parts.join(' ')}${period == null ? '' : ' $period'}';
}

/// A ruling's impact score, a signed integer from −30 to +30: `−18`, `+22`, `0`.
String formatImpact(int delta) => switch (delta.sign) {
  > 0 => '+$delta',
  < 0 => '$minus${delta.abs()}',
  _ => '0',
};

/// The tape's terminal style: a filled triangle and the unsigned percent,
/// `▲ 6.70%`, `▼ 9.34%`, `0.00%`. Nothing else uses triangles.
String formatTapeChange(Decimal pct) => switch (Trend.of(pct.round(scale: 2))) {
  Trend.up => '▲ ${formatPercent(pct, signed: false)}',
  Trend.down => '▼ ${formatPercent(pct, signed: false)}',
  Trend.flat => formatPercent(pct, signed: false),
};
