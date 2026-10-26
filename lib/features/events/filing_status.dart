import 'package:flutter/widgets.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../api/generated/export.dart' hide Freshness;
import '../../design/icons.dart';
import '../../design/tokens.dart';
import '../../design/widgets/aura_banner.dart';
import '../../design/widgets/aura_countdown.dart';
import '../../design/widgets/aura_impact_disc.dart';
import '../../design/widgets/aura_quote_card.dart';
import '../../design/widgets/aura_receipt.dart';
import '../../design/widgets/aura_status_chip.dart';
import '../../design/widgets/aura_toast.dart';
import '../../format/countdown.dart';
import '../../format/ticker.dart';
import '../../format/time.dart';
import '../../l10n/strings.dart';
import '../shared/banner_model.dart';
import '../shared/top_bar.dart';

/// Your filing's status (SCREENS.md #12), worded: what you wrote, where it
/// is (filed → rumor → ruling), the ruling when it lands, and the unsend
/// window while it's `SENDING`.
@immutable
class FilingStatusModel {
  const FilingStatusModel({
    required this.status,
    required this.title,
    required this.text,
    required this.track,
    this.statusLabel,
    this.banner,
    this.rulingIn,
    this.headline,
    this.impact,
    this.note,
    this.unsendLeft,
  });

  final AuraStatus status;
  final String? statusLabel;

  /// "Your filing about $JAKE".
  final String title;

  /// What you wrote.
  final String text;

  /// Filed, Rumor, Ruling, with when.
  final List<AuraReceiptRow> track;
  final BannerModel? banner;

  /// While it's a rumor: until the Analyst rules.
  final Duration? rulingIn;

  /// The Analyst's headline and impact once ruled.
  final String? headline;
  final int? impact;
  final String? note;

  /// While it's `SENDING`: how long you can still unsend it.
  final Duration? unsendLeft;
}

FilingStatusModel filingStatusModel(
  Event e, {
  required tz.Location zone,
  required DateTime now,
}) {
  String at(DateTime t) => formatMoment(t, zone, now: now);
  final ruling = e.ruling;
  final rumorEnds = e.rumorEndsAt;
  final status = switch (e.status) {
    EventStatus.sending => AuraStatus.sending,
    EventStatus.rumor => AuraStatus.rumor,
    EventStatus.ruled || EventStatus.hidden => AuraStatus.ruled,
    EventStatus.halted => AuraStatus.halted,
    EventStatus.voided || EventStatus.canceled => AuraStatus.voided,
    _ => AuraStatus.rumor,
  };
  final BannerModel? banner = switch (e.status) {
    EventStatus.canceled => const BannerModel(
      tone: AuraBannerTone.neutral,
      title: unsentTitle,
      body: unsentBody,
    ),
    EventStatus.halted => BannerModel(
      tone: AuraBannerTone.warn,
      title: haltedForVoteTitle,
      body: e.halt == null ? null : haltedForVoteBody(at(e.halt!.endsAt)),
    ),
    EventStatus.voided => const BannerModel(
      tone: AuraBannerTone.neutral,
      title: voidedTitle,
      body: voidedBody,
    ),
    EventStatus.review => const BannerModel(
      tone: AuraBannerTone.neutral,
      title: inReviewTitle,
      body: inReviewBody,
    ),
    _ => null,
  };
  return FilingStatusModel(
    status: status,
    statusLabel: e.status == EventStatus.canceled ? unsentTitle : null,
    title: yourFilingAbout(formatTicker(e.subject.ticker)),
    text: e.text ?? e.teaser,
    track: [
      AuraReceiptRow(filedLabel, at(e.createdAt)),
      AuraReceiptRow(
        rumorLabel,
        rumorEnds == null ? waiting : liveUntil(at(rumorEnds)),
      ),
      AuraReceiptRow(
        rulingLabel,
        ruling == null ? waiting : ruledAt(at(ruling.ruledAt)),
      ),
      AuraReceiptRow(coSigns, '${e.reactions.cosigns}'),
    ],
    banner: banner,
    rulingIn: e.status == EventStatus.rumor && rumorEnds != null
        ? rumorEnds.difference(now)
        : null,
    headline: ruling?.headline,
    impact: ruling?.impactFinal,
    note: ruling?.analystNote,
    unsendLeft: e.status == EventStatus.sending && e.unsendUntil != null
        ? e.unsendUntil!.difference(now)
        : null,
  );
}

class FilingStatusView extends StatelessWidget {
  const FilingStatusView({
    super.key,
    required this.model,
    this.onClose,
    this.onUndo,
  });

  final FilingStatusModel model;
  final VoidCallback? onClose;

  /// Unsend, during the window.
  final VoidCallback? onUndo;

  @override
  Widget build(BuildContext context) {
    final m = model;
    final top = MediaQuery.paddingOf(context).top;
    final left = m.unsendLeft;
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
                status: m.status,
                statusLabel: m.statusLabel,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(m.title, style: AuraType.title),
                    const SizedBox(height: 10),
                    Text(
                      m.text,
                      style: AuraType.body.copyWith(
                        height: 22 / 15,
                        color: AuraColors.inkSecondary,
                        fontFeatures: const [],
                      ),
                    ),
                    if (m.banner case final banner?) ...[
                      const SizedBox(height: 20),
                      ModelBanner(banner),
                    ],
                    if (m.rulingIn case final left?) ...[
                      const SizedBox(height: 20),
                      AuraCountdown(time: left, label: rulingIn),
                    ],
                    if (m.headline case final headline?) ...[
                      const SizedBox(height: 24),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 16,
                        children: [
                          Expanded(
                            child: Text(headline, style: AuraType.headline),
                          ),
                          if (m.impact case final impact?)
                            AuraImpactDisc(
                              delta: impact,
                              label: impactWord(impact),
                            ),
                        ],
                      ),
                      if (m.note case final note?) ...[
                        const SizedBox(height: 12),
                        AuraQuoteCard(quote: quoted(note)),
                      ],
                    ],
                    const SizedBox(height: 28),
                    AuraReceipt(rows: m.track),
                  ],
                ),
              ),
            ],
          ),
          if (left != null && left > Duration.zero)
            Positioned(
              left: 16,
              right: 16,
              bottom: 40,
              child: AuraToast(
                message: filedGoesLive(formatCountdown(left)),
                action: undo,
                onAction: onUndo,
              ),
            ),
        ],
      ),
    );
  }
}
