import 'package:decimal/decimal.dart';
import 'package:flutter/widgets.dart';

import '../../design/icons.dart';
import '../../design/text.dart';
import '../../design/tokens.dart';
import '../../design/widgets/aura_button.dart';
import '../../design/widgets/aura_hero_card.dart';
import '../../design/widgets/aura_quote_card.dart';
import '../../design/widgets/aura_receipt.dart';
import '../../design/widgets/aura_status_chip.dart';
import '../shared/action_bar.dart';
import '../shared/top_bar.dart';

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

  /// The tape's line, from the server as-is; null while it isn't found,
  /// and then the section isn't shown.
  final String? tape;
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
              TopBar(
                icon: AuraIcons.close,
                label: 'Close',
                onPressed: onClose,
                status: AuraStatus.liquidated,
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
                    if (m.tape case final tape?) ...[
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
                      AuraQuoteCard(quote: tape, source: m.tapeSource),
                    ],
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
