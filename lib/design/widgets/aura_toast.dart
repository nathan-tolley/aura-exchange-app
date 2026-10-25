import 'package:flutter/widgets.dart';

import '../icons.dart';
import '../text.dart';
import '../tokens.dart';
import 'aura_pressable.dart';

/// A brief confirmation after an action, with one undo or follow-up. It sits
/// above the tab bar and disappears after 4 s, or when its countdown ends;
/// the screen that shows it owns the timing. The unsend window after filing
/// is a toast with "Undo" and the 30-second countdown.
class AuraToast extends StatelessWidget {
  const AuraToast({
    super.key,
    required this.message,
    this.icon,
    this.action,
    this.onAction,
  });

  final String message;
  final AuraIcons? icon;

  /// "Undo", "View".
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      container: true,
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.only(left: 16, right: 6),
        decoration: BoxDecoration(
          color: AuraColors.raised2,
          borderRadius: BorderRadius.circular(AuraRadius.md),
        ),
        child: Row(
          spacing: 10,
          children: [
            if (icon != null) AuraIcon(icon!, size: 18, color: AuraColors.ink),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  height: 19 / 14,
                  color: AuraColors.ink,
                ),
              ),
            ),
            if (action != null)
              Semantics(
                button: true,
                label: action,
                onTap: onAction,
                excludeSemantics: true,
                child: AuraPressable(
                  onTap: onAction,
                  child: Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
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
          ],
        ),
      ),
    );
  }
}
