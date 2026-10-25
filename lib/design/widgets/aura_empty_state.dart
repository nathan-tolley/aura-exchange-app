import 'package:flutter/widgets.dart';

import '../icons.dart';
import '../surface.dart';
import '../tokens.dart';
import 'aura_button.dart';

/// What a list says when there's nothing in it: why it's empty and the one
/// action that fills it. In voice, but clear: "No positions yet" / "Your
/// portfolio is all cash. Very conservative."
class AuraEmptyState extends StatelessWidget {
  const AuraEmptyState({
    super.key,
    required this.title,
    this.body,
    this.icon = AuraIcons.tape,
    this.action,
    this.onAction,
  });

  final String title;
  final String? body;
  final AuraIcons icon;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AuraSheetScope.raised(context),
              borderRadius: BorderRadius.circular(AuraRadius.md),
            ),
            alignment: Alignment.center,
            child: AuraIcon(icon, size: 24, color: AuraColors.inkSecondary),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              title,
              textAlign: TextAlign.center,
              // CSS `normal` line height for Inter.
              style: AuraType.title.copyWith(height: 1.21),
            ),
          ),
          if (body != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 280),
                child: Text(
                  body!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 20 / 14,
                    color: AuraColors.inkSecondary,
                  ),
                ),
              ),
            ),
          if (action != null)
            AuraButton(
              action!,
              variant: AuraButtonVariant.primary,
              size: AuraButtonSize.md,
              onPressed: onAction,
            ),
        ],
      ),
    );
  }
}
