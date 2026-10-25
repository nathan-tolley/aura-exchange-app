import 'package:flutter/widgets.dart';

import '../icons.dart';
import '../text.dart';
import '../tokens.dart';
import 'aura_pressable.dart';
import 'aura_status_chip.dart';

/// A section title, with an optional status chip and a "View all" link.
/// Titles are one or two words in sentence case: Stats, About, Watchlist,
/// Your moves. Section headings stay small (15 pt), never 20 pt or larger.
class AuraSectionHeader extends StatelessWidget {
  const AuraSectionHeader(
    this.title, {
    super.key,
    this.status,
    this.statusLabel,
    this.action,
    this.onAction,
  });

  final String title;
  final AuraStatus? status;

  /// Detail for the chip: "As of 9:41 pm".
  final String? statusLabel;

  /// Link text: "View all", "Edit".
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: Row(
        children: [
          Expanded(
            child: Row(
              spacing: 10,
              children: [
                Semantics(
                  header: true,
                  child: Text(title, style: AuraType.heading, maxLines: 1),
                ),
                if (status != null)
                  Flexible(child: AuraStatusChip(status!, label: statusLabel)),
              ],
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
                child: SizedBox(
                  height: AuraSize.hit,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 2,
                    children: [
                      Text(
                        action!,
                        style: auraControlText(
                          const TextStyle(
                            fontSize: 13,
                            height: 16 / 13,
                            color: AuraColors.inkTertiary,
                          ),
                        ),
                      ),
                      const AuraIcon(
                        AuraIcons.chevron,
                        size: 12,
                        color: AuraColors.inkTertiary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
