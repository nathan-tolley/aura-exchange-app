import 'package:decimal/decimal.dart';
import 'package:flutter/widgets.dart';

import '../../format/change.dart';
import '../tokens.dart';

enum AuraChangeSize {
  /// In rows.
  sm,

  /// The default, under a hero number.
  md,

  /// In headers.
  lg,
}

/// The only way to show direction: arrow, sign and color together, so it
/// reads without color. `↑ +7.79 (+6.70%) today`. Zero has no arrow and is
/// `inkSecondary`. VoiceOver hears "Up 7.79 (6.70%) today", never the arrow.
class AuraPriceChange extends StatelessWidget {
  const AuraPriceChange({
    super.key,
    this.abs,
    this.pct,
    this.period,
    this.size = AuraChangeSize.md,
  }) : assert(abs != null || pct != null, 'Give abs, pct or both');

  final Decimal? abs;

  /// Percent units, as the API sends them: `6.70` is 6.70%.
  final Decimal? pct;

  /// "today", "this season".
  final String? period;
  final AuraChangeSize size;

  static Color colorFor(Trend trend) => switch (trend) {
    Trend.up => AuraColors.up,
    Trend.down => AuraColors.down,
    Trend.flat => AuraColors.inkSecondary,
  };

  @override
  Widget build(BuildContext context) {
    final trend = Trend.of((pct ?? abs)!.round(scale: 2));
    final (fontSize, lineHeight) = switch (size) {
      AuraChangeSize.sm => (12.0, 16.0),
      AuraChangeSize.md => (13.0, 18.0),
      AuraChangeSize.lg => (15.0, 20.0),
    };
    return Text(
      formatChange(abs: abs, pct: pct, period: period),
      style: TextStyle(
        fontSize: fontSize,
        height: lineHeight / fontSize,
        fontWeight: FontWeight.w500,
        color: colorFor(trend),
      ),
      maxLines: 1,
      softWrap: false,
      semanticsLabel: changeLabel(abs: abs, pct: pct, period: period),
    );
  }
}
