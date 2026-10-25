import 'package:flutter/widgets.dart';

import '../tokens.dart';
import '../tone.dart';

/// One or two words of context after a name in a row, as quiet text after a
/// middle dot: "Anna · Holding". Never a pill, never a number. One per row;
/// the strongest wins: SEC > Halted > Rumor > Short > Holding. Only `down`
/// (SEC) and `warn` (Halted, Indicated, Ruled) color it; neutral tags
/// (Holding, Short, Rumor, You) are `inkTertiary`.
class AuraTag extends StatelessWidget {
  const AuraTag(this.text, {super.key, this.tone = AuraTone.neutral});

  final String text;
  final AuraTone tone;

  @override
  Widget build(BuildContext context) {
    assert(tone != AuraTone.up, 'Tags are never up-colored');
    final color = tone.colorOr(AuraColors.inkTertiary);
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
