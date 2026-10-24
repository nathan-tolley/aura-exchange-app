import 'package:flutter/widgets.dart';

import '../../format/change.dart';
import '../tokens.dart';

/// A ruling's final impact score (−30 to +30) as a number, not a badge: the
/// `impact` style in `up` or `down` with a small label under it. Never inside
/// a circle or a fill.
class AuraImpactDisc extends StatelessWidget {
  const AuraImpactDisc({super.key, required this.delta, required this.label});

  final int delta;

  /// Loss, Gain, Lore.
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = switch (delta.sign) {
      > 0 => AuraColors.up,
      < 0 => AuraColors.down,
      _ => AuraColors.inkSecondary,
    };
    return Semantics(
      label: 'Impact ${formatImpact(delta)}, $label',
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(formatImpact(delta), style: AuraType.impact.copyWith(color: color)),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              height: 15 / 12,
              color: AuraColors.inkTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
