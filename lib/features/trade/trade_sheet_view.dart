import 'package:decimal/decimal.dart';
import 'package:flutter/widgets.dart';

import '../../design/tokens.dart';
import '../../design/widgets/aura_banner.dart';
import '../../design/widgets/aura_button.dart';
import '../../design/widgets/aura_countdown.dart';
import '../../design/widgets/aura_receipt.dart';
import '../../design/widgets/aura_segmented_control.dart';
import '../../design/widgets/aura_sheet.dart';
import '../../design/widgets/aura_slide_to_confirm.dart';
import '../../design/widgets/aura_stepper.dart';
import '../../l10n/strings.dart';

/// A banner as the sheet shows it: copy already built, tone chosen.
@immutable
class SheetBanner {
  const SheetBanner({
    required this.tone,
    required this.title,
    this.body,
    this.action,
  });

  final AuraBannerTone tone;
  final String title;
  final String? body;

  /// "Buy 18".
  final String? action;
}

/// The trade ticket (SCREENS.md #9): order type, quantity, the quote as a
/// receipt, why it can't go through (W05), and the button.
@immutable
class TradeTicketModel {
  const TradeTicketModel({
    required this.title,
    required this.orderType,
    required this.quantity,
    required this.quantityNote,
    required this.rows,
    required this.total,
    required this.button,
    required this.canTrade,
    this.banner,
  });

  /// "Buy $ANNA".
  final String title;

  /// One of [orderMarket], [orderLimit], [orderStop].
  final String orderType;
  final Decimal quantity;

  /// "shares at about A$124.10".
  final String quantityNote;
  final List<AuraReceiptRow> rows;
  final AuraReceiptRow total;

  /// "Buy 20 $ANNA".
  final String button;

  /// False when the quote was refused; [banner] says why, right above it.
  final bool canTrade;
  final SheetBanner? banner;
}

class TradeTicketView extends StatelessWidget {
  const TradeTicketView({
    super.key,
    required this.model,
    this.onClose,
    this.onOrderType,
    this.onQuantity,
    this.onBannerAction,
    this.onTrade,
  });

  final TradeTicketModel model;
  final VoidCallback? onClose;
  final ValueChanged<String>? onOrderType;
  final ValueChanged<Decimal>? onQuantity;
  final VoidCallback? onBannerAction;
  final VoidCallback? onTrade;

  @override
  Widget build(BuildContext context) {
    final m = model;
    return AuraSheet(
      title: m.title,
      onClose: onClose,
      children: [
        AuraSegmentedControl(
          options: const [orderMarket, orderLimit, orderStop],
          value: m.orderType,
          label: orderType,
          onChanged: onOrderType,
        ),
        AuraStepper(
          value: m.quantity,
          note: m.quantityNote,
          onChanged: onQuantity ?? (_) {},
        ),
        AuraReceipt(rows: m.rows, total: m.total),
        if (m.banner case final banner?)
          AuraBanner(
            tone: banner.tone,
            title: banner.title,
            body: banner.body,
            action: banner.action,
            onAction: banner.action == null ? null : onBannerAction,
          ),
        AuraButton(
          m.button,
          variant: AuraButtonVariant.buy,
          block: true,
          onPressed: m.canTrade ? onTrade : null,
        ),
      ],
    );
  }
}

/// The requote (W06): the price moved before the slide landed. What moved,
/// the new numbers next to what you saw, how long the new price holds, and
/// the slide again, or a way out.
@immutable
class RequoteModel {
  const RequoteModel({
    required this.title,
    required this.banner,
    required this.rows,
    required this.total,
    required this.holdsFor,
    required this.slide,
    required this.decline,
  });

  /// "Buy 12 $ANNA".
  final String title;
  final SheetBanner banner;
  final List<AuraReceiptRow> rows;
  final AuraReceiptRow total;
  final Duration holdsFor;

  /// "Slide to buy at A$125.36".
  final String slide;

  /// "Don't buy".
  final String decline;
}

class RequoteView extends StatelessWidget {
  const RequoteView({
    super.key,
    required this.model,
    this.onClose,
    this.onConfirmed,
    this.onDecline,
  });

  final RequoteModel model;
  final VoidCallback? onClose;
  final VoidCallback? onConfirmed;
  final VoidCallback? onDecline;

  @override
  Widget build(BuildContext context) {
    final m = model;
    return AuraSheet(
      title: m.title,
      onClose: onClose,
      children: [
        AuraBanner(
          tone: m.banner.tone,
          title: m.banner.title,
          body: m.banner.body,
        ),
        AuraReceipt(rows: m.rows, total: m.total),
        Row(
          spacing: 6,
          children: [
            const Text(
              priceHoldsFor,
              style: TextStyle(
                fontSize: 13,
                height: 16 / 13,
                color: AuraColors.inkSecondary,
              ),
            ),
            AuraCountdown(time: m.holdsFor, warn: true),
          ],
        ),
        AuraSlideToConfirm(label: m.slide, onConfirmed: onConfirmed),
        AuraButton(
          m.decline,
          variant: AuraButtonVariant.ghost,
          size: AuraButtonSize.md,
          block: true,
          onPressed: onDecline,
        ),
      ],
    );
  }
}
