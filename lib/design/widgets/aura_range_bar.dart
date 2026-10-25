import 'package:decimal/decimal.dart';
import 'package:flutter/widgets.dart';

import '../../format/money.dart';
import '../tokens.dart';
import '../tone.dart';
import 'aura_money.dart';
import 'aura_stat_card.dart';

/// Where a price sits between a low and a high: the season range on a stock
/// page, entry to liquidation on a margin warning. Position, not color, says
/// where the price is.
class AuraRangeBar extends StatelessWidget {
  const AuraRangeBar({
    super.key,
    required this.low,
    required this.high,
    required this.current,
    this.label = 'Season range',
    this.note,
    this.noteTone = AuraTone.up,
  });

  final Decimal low;
  final Decimal high;
  final Decimal current;
  final String label;

  /// "Near high", "4.2% away".
  final String? note;
  final AuraTone noteTone;

  /// How far [current] is from [low] to [high], from 0 to 1.
  double get fraction {
    if (high <= low) return 0;
    return ((current - low) / (high - low)).toDouble().clamp(0, 1);
  }

  @override
  Widget build(BuildContext context) {
    final f = fraction;
    return AuraStatCard(
      label: label,
      trailing: note,
      trailingTone: noteTone,
      wide: true,
      // 22 pt: in the reference the smaller " / " stretches the value's line.
      valueChild: SizedBox(
        height: 22,
        child: Row(
          children: [
            AuraMoney(low),
            const Text(
              ' / ',
              style: TextStyle(fontSize: 13, color: AuraColors.inkTertiary),
            ),
            AuraMoney(high),
          ],
        ),
      ),
      child: Semantics(
        label:
            'Current ${formatMoney(current)}, ${(f * 100).round()}% of the way '
            'from low to high',
        excludeSemantics: true,
        child: Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 6),
          child: SizedBox(
            height: 2,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final x = constraints.maxWidth * f;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AuraColors.lineStrong,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      width: x,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AuraColors.inkTertiary,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                    Positioned(
                      left: x - 4,
                      top: -3,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AuraColors.ink,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
