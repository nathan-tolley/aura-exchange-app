import 'package:flutter/widgets.dart';

import '../surface.dart';
import '../tokens.dart';
import '../tone.dart';

/// One line of an [AuraReceipt]: a label and a pre-formatted value.
class AuraReceiptRow {
  const AuraReceiptRow(this.label, this.value, {this.tone = AuraTone.neutral});

  final String label;
  final String value;
  final AuraTone tone;
}

/// A receipt for anything that moved money: fills, liquidations, fines,
/// bankruptcy. Label and value rows on hairlines, then a total. Fees are
/// their own row, never hidden in a total. Every money-moving outcome screen
/// has one.
class AuraReceipt extends StatelessWidget {
  const AuraReceipt({super.key, required this.rows, this.total});

  final List<AuraReceiptRow> rows;
  final AuraReceiptRow? total;

  @override
  Widget build(BuildContext context) {
    final line = BorderSide(color: AuraSheetScope.line(context));
    return Container(
      foregroundDecoration: BoxDecoration(border: Border(top: line)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final row in rows) _Row(row, bottom: line),
          if (total != null) _Row(total!, isTotal: true),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.row, {this.bottom, this.isTotal = false});

  final AuraReceiptRow row;
  final BorderSide? bottom;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    const base = TextStyle(fontSize: 14, height: 19 / 14);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      foregroundDecoration: BoxDecoration(
        border: bottom == null ? null : Border(bottom: bottom!),
      ),
      child: Semantics(
        label: '${row.label}: ${row.value}',
        excludeSemantics: true,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            Expanded(
              child: Text(
                row.label,
                style: base.copyWith(
                  color: isTotal ? AuraColors.ink : AuraColors.inkSecondary,
                  fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            Text(
              row.value,
              textAlign: TextAlign.right,
              style: base.copyWith(
                color: row.tone.colorOr(AuraColors.ink),
                fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
