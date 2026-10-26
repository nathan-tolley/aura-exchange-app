import 'package:decimal/decimal.dart';
import 'package:flutter/widgets.dart';

import '../../design/tokens.dart';
import '../../design/widgets/aura_money.dart';
import '../../design/widgets/aura_price_change.dart';
import '../../design/widgets/aura_status_chip.dart';
import '../shared/top_bar.dart';

/// The top of a stock page (W10, and behind the trade sheet in W05 and
/// W06): back, the market or halt status, the ticker line and the price.
/// Full width: it keeps its own gutters (see [TopBar]).
class StockHeader extends StatelessWidget {
  const StockHeader({
    super.key,
    required this.status,
    this.statusLabel,
    required this.line,
    required this.price,
    this.approx = false,
    this.changeAbs,
    this.changePct,
    this.changePeriod,
    this.onBack,
  });

  final AuraStatus status;

  /// "Halted · news pending".
  final String? statusLabel;

  /// "$ANNA · Anna", "$MIA · Mia · last trade 4:51 pm".
  final String line;
  final Decimal price;

  /// An indicated price that hasn't traded yet (the opening gap): "≈".
  final bool approx;

  /// The day's move under the price (W07): `↑ +10.40 (+10.21%) today`.
  final Decimal? changeAbs;
  final Decimal? changePct;
  final String? changePeriod;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TopBar(onPressed: onBack, status: status, statusLabel: statusLabel),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 11),
              Text(
                line,
                style: const TextStyle(
                  fontSize: 13,
                  height: 16 / 13,
                  color: AuraColors.inkTertiary,
                ),
              ),
              const SizedBox(height: 5),
              AuraMoney(price, size: AuraMoneySize.display, approx: approx),
              if (changeAbs != null || changePct != null) ...[
                const SizedBox(height: 6),
                AuraPriceChange(
                  abs: changeAbs,
                  pct: changePct,
                  period: changePeriod,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
