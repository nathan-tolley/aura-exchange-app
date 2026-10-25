import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../surface.dart';
import '../tokens.dart';
import 'aura_pressable.dart';

/// Sections inside one screen: the stock page's Overview, Tape, Holders,
/// Analyst. Up to four, equal width, over a hairline; the selected one is
/// `ink` with an `ink` underline. Tabs switch content in place: they never
/// navigate away or open sheets.
class AuraTabs extends StatelessWidget {
  const AuraTabs({
    super.key,
    required this.items,
    required this.value,
    this.onChanged,
    this.label,
  });

  final List<String> items;
  final String value;
  final ValueChanged<String>? onChanged;

  /// Names the group for VoiceOver.
  final String? label;

  @override
  Widget build(BuildContext context) {
    assert(items.length >= 2 && items.length <= 4, '2 to 4 tabs');
    return Semantics(
      container: true,
      label: label,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AuraSheetScope.line(context)),
          ),
        ),
        child: Row(
          children: [
            for (final item in items)
              Expanded(
                child: Semantics(
                  button: true,
                  selected: item == value,
                  inMutuallyExclusiveGroup: true,
                  child: AuraPressable(
                    onTap: onChanged == null || item == value
                        ? null
                        : () {
                            HapticFeedback.lightImpact();
                            onChanged!(item);
                          },
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Center(
                          child: Text(
                            item,
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 14,
                              height: 18 / 14,
                              fontWeight: FontWeight.w500,
                              color: item == value
                                  ? AuraColors.ink
                                  : AuraColors.inkTertiary,
                            ),
                          ),
                        ),
                        if (item == value)
                          // 1.5 pt, drawn over the hairline as in the reference.
                          const Positioned(
                            left: 0,
                            right: 0,
                            bottom: -1,
                            height: 1.5,
                            child: ColoredBox(color: AuraColors.ink),
                          ),
                      ],
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
