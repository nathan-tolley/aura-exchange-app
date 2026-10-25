import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../text.dart';
import '../tokens.dart';
import 'aura_pressable.dart';

/// Mutually exclusive views in one track: chart ranges (always 1D, 1W, 1M,
/// SZN, ALL in that order) and order types. The selected option sits on
/// `raised2`. Two to five options; more than five becomes `AuraTabs` or a menu.
class AuraSegmentedControl extends StatelessWidget {
  const AuraSegmentedControl({
    super.key,
    required this.options,
    required this.value,
    required this.label,
    this.onChanged,
  });

  final List<String> options;
  final String value;

  /// Names the group for VoiceOver ("Chart range").
  final String label;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    assert(options.length >= 2 && options.length <= 5, '2 to 5 options');
    return Semantics(
      container: true,
      label: label,
      child: SizedBox(
        height: 36,
        child: Row(
          children: [
            for (final option in options)
              Expanded(
                child: Semantics(
                  button: true,
                  selected: option == value,
                  inMutuallyExclusiveGroup: true,
                  child: AuraPressable(
                    onTap: onChanged == null || option == value
                        ? null
                        : () {
                            HapticFeedback.lightImpact();
                            onChanged!(option);
                          },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: option == value ? AuraColors.raised2 : null,
                        borderRadius: BorderRadius.circular(AuraRadius.sm),
                      ),
                      child: Text(
                        option,
                        maxLines: 1,
                        style: auraControlText(
                          TextStyle(
                            fontSize: 13,
                            height: 16 / 13,
                            fontWeight: FontWeight.w500,
                            color: option == value
                                ? AuraColors.ink
                                : AuraColors.inkTertiary,
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
    );
  }
}
