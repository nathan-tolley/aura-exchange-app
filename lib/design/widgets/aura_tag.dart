import 'package:flutter/widgets.dart';

import '../tokens.dart';

enum AuraTagTone {
  /// `inkTertiary`: Holding, Short, Rumor, You.
  neutral,

  /// SEC.
  down,

  /// Halted, Indicated, Ruled.
  warn,
}

/// One or two words of context after a name in a row, as quiet text after a
/// middle dot: "Anna · Holding". Never a pill, never a number. One per row;
/// the strongest wins: SEC > Halted > Rumor > Short > Holding.
class AuraTag extends StatelessWidget {
  const AuraTag(this.text, {super.key, this.tone = AuraTagTone.neutral});

  final String text;
  final AuraTagTone tone;

  @override
  Widget build(BuildContext context) {
    final color = switch (tone) {
      AuraTagTone.neutral => AuraColors.inkTertiary,
      AuraTagTone.down => AuraColors.down,
      AuraTagTone.warn => AuraColors.warn,
    };
    return Text.rich(
      TextSpan(
        children: [
          const TextSpan(text: '·'),
          // 6 pt between the dot and the word, as in the reference.
          const WidgetSpan(child: SizedBox(width: 6)),
          TextSpan(text: text),
        ],
      ),
      style: AuraType.footnote.copyWith(color: color),
      maxLines: 1,
      softWrap: false,
      semanticsLabel: text,
    );
  }
}
