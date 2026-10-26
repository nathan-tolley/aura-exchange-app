import 'package:flutter/cupertino.dart';

import '../icons.dart';
import '../surface.dart';
import '../tokens.dart';

/// The search field at the top of Home and Market. Searches people, tickers
/// and headlines; results group in that order.
class AuraSearchField extends StatelessWidget {
  const AuraSearchField({
    super.key,
    this.placeholder = 'Search friends or tickers…',
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
  });

  final String placeholder;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    // Start from the ambient text style so the field keeps the app's sans
    // (CupertinoTextField would otherwise merge onto the Cupertino theme's).
    // Input text has no tracking, as in the reference's <input>.
    final text = DefaultTextStyle.of(context).style
        .merge(AuraType.body)
        .copyWith(color: AuraColors.ink, letterSpacing: 0);
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AuraSheetScope.raised(context),
        borderRadius: BorderRadius.circular(AuraRadius.md),
      ),
      child: Row(
        spacing: 8,
        children: [
          const AuraIcon(
            AuraIcons.search,
            size: 16,
            color: AuraColors.inkTertiary,
          ),
          Expanded(
            child: CupertinoTextField.borderless(
              // Without a decoration, a disabled field paints
              // Cupertino's own disabled fill over ours.
              decoration: const BoxDecoration(),
              controller: controller,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              enabled: enabled,
              placeholder: placeholder,
              placeholderStyle: text.copyWith(color: AuraColors.inkTertiary),
              style: text,
              cursorColor: AuraColors.ink,
              padding: const EdgeInsets.only(left: 2),
              textInputAction: TextInputAction.search,
              keyboardAppearance: Brightness.dark,
              autocorrect: false,
            ),
          ),
        ],
      ),
    );
  }
}
