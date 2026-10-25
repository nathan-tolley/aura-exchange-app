import 'package:flutter/widgets.dart';

import '../icons.dart';
import '../surface.dart';
import '../text.dart';
import '../tokens.dart';
import '../tone.dart';
import 'aura_pressable.dart';

/// A list of [AuraNavRow]s: hairlines between rows, no container. A single
/// row works too (Closing bell recap). Rows are actions or destinations,
/// never settings toggles.
class AuraNavCard extends StatelessWidget {
  const AuraNavCard({super.key, required this.children});

  final List<AuraNavRow> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      foregroundDecoration: BoxDecoration(
        border: Border(top: BorderSide(color: AuraSheetScope.line(context))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

/// A tappable row: a bare glyph, title, subtitle, an optional trailing note
/// and a small arrow. Subtitles say the consequence: "Hides the story · price
/// hit stays".
class AuraNavRow extends StatelessWidget {
  const AuraNavRow({
    super.key,
    required this.title,
    this.icon,
    this.subtitle,
    this.trailing,
    this.trailingTone = AuraTone.neutral,
    this.onTap,
  });

  final AuraIcons? icon;
  final String title;
  final String? subtitle;

  /// "2 of 3 left", "Risky".
  final String? trailing;
  final AuraTone trailingTone;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: [title, ?subtitle, ?trailing].join(', '),
      onTap: onTap,
      excludeSemantics: true,
      child: AuraPressable(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          foregroundDecoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AuraSheetScope.line(context)),
            ),
          ),
          child: Row(
            spacing: 14,
            children: [
              if (icon != null)
                SizedBox.square(
                  dimension: 20,
                  child: Center(
                    child: AuraIcon(
                      icon!,
                      size: 18,
                      color: AuraColors.inkSecondary,
                    ),
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  spacing: 1,
                  children: [
                    Text(
                      title,
                      style: auraControlText(
                        AuraType.body.copyWith(fontWeight: FontWeight.w500),
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: auraControlText(
                          AuraType.footnote.copyWith(
                            color: AuraColors.inkTertiary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (trailing != null)
                Text(
                  trailing!,
                  style: auraControlText(
                    TextStyle(
                      fontSize: 13,
                      height: 16 / 13,
                      color: trailingTone.colorOr(AuraColors.inkTertiary),
                    ),
                  ),
                ),
              const AuraIcon(
                AuraIcons.arrow,
                size: 14,
                color: AuraColors.inkFaint,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
