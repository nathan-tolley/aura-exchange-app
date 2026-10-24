import 'package:flutter/widgets.dart';

import '../icons.dart';
import '../tokens.dart';
import 'aura_pressable.dart';

/// A bare glyph button for headers: back, close, alerts, the watchlist star,
/// notifications. No circle and no fill, just the icon in `ink` with a 44 pt
/// hit area. At most three per header: one left, two right.
class AuraIconButton extends StatelessWidget {
  const AuraIconButton({
    super.key,
    required this.icon,
    required this.label,
    this.onPressed,
    this.badge = false,
    this.filled = false,
    this.small = false,
  });

  final AuraIcons icon;

  /// The VoiceOver name. Required: a glyph alone says nothing.
  final String label;
  final VoidCallback? onPressed;

  /// A small `down` dot; put the count in [label].
  final bool badge;

  /// The filled variant (a starred stock).
  final bool filled;

  /// An inline `inkTertiary` glyph in a 32 pt box (the hero's eye button).
  final bool small;

  @override
  Widget build(BuildContext context) {
    final box = small ? 32.0 : AuraSize.hit;
    return Semantics(
      button: true,
      label: label,
      // excludeSemantics drops the child's tap action, so restate it here.
      onTap: onPressed,
      excludeSemantics: true,
      child: AuraPressable(
        onTap: onPressed,
        child: SizedBox.square(
          dimension: box,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AuraIcon(
                icon,
                size: small ? 16 : 20,
                filled: filled,
                color: small ? AuraColors.inkTertiary : AuraColors.ink,
              ),
              if (badge)
                Positioned(
                  top: 7,
                  right: 7,
                  child: Container(
                    width: 11,
                    height: 11,
                    decoration: BoxDecoration(
                      color: AuraColors.down,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AuraColors.bg, width: 2),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
