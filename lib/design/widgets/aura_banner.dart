import 'package:flutter/widgets.dart';

import '../icons.dart';
import '../surface.dart';
import '../text.dart';
import '../tokens.dart';
import 'aura_pressable.dart';

enum AuraBannerTone {
  /// Closed, queued.
  neutral(AuraIcons.clock, AuraColors.inkSecondary),

  /// No connection; prices are stamped "as of".
  offline(AuraIcons.wifiOff, AuraColors.warn),

  /// Margin, halts, extended hours.
  warn(AuraIcons.alert, AuraColors.warn),

  /// Rejected, liquidated, SEC.
  down(AuraIcons.alert, AuraColors.down),

  /// Insider notices: no color of its own.
  rumor(AuraIcons.bolt, AuraColors.inkSecondary);

  const AuraBannerTone(this.icon, this.color);

  final AuraIcons icon;

  /// The glyph's color; the only colored part of a banner.
  final Color color;

  /// Only the most severe banner shows: down > warn > offline > neutral.
  int get severity => switch (this) {
    AuraBannerTone.down => 4,
    AuraBannerTone.warn => 3,
    AuraBannerTone.offline => 2,
    AuraBannerTone.neutral || AuraBannerTone.rumor => 1,
  };
}

/// The one filled shape a screen usually gets: what's true right now and
/// what to do about it, on `raised` with only the glyph in color. Title is
/// what's true; body is when it changes or the exact numbers; the action is
/// the one fix. One banner per screen; the most severe wins.
class AuraBanner extends StatelessWidget {
  const AuraBanner({
    super.key,
    required this.title,
    this.tone = AuraBannerTone.neutral,
    this.body,
    this.action,
    this.onAction,
    this.icon,
  });

  final String title;
  final AuraBannerTone tone;
  final String? body;

  /// The one fix: "Retry", "Cover", "Buy 18".
  final String? action;
  final VoidCallback? onAction;

  /// Replaces the tone's glyph.
  final AuraIcons? icon;

  @override
  Widget build(BuildContext context) {
    final urgent = tone == AuraBannerTone.down || tone == AuraBannerTone.warn;
    return Semantics(
      liveRegion: urgent,
      container: true,
      child: Container(
        // The text starts 11 pt down and ends 13 pt up, as in the reference.
        padding: const EdgeInsets.fromLTRB(14, 11, 14, 12),
        decoration: BoxDecoration(
          color: AuraSheetScope.raised(context),
          borderRadius: BorderRadius.circular(AuraRadius.md),
        ),
        // The icon and text start at the top; the action sits in the middle
        // of the banner's height (W05, W11).
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: AuraIcon(
                    icon ?? tone.icon,
                    size: 18,
                    color: tone.color,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 19 / 14,
                          fontWeight: FontWeight.w600,
                          color: AuraColors.ink,
                        ),
                      ),
                      if (body != null)
                        Text(
                          body!,
                          style: const TextStyle(
                            fontSize: 13,
                            height: 18 / 13,
                            color: AuraColors.inkSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (action != null)
                Align(
                  child: Semantics(
                    button: true,
                    label: action,
                    onTap: onAction,
                    excludeSemantics: true,
                    child: AuraPressable(
                      onTap: onAction,
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 36),
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        alignment: Alignment.center,
                        child: Text(
                          action!,
                          style: auraControlText(
                            const TextStyle(
                              fontSize: 14,
                              height: 19 / 14,
                              fontWeight: FontWeight.w600,
                              color: AuraColors.ink,
                            ),
                          ),
                        ),
                      ),
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
