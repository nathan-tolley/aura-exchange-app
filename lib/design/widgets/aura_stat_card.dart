import 'package:flutter/widgets.dart';

import '../surface.dart';
import '../tokens.dart';
import '../tone.dart';

/// One line of a spec sheet: a label over a value, with a hairline above and
/// no box. Lay them out in an [AuraStatGrid] so the hairlines line up into a
/// table. Use `AuraRangeBar` for a low and a high, `AuraReceipt` for anything
/// that moved money.
class AuraStatCard extends StatelessWidget {
  const AuraStatCard({
    super.key,
    required this.label,
    this.value,
    this.valueChild,
    this.tone = AuraTone.neutral,
    this.trailing,
    this.trailingTone = AuraTone.neutral,
    this.wide = false,
    this.child,
  }) : assert(value != null || valueChild != null, 'Give value or valueChild');

  final String label;
  final String? value;

  /// A composed value instead of text (money, "low / high").
  final Widget? valueChild;

  /// Colors the value: only for direction or risk.
  final AuraTone tone;

  /// Small text at the right of the label: "Hard to borrow", "min 125%".
  final String? trailing;
  final AuraTone trailingTone;

  /// Span every column of the grid.
  final bool wide;

  /// Anything under the value (the range bar's track).
  final Widget? child;

  static const _small = TextStyle(fontSize: 12.5, height: 16 / 12.5);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 2),
      foregroundDecoration: BoxDecoration(
        border: Border(top: BorderSide(color: AuraSheetScope.line(context))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 3,
        children: [
          Row(
            spacing: 8,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: _small.copyWith(color: AuraColors.inkTertiary),
                ),
              ),
              if (trailing != null)
                Text(
                  trailing!,
                  style: _small.copyWith(
                    color: trailingTone.colorOr(AuraColors.inkTertiary),
                  ),
                ),
            ],
          ),
          valueChild ??
              Text(
                value!,
                style: AuraType.value.copyWith(
                  color: tone.colorOr(AuraColors.ink),
                ),
              ),
          ?child,
        ],
      ),
    );
  }
}

/// Stat cards in a 2- or 3-column grid with 10 pt gaps; a `wide` card takes
/// a whole row.
class AuraStatGrid extends StatelessWidget {
  const AuraStatGrid({super.key, required this.children, this.columns = 2});

  final List<AuraStatCard> children;
  final int columns;

  static const gap = 10.0;

  @override
  Widget build(BuildContext context) {
    final rows = <List<AuraStatCard>>[];
    for (final card in children) {
      if (card.wide ||
          rows.isEmpty ||
          rows.last.length == columns ||
          rows.last.first.wide) {
        rows.add([card]);
      } else {
        rows.last.add(card);
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: gap,
      children: [
        for (final row in rows)
          row.first.wide
              ? row.first
              : IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: gap,
                    children: [
                      for (var i = 0; i < columns; i++)
                        Expanded(
                          child: i < row.length ? row[i] : const SizedBox(),
                        ),
                    ],
                  ),
                ),
      ],
    );
  }
}
