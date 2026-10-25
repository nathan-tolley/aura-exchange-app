import 'package:decimal/decimal.dart';
import 'package:flutter/widgets.dart';

import '../../design/icons.dart';
import '../../design/tokens.dart';
import '../../design/widgets/aura_icon_button.dart';
import '../../design/widgets/aura_money.dart';
import '../../design/widgets/aura_status_chip.dart';

/// The top of a stock page (W10, and behind the trade sheet in W05 and
/// W06): back, the market or halt status, the ticker line and the price.
/// Full width: it keeps its own gutters, so the back button's 44 pt hit area
/// can reach 10 pt into the left one and its glyph sits on the edge
/// (DESIGN.md → Layout).
class StockHeader extends StatelessWidget {
  const StockHeader({
    super.key,
    required this.status,
    this.statusLabel,
    required this.line,
    required this.price,
    this.onBack,
  });

  final AuraStatus status;

  /// "Halted · news pending".
  final String? statusLabel;

  /// "$ANNA · Anna", "$MIA · Mia · last trade 4:51 pm".
  final String line;
  final Decimal price;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 6, right: 16),
          child: Row(
            children: [
              AuraIconButton(
                icon: AuraIcons.back,
                label: 'Back',
                onPressed: onBack,
              ),
              const Spacer(),
              AuraStatusChip(status, label: statusLabel),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(
                line,
                style: const TextStyle(
                  fontSize: 13,
                  height: 16 / 13,
                  color: AuraColors.inkTertiary,
                ),
              ),
              const SizedBox(height: 4),
              AuraMoney(price, size: AuraMoneySize.display),
            ],
          ),
        ),
      ],
    );
  }
}
