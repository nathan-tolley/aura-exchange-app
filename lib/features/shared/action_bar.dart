import 'package:flutter/widgets.dart';

import '../../design/text.dart';
import '../../design/tokens.dart';

/// The actions at the bottom of a full screen: two large buttons side by
/// side where the tab bar would float (DESIGN.md → Layout), and an optional
/// note under them, such as why they're disabled (W07, W08, W10). Put it in
/// the screen's Stack, over the scrolling content.
class ActionBar extends StatelessWidget {
  const ActionBar({super.key, required this.actions, this.note});

  /// Usually two `AuraButton`s, secondary first.
  final List<Widget> actions;

  /// "Trading resumes when the vote closes."
  final String? note;

  @override
  Widget build(BuildContext context) {
    final note = this.note;
    return Positioned(
      left: 16,
      right: 16,
      // Measured: the buttons end 30 pt above the bottom, or 29 with a note
      // under them (W10).
      bottom: note == null ? 30 : 29,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          Row(
            spacing: 10,
            children: [for (final a in actions) Expanded(child: a)],
          ),
          if (note != null)
            auraLiftFootnote(
              Text(
                note,
                textAlign: TextAlign.center,
                style: AuraType.footnote.copyWith(
                  color: AuraColors.inkTertiary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
