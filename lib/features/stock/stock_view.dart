import 'package:flutter/widgets.dart';

import '../../design/icons.dart';
import '../../design/tokens.dart';
import '../../design/widgets/aura_button.dart';
import '../../design/widgets/aura_chart.dart';
import '../../design/widgets/aura_empty_state.dart';
import '../../design/widgets/aura_nav_card.dart';
import '../../design/widgets/aura_news_row.dart';
import '../../design/widgets/aura_quote_card.dart';
import '../../design/widgets/aura_range_bar.dart';
import '../../design/widgets/aura_section_header.dart';
import '../../design/widgets/aura_segmented_control.dart';
import '../../design/widgets/aura_skeleton.dart';
import '../../design/widgets/aura_stat_card.dart';
import '../../design/widgets/aura_tabs.dart';
import '../../l10n/strings.dart';
import '../shared/action_bar.dart';
import '../shared/banner_model.dart';
import 'stock_header.dart';
import 'stock_model.dart';

/// The stock page (SCREENS.md #7) and its overview (#8). Laid out like the
/// drawn stock pages (W07, W10): back and the market's chip, the ticker
/// line, the price and today's move, the one banner, then the chart with
/// its ranges, the sections, and Sell / Buy where the tab bar would float.
class StockPageView extends StatelessWidget {
  const StockPageView({
    super.key,
    required this.model,
    this.onBack,
    this.onBannerAction,
    this.onRange,
    this.onTab,
    this.onEvent,
    this.onFile,
    this.onTrade,
  });

  final StockPageModel model;
  final VoidCallback? onBack;

  /// Retry when offline, Read it on a pending rumor.
  final VoidCallback? onBannerAction;
  final ValueChanged<String>? onRange;
  final ValueChanged<StockTab>? onTab;
  final ValueChanged<String>? onEvent;
  final VoidCallback? onFile;

  /// Null while trading is off (offline); the note says why.
  final ValueChanged<StockAction>? onTrade;

  @override
  Widget build(BuildContext context) {
    final m = model;
    final top = MediaQuery.paddingOf(context).top;
    final bar = m.actions.isNotEmpty;
    return ColoredBox(
      color: AuraColors.bg,
      child: Stack(
        children: [
          ListView(
            padding: EdgeInsets.only(top: top, bottom: bar ? 160 : 96),
            children: [
              StockHeader(
                status: m.status,
                statusLabel: m.statusLabel,
                line: m.line,
                price: m.price,
                approx: m.approx,
                changeAbs: m.changeAbs,
                changePct: m.changePct,
                changePeriod: m.changePeriod,
                onBack: onBack,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (m.banner case final banner?) ...[
                      const SizedBox(height: 23),
                      ModelBanner(banner, onAction: onBannerAction),
                    ],
                    const SizedBox(height: 16),
                    if (m.chart case final chart?)
                      AuraChart(
                        points: chart.points,
                        previousClose: chart.previousClose,
                        markers: chart.markers,
                      )
                    else
                      const AuraSkeleton(height: 180),
                    const SizedBox(height: 12),
                    AuraSegmentedControl(
                      options: chartRanges,
                      value: m.range,
                      label: chartRange,
                      onChanged: onRange,
                    ),
                    const SizedBox(height: 24),
                    AuraTabs(
                      items: stockTabs,
                      value: stockTabs[m.tab.index],
                      label: 'Sections',
                      onChanged: onTab == null
                          ? null
                          : (t) =>
                                onTab!(StockTab.values[stockTabs.indexOf(t)]),
                    ),
                    const SizedBox(height: 16),
                    ...switch (m.tab) {
                      StockTab.overview => _overview(m),
                      StockTab.tape => _tape(m),
                      StockTab.analyst => _analyst(m),
                    },
                  ],
                ),
              ),
            ],
          ),
          if (bar)
            ActionBar(
              actions: [
                for (final a in m.actions)
                  AuraButton(
                    a.label,
                    variant: a.primary
                        ? AuraButtonVariant.buy
                        : AuraButtonVariant.secondary,
                    block: true,
                    onPressed: onTrade == null ? null : () => onTrade!(a),
                  ),
              ],
              note: m.note,
              backed: true,
            )
          else if (m.note case final note?)
            ActionBar(actions: const [], note: note, backed: true),
        ],
      ),
    );
  }

  List<Widget> _overview(StockPageModel m) => [
    AuraStatGrid(
      rowGap: 6,
      children: [
        for (final (label, value) in m.stats)
          AuraStatCard(label: label, value: value),
      ],
    ),
    const SizedBox(height: 20),
    AuraRangeBar(low: m.rangeLow, high: m.rangeHigh, current: m.price),
    const SizedBox(height: 24),
    const AuraSectionHeader(eventsHeading),
    if (m.events.isEmpty)
      Padding(
        padding: const EdgeInsets.only(top: 16),
        child: AuraEmptyState(
          icon: AuraIcons.file,
          title: noEventsYet,
          body: noEventsYetBody(m.name),
          action: fileAnEvent,
          onAction: onFile,
        ),
      )
    else
      AuraNavCard(
        children: [
          for (final e in m.events)
            AuraNavRow(
              icon: AuraIcons.gavel,
              title: e.title,
              subtitle: e.subtitle,
              trailing: e.trailing,
              trailingTone: e.trailingTone,
              onTap: onEvent == null ? null : () => onEvent!(e.id),
            ),
        ],
      ),
  ];

  List<Widget> _tape(StockPageModel m) {
    final tape = m.tape;
    if (tape == null) {
      return [
        for (var i = 0; i < 3; i++)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: AuraSkeleton(height: 44),
          ),
      ];
    }
    if (tape.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: AuraEmptyState(
            title: nothingOnTapeYet,
            body: nothingOnTapeBody(m.ticker),
          ),
        ),
      ];
    }
    return [
      for (final t in tape)
        AuraNewsRow(
          source: t.source,
          headline: t.headline,
          movePct: t.movePct,
          onTap: t.eventId == null || onEvent == null
              ? null
              : () => onEvent!(t.eventId!),
        ),
    ];
  }

  List<Widget> _analyst(StockPageModel m) {
    final analyst = m.analyst;
    if (analyst == null) {
      return [
        const Padding(
          padding: EdgeInsets.only(top: 16),
          child: AuraEmptyState(
            icon: AuraIcons.chat,
            title: noAnalystNote,
            body: noAnalystNoteBody,
          ),
        ),
      ];
    }
    final (quote, source) = analyst;
    return [AuraQuoteCard(quote: quote, source: source)];
  }
}
