import 'package:decimal/decimal.dart';
import 'package:flutter/widgets.dart';

import '../../api/generated/export.dart' hide Freshness;
import '../../design/tokens.dart';
import '../../design/widgets/aura_button.dart';
import '../../design/widgets/aura_receipt.dart';
import '../../design/widgets/aura_sheet.dart';
import '../../format/money.dart';
import '../../format/ticker.dart';
import '../../l10n/strings.dart';

/// What a trade or an order came to (SCREENS.md #10): the receipt for
/// anything that moved money, what happens next, and the follow-up. A fill
/// answers "what just happened" with its receipt; a resting order says when
/// it fills and can be canceled any time (PLAN.md → Quality bar).
@immutable
class TradeOutcomeModel {
  const TradeOutcomeModel({
    required this.title,
    required this.rows,
    required this.primary,
    this.body,
    this.total,
    this.secondary,
  });

  /// "Bought 12 $ANNA", "Order placed".
  final String title;
  final String? body;
  final List<AuraReceiptRow> rows;
  final AuraReceiptRow? total;

  /// "Done".
  final String primary;

  /// "Set a stop-loss", "Cancel the order".
  final String? secondary;
}

/// A filled trade's receipt. The fee is its own row; the total is what the
/// server says left or reached your cash.
TradeOutcomeModel filledModel(Trade trade, {required bool canStopLoss}) =>
    TradeOutcomeModel(
      title: filledTitle(
        trade.side,
        Decimal.parse(trade.quantity),
        trade.listing.ticker,
      ),
      rows: [
        AuraReceiptRow(filledShares, trade.quantity),
        AuraReceiptRow(filledPrice, _money(trade.price)),
        AuraReceiptRow(filledFee, _money(trade.fee)),
        AuraReceiptRow(cashAfterLabel, _money(trade.cashAfter)),
      ],
      total: AuraReceiptRow(filledTotal(trade.side), _money(trade.total)),
      primary: done,
      secondary: canStopLoss ? setStopLoss : null,
    );

/// A resting order: when it fills, and the way to cancel it.
TradeOutcomeModel restingModel(Order order) => TradeOutcomeModel(
  title: orderPlacedTitle,
  body: restingBody(
    Decimal.parse(order.triggerPrice),
    formatTicker(order.listing.ticker),
  ),
  rows: [
    AuraReceiptRow(orderTypeLabel, orderTypeWord(order.type)),
    AuraReceiptRow(filledShares, order.quantity),
    AuraReceiptRow(triggerLabel, _money(order.triggerPrice)),
    AuraReceiptRow(reservedLabel, _money(order.reservedCash)),
  ],
  primary: done,
  secondary: cancelOrder,
);

String _money(String s) => formatMoney(Decimal.parse(s));

class TradeOutcomeView extends StatelessWidget {
  const TradeOutcomeView({
    super.key,
    required this.model,
    this.onClose,
    this.onPrimary,
    this.onSecondary,
  });

  final TradeOutcomeModel model;
  final VoidCallback? onClose;
  final VoidCallback? onPrimary;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    final m = model;
    final secondary = m.secondary;
    return AuraSheet(
      title: m.title,
      onClose: onClose,
      children: [
        if (m.body case final body?)
          Text(
            body,
            style: AuraType.body.copyWith(
              height: 22 / 15,
              color: AuraColors.inkSecondary,
              fontFeatures: const [],
            ),
          ),
        AuraReceipt(rows: m.rows, total: m.total),
        AuraButton(
          m.primary,
          variant: AuraButtonVariant.primary,
          block: true,
          onPressed: onPrimary,
        ),
        if (secondary != null)
          AuraButton(
            secondary,
            variant: AuraButtonVariant.ghost,
            size: AuraButtonSize.md,
            block: true,
            onPressed: onSecondary,
          ),
      ],
    );
  }
}
