import 'package:decimal/decimal.dart';
import 'package:flutter/widgets.dart';

import '../../format/money.dart';
import '../tokens.dart';

enum AuraMoneySize {
  /// Net worth, a landing price, a fine: one per screen.
  display,

  /// The price in a stock header.
  price,

  /// Rows and receipts (the default).
  row,

  /// Small inline amounts.
  sm,
}

/// Every amount of Aura Bucks: `A$`, the whole part in the current text
/// color, the cents in `inkTertiary`. On `display` and `price` the `A$`
/// steps back too. Never rounded to whole A$, never colored by direction:
/// direction belongs to the `AuraPriceChange` next to it.
class AuraMoney extends StatelessWidget {
  const AuraMoney(
    this.value, {
    super.key,
    this.size = AuraMoneySize.row,
    this.approx = false,
    this.color,
  });

  final Decimal value;
  final AuraMoneySize size;

  /// Adds "≈" for indicated prices that haven't traded yet.
  final bool approx;

  /// The whole part's color; defaults to `ink`.
  final Color? color;

  static TextStyle styleFor(AuraMoneySize size) => switch (size) {
    AuraMoneySize.display => AuraType.display,
    AuraMoneySize.price => AuraType.price,
    AuraMoneySize.row => _row,
    AuraMoneySize.sm => _row.copyWith(fontSize: 13, height: 20 / 13),
  };

  static final _row = AuraType.body.copyWith(fontWeight: FontWeight.w500);

  @override
  Widget build(BuildContext context) {
    final parts = moneyParts(value);
    final style = styleFor(size).copyWith(color: color ?? AuraColors.ink);
    final big = size == AuraMoneySize.display || size == AuraMoneySize.price;
    const quiet = TextStyle(color: AuraColors.inkTertiary);
    // The style goes on Text.rich, which merges it with the default text style
    // (and its sans family); spans only change color and tracking.
    return Text.rich(
      style: style,
      TextSpan(
        children: [
          if (approx) const TextSpan(text: '≈ '),
          if (parts.sign.isNotEmpty) TextSpan(text: parts.sign),
          TextSpan(
            style: big ? quiet : null,
            children: [
              const TextSpan(text: 'A'),
              // The web reference sets 1 px after the currency mark.
              TextSpan(
                text: r'$',
                style: TextStyle(letterSpacing: (style.letterSpacing ?? 0) + 1),
              ),
            ],
          ),
          TextSpan(text: parts.whole),
          TextSpan(text: parts.cents, style: quiet),
        ],
      ),
      maxLines: 1,
      softWrap: false,
      semanticsLabel: '${approx ? 'About ' : ''}$parts',
    );
  }
}
