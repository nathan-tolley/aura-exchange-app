import 'package:decimal/decimal.dart';
import 'package:flutter/widgets.dart';

import '../../design/icons.dart';
import '../../design/text.dart';
import '../../design/tokens.dart';
import '../../design/widgets/aura_button.dart';
import '../../design/widgets/aura_countdown.dart';
import '../../design/widgets/aura_impact_disc.dart';
import '../../design/widgets/aura_nav_card.dart';
import '../../design/widgets/aura_section_header.dart';
import '../../design/widgets/aura_status_chip.dart';
import '../shared/action_bar.dart';
import 'stock_header.dart';

/// One way to vote on a news halt.
@immutable
class HaltOption {
  const HaltOption({
    required this.choice,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  /// The contract's word: `CONFIRM`, `DECLINE`, `RECONSIDER`.
  final String choice;
  final AuraIcons icon;
  final String title;

  /// The consequence: "The ruling stands at +22".
  final String subtitle;
}

/// A stock page while its stock is halted for a news vote (W10).
@immutable
class HaltedStockModel {
  const HaltedStockModel({
    required this.statusLabel,
    required this.line,
    required this.price,
    required this.voteLabel,
    required this.voteLeft,
    required this.voted,
    required this.headline,
    required this.impact,
    required this.impactLabel,
    required this.explainer,
    required this.voteTitle,
    required this.options,
    required this.footnote,
    required this.sell,
    required this.buy,
    required this.disabledReason,
  });

  /// "Halted · news pending".
  final String statusLabel;

  /// "$MIA · Mia · last trade 4:51 pm".
  final String line;
  final Decimal price;

  /// "Vote closes in".
  final String voteLabel;
  final Duration voteLeft;

  /// "4 of 6 voted".
  final String voted;

  /// The Analyst's headline, as-is.
  final String headline;
  final int impact;

  /// "Gain", "Loss".
  final String impactLabel;

  /// "A ruling this big needs the group's vote. If it's confirmed, $MIA
  /// reopens about 16.2% higher."
  final String explainer;

  /// "Your vote".
  final String voteTitle;
  final List<HaltOption> options;

  /// "Voting pays A$100.00. Nobody sees how you voted."
  final String footnote;
  final String sell;
  final String buy;

  /// Under the disabled Sell and Buy: "Trading resumes when the vote closes."
  final String disabledReason;
}

class HaltedStockView extends StatelessWidget {
  const HaltedStockView({
    super.key,
    required this.model,
    this.onBack,
    this.onVote,
  });

  final HaltedStockModel model;
  final VoidCallback? onBack;
  final ValueChanged<String>? onVote;

  @override
  Widget build(BuildContext context) {
    final m = model;
    final top = MediaQuery.paddingOf(context).top;
    const small = TextStyle(fontSize: 13, height: 17 / 13);
    return ColoredBox(
      color: AuraColors.bg,
      child: Stack(
        children: [
          ListView(
            padding: EdgeInsets.only(top: top, bottom: 160),
            children: [
              StockHeader(
                status: AuraStatus.halted,
                statusLabel: m.statusLabel,
                line: m.line,
                price: m.price,
                onBack: onBack,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 25),
                    Row(
                      children: [
                        AuraCountdown(
                          label: m.voteLabel,
                          time: m.voteLeft,
                          warn: true,
                        ),
                        const Spacer(),
                        Text(
                          m.voted,
                          style: small.copyWith(color: AuraColors.inkTertiary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 16,
                      children: [
                        Expanded(
                          child: Text(m.headline, style: AuraType.headline),
                        ),
                        AuraImpactDisc(delta: m.impact, label: m.impactLabel),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      m.explainer,
                      style: small.copyWith(color: AuraColors.inkTertiary),
                    ),
                    const SizedBox(height: 22),
                    AuraSectionHeader(m.voteTitle),
                    AuraNavCard(
                      children: [
                        for (final option in m.options)
                          AuraNavRow(
                            icon: option.icon,
                            title: option.title,
                            subtitle: option.subtitle,
                            onTap: onVote == null
                                ? null
                                : () => onVote!(option.choice),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    auraLiftFootnote(
                      Text(
                        m.footnote,
                        style: AuraType.footnote.copyWith(
                          color: AuraColors.inkTertiary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // The Sell / Buy bar sits where the tab bar does, disabled with
          // the reason right under it.
          ActionBar(
            actions: [
              AuraButton(m.sell, block: true),
              AuraButton(m.buy, variant: AuraButtonVariant.buy, block: true),
            ],
            note: m.disabledReason,
          ),
        ],
      ),
    );
  }
}
