import 'package:decimal/decimal.dart';
import 'package:flutter/widgets.dart';

import '../../design/tokens.dart';
import '../../design/widgets/aura_button.dart';
import '../../design/widgets/aura_countdown.dart';
import '../../design/widgets/aura_receipt.dart';
import '../../design/widgets/aura_segmented_control.dart';
import '../../design/widgets/aura_sheet.dart';
import '../../design/widgets/aura_skeleton.dart';
import '../../design/widgets/aura_slide_to_confirm.dart';
import '../../design/widgets/aura_stepper.dart';
import '../../design/widgets/aura_text_field.dart';
import '../../l10n/strings.dart';
import '../shared/banner_model.dart';

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
    this.orderTypes = const [orderMarket, orderLimit, orderStop],
    this.priceField,
    this.loading = false,
    this.holdsFor,
    this.refreshing,
    this.slide,
    this.slideDown = false,
  });

  /// "Buy $ANNA".
  final String title;

  /// One of [orderTypes].
  final String orderType;

  /// What this trade can be: Stop needs a position to protect, and shorts
  /// and covers are market orders only. One option hides the control.
  final List<String> orderTypes;

  /// A limit or stop's price field: (label, note).
  final (String, String)? priceField;

  /// The quote is on its way: the receipt is a skeleton.
  final bool loading;

  /// How long the quote holds; the countdown turns `warn` near the end.
  final Duration? holdsFor;

  /// "Getting a new price…", once it has run out.
  final String? refreshing;

  /// "Slide to buy 12 $ANNA": anything that moves money ends with the
  /// slide. Without it (a refused quote, W05) the disabled [button] shows.
  final String? slide;

  /// Shorts slide on the `down` knob.
  final bool slideDown;
  final Decimal quantity;

  /// "shares at about A$124.10".
  final String quantityNote;
  final List<AuraReceiptRow> rows;
  final AuraReceiptRow total;

  /// "Buy 20 $ANNA".
  final String button;

  /// False when the quote was refused; [banner] says why, right above it.
  final bool canTrade;
  final BannerModel? banner;
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
    this.price,
    this.onPrice,
  });

  final TradeTicketModel model;
  final VoidCallback? onClose;
  final ValueChanged<String>? onOrderType;
  final ValueChanged<Decimal>? onQuantity;
  final VoidCallback? onBannerAction;

  /// The button, or the slide landing.
  final VoidCallback? onTrade;

  /// Holds a limit or stop's price.
  final TextEditingController? price;
  final ValueChanged<String>? onPrice;

  @override
  Widget build(BuildContext context) {
    final m = model;
    final slide = m.slide;
    return AuraSheet(
      title: m.title,
      onClose: onClose,
      children: [
        if (m.orderTypes.length > 1)
          AuraSegmentedControl(
            options: m.orderTypes,
            value: m.orderType,
            label: orderType,
            onChanged: onOrderType,
          ),
        AuraStepper(
          value: m.quantity,
          note: m.quantityNote,
          onChanged: onQuantity ?? (_) {},
        ),
        if (m.priceField case (final label, final note))
          AuraTextField(
            label: label,
            controller: price,
            prefix: 'A\$',
            note: note,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: onPrice,
          ),
        if (m.loading)
          const AuraSkeleton(height: 120)
        else if (m.rows.isNotEmpty)
          AuraReceipt(rows: m.rows, total: m.total),
        if (m.holdsFor case final left?)
          _Holds(left: left)
        else if (m.refreshing case final text?)
          Text(text, style: _small),
        if (m.banner case final banner?)
          ModelBanner(banner, onAction: onBannerAction),
        if (slide != null && m.canTrade)
          AuraSlideToConfirm(
            label: slide,
            down: m.slideDown,
            onConfirmed: onTrade,
          )
        else
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

const _small = TextStyle(
  fontSize: 13,
  height: 16 / 13,
  color: AuraColors.inkSecondary,
);

/// "This price holds for 0:12", the digits in `warn` for the last five
/// seconds (W06's line).
class _Holds extends StatelessWidget {
  const _Holds({required this.left});

  final Duration left;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 6,
      children: [
        const Text(priceHoldsFor, style: _small),
        AuraCountdown(time: left, warn: left.inSeconds <= 5),
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
  final BannerModel banner;
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
        ModelBanner(m.banner),
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
