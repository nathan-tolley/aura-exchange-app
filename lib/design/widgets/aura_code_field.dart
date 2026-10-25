import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../surface.dart';
import '../tokens.dart';
import '../tone.dart';
import 'aura_text_field.dart';

/// The 6-digit sign-in code: one cell per digit, each a big light number
/// like every number in the app, with the next empty cell marked. Typing,
/// pasting and iOS's one-time-code autofill all go into one hidden field;
/// [onCompleted] fires when the sixth digit lands.
///
/// A [note] under it says where the code went or what was wrong with it,
/// with the glyph in [noteTone] (`AuraFieldNote`).
class AuraCodeField extends StatelessWidget {
  const AuraCodeField({
    super.key,
    required this.controller,
    this.length = 6,
    this.onChanged,
    this.onCompleted,
    this.note,
    this.noteTone = AuraTone.neutral,
    this.enabled = true,
    this.autofocus = false,
    this.focusNode,
  });

  final TextEditingController controller;
  final int length;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;
  final String? note;
  final AuraTone noteTone;
  final bool enabled;
  final bool autofocus;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final note = this.note;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          label: 'Sign-in code, $length digits',
          hint: note,
          child: SizedBox(
            height: 56,
            child: Stack(
              children: [
                ValueListenableBuilder(
                  valueListenable: controller,
                  builder: (context, value, _) => _Cells(
                    digits: value.text,
                    length: length,
                    enabled: enabled,
                  ),
                ),
                // The real input, invisible over the cells: it takes taps,
                // the keyboard, paste and autofill.
                Positioned.fill(
                  child: CupertinoTextField.borderless(
                    // Without a decoration, a disabled field paints
                    // Cupertino's own disabled fill over ours.
                    decoration: const BoxDecoration(),
                    controller: controller,
                    focusNode: focusNode,
                    enabled: enabled,
                    autofocus: autofocus,
                    keyboardType: TextInputType.number,
                    keyboardAppearance: Brightness.dark,
                    autofillHints: const [AutofillHints.oneTimeCode],
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(length),
                    ],
                    style: const TextStyle(
                      color: Color(0x00000000),
                      fontSize: 1,
                    ),
                    cursorColor: const Color(0x00000000),
                    cursorWidth: 0,
                    showCursor: false,
                    enableInteractiveSelection: false,
                    autocorrect: false,
                    enableSuggestions: false,
                    onChanged: (text) {
                      onChanged?.call(text);
                      if (text.length == length) onCompleted?.call(text);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        if (note != null) ...[
          const SizedBox(height: 10),
          ExcludeSemantics(child: AuraFieldNote(note, tone: noteTone)),
        ],
      ],
    );
  }
}

class _Cells extends StatelessWidget {
  const _Cells({
    required this.digits,
    required this.length,
    required this.enabled,
  });

  final String digits;
  final int length;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final fill = AuraSheetScope.raised(context);
    return Row(
      spacing: 8,
      children: [
        for (var i = 0; i < length; i++)
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: fill,
                borderRadius: BorderRadius.circular(AuraRadius.md),
              ),
              alignment: Alignment.center,
              child: i < digits.length
                  ? Text(
                      digits[i],
                      style: AuraType.price.copyWith(
                        color: enabled
                            ? AuraColors.ink
                            : AuraColors.inkTertiary,
                      ),
                    )
                  // The next digit goes here: a short ink bar, as a caret.
                  : i == digits.length && enabled
                  ? Container(width: 2, height: 24, color: AuraColors.ink)
                  : null,
            ),
          ),
      ],
    );
  }
}
