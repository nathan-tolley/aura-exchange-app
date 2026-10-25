import 'package:flutter/widgets.dart';

import '../tokens.dart';

/// A listing's face: the member's initial on `raised2` in `inkSecondary`
/// (photos come later). Never colored by trend: an avatar isn't
/// information. Decorative; the ticker beside it names it for VoiceOver.
class AuraAvatar extends StatelessWidget {
  const AuraAvatar(this.initial, {super.key, this.size = 40});

  final String initial;

  /// 36 in rows, 40 in headers.
  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AuraColors.raised2,
          shape: BoxShape.circle,
        ),
        child: Text(
          initial.isEmpty ? '' : initial.characters.first.toUpperCase(),
          style: TextStyle(
            fontSize: (size * 0.4).roundToDouble(),
            height: 1,
            fontWeight: FontWeight.w500,
            color: AuraColors.inkSecondary,
          ),
        ),
      ),
    );
  }
}
