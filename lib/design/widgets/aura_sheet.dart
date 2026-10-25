import 'package:flutter/widgets.dart';

import '../icons.dart';
import '../surface.dart';
import '../tokens.dart';
import 'aura_icon_button.dart';

/// A bottom sheet's panel for a focused task: the trade ticket, filing an
/// event, voting, statements. A grabber, a title with a close glyph, then the
/// content, which lifts one step ([AuraSheetScope]). One primary action at
/// the bottom: `AuraSlideToConfirm` for money, `AuraButton` otherwise. The
/// screen presents it (medium detent by default, large for filing) and asks
/// "Discard this filing?" before a half-filled sheet is swiped away.
class AuraSheet extends StatelessWidget {
  const AuraSheet({
    super.key,
    required this.children,
    this.title,
    this.onClose,
  });

  final String? title;
  final VoidCallback? onClose;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      scopesRoute: true,
      namesRoute: true,
      label: title,
      explicitChildNodes: true,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        decoration: const BoxDecoration(
          color: AuraColors.raised,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AuraRadius.sheet),
          ),
        ),
        child: AuraSheetScope(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AuraColors.lineStrong,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              if (title != null)
                Row(
                  children: [
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: Text(title!, style: AuraType.title),
                      ),
                    ),
                    AuraIconButton(
                      icon: AuraIcons.close,
                      label: 'Close',
                      small: true,
                      onPressed: onClose,
                    ),
                  ],
                ),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}
