import 'dart:ui';

import 'package:flutter/widgets.dart';

import '../icons.dart';
import '../tokens.dart';
import 'aura_pressable.dart';

/// The app's five sections, in tab-bar order.
enum AuraTab {
  home(AuraIcons.home, 'Home'),
  market(AuraIcons.market, 'Market'),
  tape(AuraIcons.tape, 'Tape'),
  portfolio(AuraIcons.portfolio, 'Portfolio'),
  you(AuraIcons.you, 'You');

  const AuraTab(this.icon, this.label);

  final AuraIcons icon;
  final String label;
}

/// The floating tab bar: five glyphs on a blurred capsule with a small dot
/// under the active one. It floats 30 pt above the bottom with content
/// scrolling under its blur, and hides on sheets and while filing. The only
/// floating thing in the app, so the only blur; no shadow.
class AuraTabBar extends StatelessWidget {
  const AuraTabBar({
    super.key,
    required this.active,
    this.tapeBadge = false,
    this.onSelect,
  });

  final AuraTab active;

  /// Unread rulings on the tape.
  final bool tapeBadge;
  final ValueChanged<AuraTab>? onSelect;

  @override
  Widget build(BuildContext context) {
    const shape = StadiumBorder(side: BorderSide(color: AuraColors.lineStrong));
    return ClipPath(
      clipper: const ShapeBorderClipper(shape: shape),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          height: AuraSize.tabbar,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: ShapeDecoration(
            // raised2 at 82%, as on iOS's thin material.
            color: AuraColors.raised2.withValues(alpha: 0.82),
            shape: shape,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 2,
            children: [
              for (final tab in AuraTab.values)
                _TabItem(
                  tab: tab,
                  active: tab == active,
                  badge: tab == AuraTab.tape && tapeBadge,
                  onTap: onSelect == null ? null : () => onSelect!(tab),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.tab,
    required this.active,
    required this.badge,
    this.onTap,
  });

  final AuraTab tab;
  final bool active;
  final bool badge;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: active,
      label: badge ? '${tab.label}, new rulings' : tab.label,
      onTap: onTap,
      excludeSemantics: true,
      child: AuraPressable(
        onTap: onTap,
        child: SizedBox(
          width: 52,
          height: AuraSize.hit,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AuraIcon(
                tab.icon,
                size: 22,
                weight: active ? 2.2 : 1.9,
                color: active ? AuraColors.ink : AuraColors.inkTertiary,
              ),
              if (active)
                Positioned(
                  bottom: 4,
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: AuraColors.ink,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              if (badge)
                Positioned(
                  top: 7,
                  right: 13,
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
