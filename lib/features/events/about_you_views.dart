import 'package:decimal/decimal.dart';
import 'package:flutter/widgets.dart';

import '../../design/icons.dart';
import '../../design/text.dart';
import '../../design/tokens.dart';
import '../../design/tone.dart';
import '../../design/widgets/aura_avatar.dart';
import '../../design/widgets/aura_hero_card.dart';
import '../../design/widgets/aura_impact_disc.dart';
import '../../design/widgets/aura_nav_card.dart';
import '../../design/widgets/aura_quote_card.dart';
import '../../design/widgets/aura_receipt.dart';
import '../../design/widgets/aura_section_header.dart';
import '../../design/widgets/aura_stat_card.dart';
import '../../design/widgets/aura_status_chip.dart';
import '../shared/top_bar.dart';

/// A row that leads somewhere: a choice, an action, a related story.
@immutable
class RowModel {
  const RowModel({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.trailingTone = AuraTone.neutral,
  });

  final AuraIcons icon;
  final String title;
  final String? subtitle;
  final String? trailing;
  final AuraTone trailingTone;
}

/// The stock an event is about, at the top of its screen (W01, W02).
@immutable
class SubjectModel {
  const SubjectModel({
    required this.initial,
    required this.ticker,
    required this.subtitle,
    this.impact,
    this.impactLabel,
  });

  final String initial;

  /// "$JAKE".
  final String ticker;

  /// "A ruling about you · 2:24 am".
  final String subtitle;
  final int? impact;
  final String? impactLabel;
}

/// The chip at the top right of every "about you" screen.
@immutable
class ChipModel {
  const ChipModel(this.status, [this.label]);

  final AuraStatus status;
  final String? label;
}

/// W01: an unconfirmed report about you. All you can see is the teaser;
/// what you can do is answer it before the ruling.
@immutable
class RumorAboutYouModel {
  const RumorAboutYouModel({
    required this.chip,
    required this.subject,
    required this.teaser,
    required this.explainer,
    required this.stats,
    required this.respondTitle,
    required this.responses,
    required this.footer,
  });

  final ChipModel chip;
  final SubjectModel subject;

  /// The Analyst's teaser, as-is.
  final String teaser;
  final String explainer;

  /// Ruling in, co-signs, receipts.
  final List<(String, String)> stats;
  final String respondTitle;
  final List<RowModel> responses;
  final String footer;
}

/// W02: the ruling on you, landing at the next open.
@immutable
class RulingOnYouModel {
  const RulingOnYouModel({
    required this.chip,
    required this.subject,
    required this.landsLabel,
    required this.indicated,
    required this.movePct,
    required this.from,
    required this.headline,
    required this.note,
    required this.noteSource,
    required this.stats,
    required this.actions,
  });

  final ChipModel chip;
  final SubjectModel subject;

  /// "Lands at the 7:00 am open".
  final String landsLabel;
  final Decimal indicated;
  final Decimal movePct;

  /// "From A$112.40 · indicated, not traded yet".
  final String from;
  final String headline;

  /// The Analyst's note, quoted.
  final String note;
  final String noteSource;

  /// Analyst, co-signs, group vote.
  final List<(String, String)> stats;
  final List<RowModel> actions;
}

/// W03: the SEC charged you; what it took, the evidence, what's next.
@immutable
class SecChargeModel {
  const SecChargeModel({
    required this.caseLine,
    required this.headline,
    required this.heroLabel,
    required this.taken,
    required this.takenNote,
    required this.evidence,
    required this.total,
    required this.actions,
    required this.footer,
  });

  /// "Social Exchange Commission · Case 0007 · 1:21 pm".
  final String caseLine;
  final String headline;
  final String heroLabel;
  final Decimal taken;
  final String takenNote;
  final List<AuraReceiptRow> evidence;
  final AuraReceiptRow total;
  final List<RowModel> actions;
  final String footer;
}

class RumorAboutYouView extends StatelessWidget {
  const RumorAboutYouView({
    super.key,
    required this.model,
    this.onClose,
    this.onRespond,
  });

  final RumorAboutYouModel model;
  final VoidCallback? onClose;
  final ValueChanged<int>? onRespond;

  @override
  Widget build(BuildContext context) {
    final m = model;
    return _AboutYouScaffold(
      chip: m.chip,
      onClose: onClose,
      footer: m.footer,
      footerBottom: 27,
      children: [
        const SizedBox(height: 11),
        _Subject(m.subject),
        const SizedBox(height: 27),
        Text(m.teaser, style: AuraType.headline),
        const SizedBox(height: 9),
        Text(m.explainer, style: _small),
        const SizedBox(height: 23),
        _Stats(m.stats),
        const SizedBox(height: 24),
        AuraSectionHeader(m.respondTitle),
        _Rows(m.responses, onTap: onRespond),
      ],
    );
  }
}

class RulingOnYouView extends StatelessWidget {
  const RulingOnYouView({
    super.key,
    required this.model,
    this.onClose,
    this.onAction,
  });

  final RulingOnYouModel model;
  final VoidCallback? onClose;
  final ValueChanged<int>? onAction;

  @override
  Widget build(BuildContext context) {
    final m = model;
    return _AboutYouScaffold(
      chip: m.chip,
      onClose: onClose,
      children: [
        const SizedBox(height: 12),
        _Subject(m.subject),
        const SizedBox(height: 23),
        AuraHeroCard(
          label: m.landsLabel,
          value: m.indicated,
          approx: true,
          pct: m.movePct,
          note: m.from,
        ),
        const SizedBox(height: 27),
        Text(m.headline, style: AuraType.headline),
        const SizedBox(height: 12),
        AuraQuoteCard(quote: m.note, source: m.noteSource),
        const SizedBox(height: 22),
        _Stats(m.stats),
        const SizedBox(height: 22),
        _Rows(m.actions, onTap: onAction),
      ],
    );
  }
}

class SecChargeView extends StatelessWidget {
  const SecChargeView({
    super.key,
    required this.model,
    this.onClose,
    this.onAction,
  });

  final SecChargeModel model;
  final VoidCallback? onClose;
  final ValueChanged<int>? onAction;

  @override
  Widget build(BuildContext context) {
    final m = model;
    return _AboutYouScaffold(
      chip: const ChipModel(AuraStatus.sec),
      onClose: onClose,
      footer: m.footer,
      footerBottom: 23,
      children: [
        const SizedBox(height: 14),
        auraLiftFootnote(Text(m.caseLine, style: _meta)),
        const SizedBox(height: 8),
        Text(m.headline, style: AuraType.headline),
        const SizedBox(height: 26),
        AuraHeroCard(label: m.heroLabel, value: m.taken, note: m.takenNote),
        const SizedBox(height: 24),
        AuraReceipt(rows: m.evidence, total: m.total),
        const SizedBox(height: 24),
        _Rows(m.actions, onTap: onAction),
      ],
    );
  }
}

const _small = TextStyle(
  fontSize: 13,
  height: 18 / 13,
  color: AuraColors.inkTertiary,
);

/// Metadata lines (who, when, which case) are 12.5 pt.
final _meta = AuraType.footnote.copyWith(color: AuraColors.inkTertiary);

/// Close and the chip, the content in the gutters, and a footnote pinned to
/// the bottom where the tab bar would be.
class _AboutYouScaffold extends StatelessWidget {
  const _AboutYouScaffold({
    required this.chip,
    required this.children,
    this.onClose,
    this.footer,
    this.footerBottom = 30,
  });

  final ChipModel chip;
  final List<Widget> children;
  final VoidCallback? onClose;
  final String? footer;

  /// Measured per screen: 27 in W01, 23 in W03.
  final double footerBottom;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final footer = this.footer;
    return ColoredBox(
      color: AuraColors.bg,
      child: Stack(
        children: [
          ListView(
            padding: EdgeInsets.only(top: top, bottom: 96),
            children: [
              TopBar(
                icon: AuraIcons.close,
                label: 'Close',
                onPressed: onClose,
                status: chip.status,
                statusLabel: chip.label,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: children,
                ),
              ),
            ],
          ),
          if (footer != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: footerBottom,
              child: auraLiftFootnote(
                Text(
                  footer,
                  style: AuraType.footnote.copyWith(
                    height: 17 / 12.5,
                    color: AuraColors.inkTertiary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Subject extends StatelessWidget {
  const _Subject(this.subject);

  final SubjectModel subject;

  @override
  Widget build(BuildContext context) {
    final s = subject;
    return Row(
      spacing: 12,
      children: [
        AuraAvatar(s.initial),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              Text(s.ticker, style: AuraType.title),
              auraLiftFootnote(Text(s.subtitle, style: _meta)),
            ],
          ),
        ),
        if (s.impact case final impact?)
          AuraImpactDisc(delta: impact, label: s.impactLabel ?? ''),
      ],
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats(this.stats);

  final List<(String, String)> stats;

  @override
  Widget build(BuildContext context) => AuraStatGrid(
    columns: 3,
    rowGap: 6,
    children: [
      for (final (label, value) in stats)
        AuraStatCard(label: label, value: value),
    ],
  );
}

class _Rows extends StatelessWidget {
  const _Rows(this.rows, {this.onTap});

  final List<RowModel> rows;
  final ValueChanged<int>? onTap;

  @override
  Widget build(BuildContext context) => AuraNavCard(
    children: [
      for (final (i, row) in rows.indexed)
        AuraNavRow(
          icon: row.icon,
          title: row.title,
          subtitle: row.subtitle,
          trailing: row.trailing,
          trailingTone: row.trailingTone,
          onTap: onTap == null ? null : () => onTap!(i),
        ),
    ],
  );
}
