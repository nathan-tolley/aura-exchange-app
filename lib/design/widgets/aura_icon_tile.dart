import 'package:flutter/widgets.dart';

import '../icons.dart';
import '../surface.dart';
import '../tokens.dart';
import '../tone.dart';

/// A glyph on a `raised` rounded square (`md` radius): what heads an empty
/// state (44 pt) or a full-screen failure (52 pt, W13). Decorative: the
/// title next to it says what it means.
class AuraIconTile extends StatelessWidget {
  const AuraIconTile(
    this.icon, {
    super.key,
    this.size = 44,
    this.tone = AuraTone.neutral,
  });

  final AuraIcons icon;

  /// 44 for empty states, 52 for a screen that is itself the message.
  final double size;

  /// The glyph's color: `inkSecondary` unless the tile carries risk (`warn`).
  final AuraTone tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AuraSheetScope.raised(context),
        borderRadius: BorderRadius.circular(AuraRadius.md),
      ),
      alignment: Alignment.center,
      child: AuraIcon(
        icon,
        size: size >= 52 ? 26 : 24,
        color: tone.colorOr(AuraColors.inkSecondary),
      ),
    );
  }
}
