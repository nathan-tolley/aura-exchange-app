import 'package:flutter/widgets.dart';

import '../../format/countdown.dart';
import '../tokens.dart';

/// One countdown for everything with a clock: quotes (15 s), rumors (10 min),
/// unsend (30 s), halts and votes (30 min), the open. The digits are mono so
/// the label doesn't jitter. At zero the screen replaces it with the result;
/// never leave it at 0:00.
class AuraCountdown extends StatelessWidget {
  const AuraCountdown({
    super.key,
    required this.time,
    this.label,
    this.warn = false,
  });

  /// Time left; shown as `m:ss`, or `h:mm:ss` from an hour.
  final Duration time;

  /// "Ruling in", "Quote expires".
  final String? label;

  /// Digits in `warn` when time or money is at risk.
  final bool warn;

  @override
  Widget build(BuildContext context) {
    final digits = formatCountdown(time);
    return Semantics(
      label: [?label, digits].join(' '),
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 6,
        children: [
          if (label != null)
            Text(
              label!,
              style: const TextStyle(
                fontSize: 13,
                height: 16 / 13,
                color: AuraColors.inkSecondary,
              ),
            ),
          Text(
            digits,
            style: AuraType.countdown.copyWith(
              color: warn ? AuraColors.warn : AuraColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}
