import 'package:decimal/decimal.dart';
import 'package:flutter/widgets.dart';

import '../../design/text.dart';
import '../../design/tokens.dart';
import '../../design/tone.dart';
import '../../design/widgets/aura_button.dart';
import '../../design/widgets/aura_range_bar.dart';
import '../../design/widgets/aura_section_header.dart';
import '../../design/widgets/aura_stat_card.dart';
import '../../design/widgets/aura_status_chip.dart';
import '../shared/action_bar.dart';
import '../shared/banner_model.dart';
import 'stock_header.dart';

/// One spec-sheet stat under "Your short".
@immutable
class ShortStat {
  const ShortStat(
    this.label,
    this.value, {
    this.tone = AuraTone.neutral,
    this.trailing,
    this.trailingTone = AuraTone.neutral,
  });

  final String label;
  final String value;
  final AuraTone tone;
  final String? trailing;
  final AuraTone trailingTone;
}

/// A stock page where you hold a short close to liquidation (W07): the
/// warning, how far the price is from your liquidation price, the
/// position's numbers, what liquidation does, and two ways to cover.
@immutable
class ShortPageModel {
  const ShortPageModel({
    required this.line,
    required this.price,
    required this.changeAbs,
    required this.changePct,
    required this.warning,
    required this.sectionTitle,
    required this.rangeLabel,
    required this.entry,
    required this.liquidation,
    required this.rangeNote,
    required this.stats,
    required this.explainer,
    required this.coverPart,
    required this.coverAll,
  });

  final String line;
  final Decimal price;
  final Decimal changeAbs;
  final Decimal changePct;

  /// Null once the collateral is back above the warning line.
  final BannerModel? warning;
  final String sectionTitle;
  final String rangeLabel;
  final Decimal entry;
  final Decimal liquidation;

  /// "4.2% away".
  final String rangeNote;
  final List<ShortStat> stats;
  final String explainer;

  /// "Cover 30", "Cover all 60".
  final String coverPart;
  final String coverAll;
}

class ShortPageView extends StatelessWidget {
  const ShortPageView({
    super.key,
    required this.model,
    this.onBack,
    this.onCoverPart,
    this.onCoverAll,
  });

  final ShortPageModel model;
  final VoidCallback? onBack;
  final VoidCallback? onCoverPart;
  final VoidCallback? onCoverAll;

  @override
  Widget build(BuildContext context) {
    final m = model;
    final top = MediaQuery.paddingOf(context).top;
    return ColoredBox(
      color: AuraColors.bg,
      child: Stack(
        children: [
          ListView(
            padding: EdgeInsets.only(top: top, bottom: 128),
            children: [
              StockHeader(
                status: AuraStatus.open,
                line: m.line,
                price: m.price,
                changeAbs: m.changeAbs,
                changePct: m.changePct,
                changePeriod: 'today',
                onBack: onBack,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (m.warning case final warning?) ...[
                      const SizedBox(height: 23),
                      ModelBanner(warning),
                    ],
                    const SizedBox(height: 20),
                    AuraSectionHeader(m.sectionTitle),
                    AuraRangeBar(
                      label: m.rangeLabel,
                      low: m.entry,
                      high: m.liquidation,
                      current: m.price,
                      note: m.rangeNote,
                      noteTone: AuraTone.warn,
                    ),
                    const SizedBox(height: 7),
                    AuraStatGrid(
                      rowGap: 6,
                      children: [
                        for (final s in m.stats)
                          AuraStatCard(
                            label: s.label,
                            value: s.value,
                            tone: s.tone,
                            trailing: s.trailing,
                            trailingTone: s.trailingTone,
                          ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    auraLiftFootnote(
                      Text(
                        m.explainer,
                        style: AuraType.footnote.copyWith(
                          height: 17 / 12.5,
                          color: AuraColors.inkTertiary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          ActionBar(
            actions: [
              AuraButton(m.coverPart, block: true, onPressed: onCoverPart),
              AuraButton(
                m.coverAll,
                variant: AuraButtonVariant.primary,
                block: true,
                onPressed: onCoverAll,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
