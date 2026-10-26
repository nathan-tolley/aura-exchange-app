import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../icons.dart';
import '../surface.dart';
import '../text.dart';
import '../tokens.dart';
import '../tone.dart';

/// A labelled single-line field for the few things the app asks you to type:
/// your email, an exchange's name, a ticker. The label sits above it, a note
/// under it says what's wanted or what's wrong.
///
/// The field is the search field's shape at form height: `raised` (lifted
/// inside sheets), `md` corners, body text. Color is information, so a note
/// about a problem colors only its glyph ([noteTone]); its words stay
/// `inkSecondary`.
class AuraTextField extends StatelessWidget {
  const AuraTextField({
    super.key,
    required this.label,
    this.controller,
    this.placeholder,
    this.prefix,
    this.note,
    this.noteTone = AuraTone.neutral,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
    this.inputFormatters,
    this.focusNode,
    this.minLines = 1,
    this.maxLines = 1,
  });

  /// "Email", "Name", "Ticker". Also what VoiceOver calls the field.
  final String label;
  final TextEditingController? controller;
  final String? placeholder;

  /// Fixed text before the input, in `inkTertiary`: the `$` of a ticker.
  final String? prefix;

  /// Under the field: help ("We'll email you a 6-digit code") or the problem
  /// ("That email address doesn't look right").
  final String? note;

  /// `down` or `warn` adds a glyph in that color before [note].
  final AuraTone noteTone;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;

  /// Shown in full ink and selectable, but not editable: an invite link.
  final bool readOnly;
  final bool autofocus;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;

  /// More than 1 makes a box that grows from [minLines] to [maxLines]: an
  /// event's text.
  final int minLines;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    // Start from the ambient style so the field keeps the app's sans; input
    // text has no tracking, as in the references' <input>.
    final text = DefaultTextStyle.of(context).style
        .merge(AuraType.body)
        .copyWith(
          color: enabled ? AuraColors.ink : AuraColors.inkTertiary,
          letterSpacing: 0,
        );
    final note = this.note;
    final prefix = this.prefix;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        ExcludeSemantics(
          child: auraLiftFootnote(
            Text(
              label,
              style: AuraType.footnote.copyWith(color: AuraColors.inkTertiary),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Semantics(
          label: label,
          hint: note,
          child: Container(
            height: maxLines > 1 ? null : 48,
            padding: maxLines > 1
                ? const EdgeInsets.symmetric(horizontal: 14, vertical: 12)
                : const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AuraSheetScope.raised(context),
              borderRadius: BorderRadius.circular(AuraRadius.md),
            ),
            child: Row(
              children: [
                if (prefix != null)
                  Text(
                    prefix,
                    style: text.copyWith(color: AuraColors.inkTertiary),
                  ),
                Expanded(
                  child: CupertinoTextField.borderless(
                    // Without a decoration, a disabled field paints
                    // Cupertino's own disabled fill over ours.
                    decoration: const BoxDecoration(),
                    controller: controller,
                    focusNode: focusNode,
                    onChanged: onChanged,
                    onSubmitted: onSubmitted,
                    enabled: enabled,
                    readOnly: readOnly,
                    autofocus: autofocus,
                    placeholder: placeholder,
                    placeholderStyle: text.copyWith(
                      color: AuraColors.inkTertiary,
                    ),
                    style: text,
                    cursorColor: AuraColors.ink,
                    padding: EdgeInsets.only(left: prefix == null ? 0 : 1),
                    keyboardType: keyboardType,
                    textInputAction: textInputAction,
                    textCapitalization: textCapitalization,
                    autofillHints: autofillHints,
                    inputFormatters: inputFormatters,
                    keyboardAppearance: Brightness.dark,
                    minLines: minLines,
                    maxLines: maxLines,
                    // Prose gets the keyboard's help; addresses and
                    // tickers don't.
                    autocorrect: maxLines > 1,
                    enableSuggestions: maxLines > 1,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (note != null) ...[
          const SizedBox(height: 8),
          ExcludeSemantics(child: AuraFieldNote(note, tone: noteTone)),
        ],
      ],
    );
  }
}

/// The line under a field: help in `inkTertiary`, or a problem with its
/// glyph in [tone] and its words in `inkSecondary`. `AuraCodeField` uses it
/// too.
class AuraFieldNote extends StatelessWidget {
  const AuraFieldNote(this.text, {super.key, this.tone = AuraTone.neutral});

  final String text;
  final AuraTone tone;

  @override
  Widget build(BuildContext context) {
    final problem = tone != AuraTone.neutral;
    return auraLiftFootnote(
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 6,
        children: [
          if (problem)
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: AuraIcon(
                AuraIcons.alert,
                size: 14,
                color: tone.colorOr(AuraColors.inkSecondary),
              ),
            ),
          Expanded(
            child: Text(
              text,
              // Proportional figures: Inter's tabular hyphen would space
              // out "6-digit".
              style: AuraType.footnote.copyWith(
                color: problem
                    ? AuraColors.inkSecondary
                    : AuraColors.inkTertiary,
                fontFeatures: const [],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
