import 'package:flutter/widgets.dart';

import '../tokens.dart';

/// The shared status vocabulary. The API's status enums use the same words
/// (docs/aura/API-CONTRACT.md → One status vocabulary). Never invent a new
/// word for an existing state.
enum AuraStatus {
  open(_Tone.up, 'Market open', dot: true),
  pre(_Tone.warn, 'Pre-market', dot: true),
  after(_Tone.warn, 'After hours', dot: true),
  closed(_Tone.neutral, 'Closed', dot: true),
  halted(_Tone.warn, 'Halted', dot: true),
  delayed(_Tone.warn, 'Delayed', dot: true),
  rumor(_Tone.neutral, 'Unconfirmed'),
  ruled(_Tone.neutral, 'Ruled'),
  voided(_Tone.neutral, 'Voided'),
  sending(_Tone.neutral, 'Sending'),
  filled(_Tone.up, 'Filled'),
  resting(_Tone.neutral, 'Resting'),
  canceled(_Tone.neutral, 'Canceled'),
  liquidated(_Tone.down, 'Liquidated'),
  sec(_Tone.down, 'SEC charge'),
  beat(_Tone.up, 'Beat'),
  miss(_Tone.down, 'Miss');

  const AuraStatus(this._tone, this.word, {this.dot = false});

  final _Tone _tone;

  /// The word the chip shows when no label is given.
  final String word;

  /// Market states carry a dot; object states are just the word.
  final bool dot;

  Color get color => switch (_tone) {
    _Tone.up => AuraColors.up,
    _Tone.warn => AuraColors.warn,
    _Tone.down => AuraColors.down,
    _Tone.neutral => AuraColors.inkSecondary,
  };
}

enum _Tone { up, warn, down, neutral }

/// A small dot and a word, no pill. Only `open`, `filled`, `beat` (up),
/// `halted`, `delayed`, `pre`, `after` (warn) and `liquidated`, `sec`,
/// `miss` (down) take color.
class AuraStatusChip extends StatelessWidget {
  const AuraStatusChip(this.status, {super.key, this.label, this.glass = false});

  final AuraStatus status;

  /// Replaces the word with detail: "Closed · opens 7:00 am".
  final String? label;

  /// The quieter `inkTertiary` variant from the web reference (`glass`), for a
  /// chip that sits over other content rather than in a header.
  final bool glass;

  @override
  Widget build(BuildContext context) {
    final color = glass ? AuraColors.inkTertiary : status.color;
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: [
        if (status.dot)
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        Text(
          label ?? status.word,
          style: AuraType.footnote.copyWith(
            fontWeight: FontWeight.w500,
            color: color,
          ),
          maxLines: 1,
          softWrap: false,
        ),
      ],
    );
  }
}
