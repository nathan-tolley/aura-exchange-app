import 'package:flutter/widgets.dart';

import '../../design/icons.dart';
import '../../design/widgets/aura_icon_button.dart';
import '../../design/widgets/aura_status_chip.dart';

/// A full screen's top row: back (or close) on the left, at most one status
/// chip on the right (DESIGN.md → Layout). Full width: it keeps its own
/// gutters, so the button's 44 pt hit area reaches 10 pt into the left one
/// and its glyph sits on the edge.
class TopBar extends StatelessWidget {
  const TopBar({
    super.key,
    this.icon = AuraIcons.back,
    this.label = 'Back',
    this.onPressed,
    this.status,
    this.statusLabel,
  });

  /// [AuraIcons.back], or [AuraIcons.close] for an outcome screen.
  final AuraIcons icon;
  final String label;
  final VoidCallback? onPressed;
  final AuraStatus? status;

  /// "Halted · news pending".
  final String? statusLabel;

  @override
  Widget build(BuildContext context) {
    final status = this.status;
    return Padding(
      padding: const EdgeInsets.only(left: 6, right: 16),
      child: Row(
        children: [
          AuraIconButton(icon: icon, label: label, onPressed: onPressed),
          const Spacer(),
          if (status != null)
            // The references set the chip 3 pt below the row's centre, so
            // its words line up with the glyph (W04, W05, W07, W08, W10).
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: AuraStatusChip(status, label: statusLabel),
            ),
        ],
      ),
    );
  }
}
