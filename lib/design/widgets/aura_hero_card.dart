import 'package:decimal/decimal.dart';
import 'package:flutter/widgets.dart';

import '../icons.dart';
import '../surface.dart';
import '../tokens.dart';
import 'aura_icon_button.dart';
import 'aura_money.dart';
import 'aura_pressable.dart';
import 'aura_price_change.dart';

/// The one big number at the top of a screen, sitting directly on the
/// background: label, number, change. No card around it, and one per screen.
/// Home has no action row: a primary "File an event" and a secondary "Trade"
/// button sit under the hero instead. [actions] is for screens that truly
/// need round shortcuts.
class AuraHeroCard extends StatelessWidget {
  const AuraHeroCard({
    super.key,
    required this.label,
    required this.value,
    this.abs,
    this.pct,
    this.period,
    this.note,
    this.approx = false,
    this.hideable = false,
    this.hidden = false,
    this.onToggleHidden,
    this.actions = const [],
  });

  /// "Net worth · Season 1", "Net worth · as of 9:41 pm".
  final String label;
  final Decimal value;
  final Decimal? abs;
  final Decimal? pct;

  /// "this season".
  final String? period;

  /// A quiet line under the change: "From A$112.40".
  final String? note;

  /// An indicated price that hasn't traded yet.
  final bool approx;

  /// Shows the eye button that hides the number.
  final bool hideable;

  /// Whether the number is hidden right now.
  final bool hidden;
  final VoidCallback? onToggleHidden;
  final List<AuraActionButton> actions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 6,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              height: 16 / 13,
              color: AuraColors.inkTertiary,
            ),
          ),
          Row(
            spacing: 4,
            children: [
              if (hidden)
                Text(
                  r'A$••••••',
                  style: AuraType.display.copyWith(
                    color: AuraColors.inkTertiary,
                  ),
                )
              else
                AuraMoney(value, size: AuraMoneySize.display, approx: approx),
              if (hideable)
                AuraIconButton(
                  icon: AuraIcons.eyeOff,
                  label: hidden ? 'Show balance' : 'Hide balance',
                  small: true,
                  onPressed: onToggleHidden,
                ),
            ],
          ),
          if (!hidden && (abs != null || pct != null))
            AuraPriceChange(abs: abs, pct: pct, period: period),
          if (note != null)
            Text(
              note!,
              style: const TextStyle(
                fontSize: 13,
                height: 16 / 13,
                color: AuraColors.inkTertiary,
              ),
            ),
          if (actions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Row(
                spacing: 8,
                children: [for (final a in actions) Expanded(child: a)],
              ),
            ),
        ],
      ),
    );
  }
}

/// A round shortcut under a hero: a glyph on a 52 pt `raised` disc with its
/// label under it. Only for screens that truly need round shortcuts.
class AuraActionButton extends StatelessWidget {
  const AuraActionButton({
    super.key,
    required this.icon,
    required this.label,
    this.onPressed,
  });

  final AuraIcons icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      onTap: onPressed,
      excludeSemantics: true,
      child: AuraPressable(
        onTap: onPressed,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            Container(
              width: AuraSize.action,
              height: AuraSize.action,
              decoration: BoxDecoration(
                color: AuraSheetScope.raised(context),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: AuraIcon(icon, size: 22, color: AuraColors.ink),
            ),
            Text(
              label,
              style: AuraType.footnote.copyWith(
                color: AuraColors.inkSecondary,
                letterSpacing: 0,
                fontFeatures: const [],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
