import 'package:decimal/decimal.dart';
import 'package:flutter/widgets.dart';

import '../../design/text.dart';
import '../../design/tokens.dart';
import '../../design/widgets/aura_button.dart';
import '../../design/widgets/aura_hero_card.dart';
import '../../design/widgets/aura_quote_card.dart';
import '../../design/widgets/aura_section_header.dart';
import '../../design/widgets/aura_slide_to_confirm.dart';
import '../../design/widgets/aura_stat_card.dart';
import '../../design/widgets/aura_status_chip.dart';
import '../../l10n/strings.dart';
import '../shared/banner_model.dart';
import '../shared/top_bar.dart';

/// The Chapter 7 offer, at the moment of the loss (W04): where you stand,
/// what filing gives and takes, what the tape will say, and the choice.
@immutable
class BankruptcyModel {
  const BankruptcyModel({
    required this.heroLabel,
    required this.netWorth,
    required this.seasonAbs,
    required this.seasonPct,
    required this.banner,
    required this.sectionTitle,
    required this.youGet,
    required this.youGiveUp,
    required this.badgeLabel,
    required this.badge,
    required this.tapeLabel,
    required this.tape,
    required this.tapeSource,
    required this.slide,
    required this.keepGoing,
  });

  final String heroLabel;
  final Decimal netWorth;
  final Decimal seasonAbs;
  final Decimal seasonPct;
  final BannerModel banner;
  final String sectionTitle;

  /// "A$2,000.00".
  final String youGet;

  /// "A$64.12 + 1 position".
  final String youGiveUp;
  final String badgeLabel;

  /// "Chapter 7".
  final String badge;
  final String tapeLabel;

  /// The tape's line, quoted.
  final String tape;
  final String tapeSource;
  final String slide;
  final String keepGoing;
}

class BankruptcyView extends StatelessWidget {
  const BankruptcyView({
    super.key,
    required this.model,
    this.onBack,
    this.onFile,
    this.onKeepGoing,
  });

  final BankruptcyModel model;
  final VoidCallback? onBack;
  final VoidCallback? onFile;
  final VoidCallback? onKeepGoing;

  @override
  Widget build(BuildContext context) {
    final m = model;
    final top = MediaQuery.paddingOf(context).top;
    return ColoredBox(
      color: AuraColors.bg,
      child: Stack(
        children: [
          ListView(
            padding: EdgeInsets.only(top: top, bottom: 160),
            children: [
              TopBar(onPressed: onBack, status: AuraStatus.open),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 15),
                    AuraHeroCard(
                      label: m.heroLabel,
                      value: m.netWorth,
                      abs: m.seasonAbs,
                      pct: m.seasonPct,
                      period: 'this season',
                    ),
                    const SizedBox(height: 23),
                    ModelBanner(m.banner),
                    const SizedBox(height: 20),
                    AuraSectionHeader(m.sectionTitle),
                    AuraStatGrid(
                      rowGap: 6,
                      children: [
                        AuraStatCard(label: youGet, value: m.youGet),
                        AuraStatCard(label: youGiveUp, value: m.youGiveUp),
                        AuraStatCard(
                          label: m.badgeLabel,
                          value: m.badge,
                          wide: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
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
          Positioned(
            left: 16,
            right: 16,
            bottom: 30,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 10,
              children: [
                AuraSlideToConfirm(
                  label: m.slide,
                  down: true,
                  onConfirmed: onFile,
                ),
                AuraButton(
                  m.keepGoing,
                  variant: AuraButtonVariant.ghost,
                  size: AuraButtonSize.md,
                  block: true,
                  onPressed: onKeepGoing,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
