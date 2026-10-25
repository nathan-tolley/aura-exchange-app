import 'package:decimal/decimal.dart';
import 'package:flutter/widgets.dart';

import '../tokens.dart';
import '../tone.dart';
import 'aura_money.dart';

/// The floating price label on a chart point, with an optional badge for the
/// event behind it ("+22 ruling", "−18 ruling", "Rumor"). Shown while a
/// finger is on the chart and on event markers.
class AuraChartTooltip extends StatelessWidget {
  const AuraChartTooltip({
    super.key,
    required this.price,
    this.badge,
    this.tone = AuraTone.neutral,
  });

  final Decimal price;
  final String? badge;

  /// The badge's color: `up`/`down` for rulings, neutral for a rumor.
  final AuraTone tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AuraColors.raised2,
        borderRadius: BorderRadius.circular(AuraRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 6,
        children: [
          AuraMoney(price, size: AuraMoneySize.sm),
          if (badge != null)
            Text(
              badge!,
              style: TextStyle(
                fontSize: 12,
                height: 16 / 12,
                fontWeight: FontWeight.w500,
                color: tone.colorOr(AuraColors.inkSecondary),
              ),
            ),
        ],
      ),
    );
  }
}
