import 'package:flutter/widgets.dart';

import '../icons.dart';
import '../surface.dart';
import '../tokens.dart';
import 'aura_pressable.dart';

enum AuraButtonVariant {
  /// `ink` fill: the one decision a screen is for (File an event, Cover).
  primary,

  /// Same look as primary, for Buy.
  buy,

  /// `raised2`: Sell, Short, Trade.
  secondary,

  /// Outlined: Not now, Don't buy.
  ghost,

  /// `down` outline, for Declare bankruptcy only.
  danger,
}

enum AuraButtonSize {
  /// 54 pt, for the one decision a screen is for.
  lg,

  /// 44 pt, everywhere else.
  md,
}

/// Capsule buttons. Never colored by direction. One `primary`/`buy` per
/// screen; labels are a verb in sentence case. A disabled button (no
/// [onPressed]) always has a line of text saying why right next to it; the
/// screen places it. Anything that moves money ends in `AuraSlideToConfirm`,
/// not a second button.
class AuraButton extends StatelessWidget {
  const AuraButton(
    this.label, {
    super.key,
    this.onPressed,
    this.variant = AuraButtonVariant.secondary,
    this.size = AuraButtonSize.lg,
    this.icon,
    this.block = false,
  });

  final String label;

  /// Null disables the button.
  final VoidCallback? onPressed;
  final AuraButtonVariant variant;
  final AuraButtonSize size;
  final AuraIcons? icon;

  /// Fill the available width.
  final bool block;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final (Color fill, Color ink, Color? outline) = !enabled
        ? (AuraSheetScope.raised(context), AuraColors.inkFaint, null)
        : switch (variant) {
            AuraButtonVariant.primary ||
            AuraButtonVariant.buy => (AuraColors.ink, AuraColors.onInk, null),
            AuraButtonVariant.secondary => (
              AuraColors.raised2,
              AuraColors.ink,
              null,
            ),
            AuraButtonVariant.ghost => (
              const Color(0x00000000),
              AuraColors.ink,
              AuraColors.lineStrong,
            ),
            AuraButtonVariant.danger => (
              const Color(0x00000000),
              AuraColors.down,
              AuraColors.down,
            ),
          };
    final lg = size == AuraButtonSize.lg;
    final text = lg
        ? AuraType.button.copyWith(color: ink)
        : AuraType.body.copyWith(fontWeight: FontWeight.w500, color: ink);

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      onTap: onPressed,
      excludeSemantics: true,
      child: AuraPressable(
        onTap: onPressed,
        child: Container(
          height: lg ? AuraSize.buttonLg : AuraSize.hit,
          width: block ? double.infinity : null,
          padding: EdgeInsets.symmetric(horizontal: lg ? 24 : 18),
          decoration: ShapeDecoration(
            color: fill,
            shape: StadiumBorder(
              side: outline == null
                  ? BorderSide.none
                  : BorderSide(color: outline),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 8,
            children: [
              if (icon != null)
                AuraIcon(icon!, size: 16, weight: 2, color: ink),
              Flexible(
                child: Text(
                  label,
                  style: text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
