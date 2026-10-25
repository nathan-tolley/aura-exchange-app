import 'package:decimal/decimal.dart';
import 'package:flutter/widgets.dart';

import '../../design/icons.dart';
import '../../design/text.dart';
import '../../design/tokens.dart';
import '../../design/widgets/aura_button.dart';
import '../../design/widgets/aura_hero_card.dart';
import '../../design/widgets/aura_icon_button.dart';
import '../../design/widgets/aura_quote_card.dart';
import '../../design/widgets/aura_receipt.dart';
import '../../design/widgets/aura_status_chip.dart';
import '../shared/action_bar.dart';

/// The liquidation receipt (W08): what happened and why, what came back to
/// your cash, the settlement as a receipt, and the tape line, which never
/// names you.
@immutable
class LiquidatedModel {
  const LiquidatedModel({
    required this.title,
    required this.why,
    required this.heroLabel,
    required this.returned,
    required this.pnl,
    required this.pnlPct,
    required this.period,
    required this.rows,
    required this.total,
    required this.tapeLabel,
    required this.tape,
    required this.tapeSource,
    required this.seeStock,
    required this.portfolio,
  });

  final String title;

  /// "3:12 pm · $JAKE crossed A$117.00 and your collateral fell under 125%".
  final String why;
  final String heroLabel;
  final Decimal returned;
  final Decimal pnl;
  final Decimal pnlPct;

  /// "on the trade".
  final String period;
  final List<AuraReceiptRow> rows;
  final AuraReceiptRow total;
  final String tapeLabel;

  /// The tape's line, from the server as-is.
  final String tape;
  final String tapeSource;
  final String seeStock;
  final String portfolio;
}

class LiquidatedView extends StatelessWidget {
  const LiquidatedView({
    super.key,
    required this.model,
    this.onClose,
    this.onSeeStock,
    this.onPortfolio,
  });

  final LiquidatedModel model;
  final VoidCallback? onClose;
  final VoidCallback? onSeeStock;
  final VoidCallback? onPortfolio;

  @override
  Widget build(BuildContext context) {
    final m = model;
    final top = MediaQuery.paddingOf(context).top;
    const small = TextStyle(fontSize: 13, height: 18 / 13);
    return ColoredBox(
      color: AuraColors.bg,
      child: Stack(
        children: [
          ListView(
            padding: EdgeInsets.only(top: top, bottom: 128),
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 6, right: 16),
                child: Row(
                  children: [
                    AuraIconButton(
                      icon: AuraIcons.close,
                      label: 'Close',
                      onPressed: onClose,
                    ),
                    const Spacer(),
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: AuraStatusChip(AuraStatus.liquidated),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),
                    Text(m.title, style: auraLargeTitle()),
                    const SizedBox(height: 3),
                    Text(
                      m.why,
                      style: small.copyWith(color: AuraColors.inkTertiary),
                    ),
                    const SizedBox(height: 26),
                    AuraHeroCard(
                      label: m.heroLabel,
                      value: m.returned,
                      abs: m.pnl,
                      pct: m.pnlPct,
                      period: m.period,
                    ),
                    const SizedBox(height: 23),
                    AuraReceipt(rows: m.rows, total: m.total),
                    const SizedBox(height: 22),
                    auraLiftFootnote(
                      Text(
                        m.tapeLabel,
                        style: AuraType.footnote.copyWith(
                          color: AuraColors.inkTertiary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    AuraQuoteCard(quote: m.tape, source: m.tapeSource),
                  ],
                ),
              ),
            ],
          ),
          ActionBar(
            actions: [
              AuraButton(m.seeStock, block: true, onPressed: onSeeStock),
              AuraButton(
                m.portfolio,
                variant: AuraButtonVariant.primary,
                block: true,
                onPressed: onPortfolio,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
