import 'package:decimal/decimal.dart';
import 'package:flutter/widgets.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../api/generated/export.dart' hide Freshness;
import '../../data/freshness.dart';
import '../../design/icons.dart';
import '../../design/tone.dart';
import '../../design/widgets/aura_banner.dart';
import '../../design/widgets/aura_receipt.dart';
import '../../design/widgets/aura_status_chip.dart';
import '../../format/change.dart';
import '../../format/countdown.dart';
import '../../format/money.dart';
import '../../format/time.dart';
import '../../l10n/strings.dart';
import '../../format/ticker.dart';
import '../shared/banner_model.dart';
import 'about_you_views.dart';

/// The market chip at the top right: "Closed · opens 7:00 am" while closed.
ChipModel marketChip(
  Freshness market,
  tz.Location zone, {
  required DateTime now,
}) => switch (market.marketState) {
  MarketState.closed when market.nextChangeAt != null => ChipModel(
    AuraStatus.closed,
    closedOpens(market.nextChangeAt!, zone, now: now),
  ),
  MarketState.closed => const ChipModel(AuraStatus.closed),
  MarketState.pre => const ChipModel(AuraStatus.pre),
  MarketState.after => const ChipModel(AuraStatus.after),
  MarketState.halted => const ChipModel(AuraStatus.halted),
  _ => const ChipModel(AuraStatus.open),
};

SubjectModel _subject(Event event, String subtitle, {int? impact}) =>
    SubjectModel(
      initial: event.subject.displayName.characters.first,
      ticker: event.subject.ticker,
      subtitle: subtitle,
      impact: impact,
      impactLabel: impact == null ? null : impactWord(impact),
    );

/// A rumor about you (W01), from the event, including how much bigger a
/// confirmed hit gets if you deny it (`denialPenaltyPct`).
RumorAboutYouModel rumorAboutYouModel({
  required Event event,
  required Freshness market,
  required tz.Location zone,
  required DateTime now,
}) {
  final left = (event.rumorEndsAt ?? now).difference(now);
  return RumorAboutYouModel(
    chip: marketChip(market, zone, now: now),
    subject: _subject(event, rumorAboutYou(formatClock(event.createdAt, zone))),
    teaser: event.teaser,
    explainer: rumorExplainer,
    stats: [
      (rulingIn, formatCountdown(left)),
      (coSigns, '${event.reactions.cosigns}'),
      (receiptsLabel, '${event.receipts.length}'),
    ],
    respondTitle: howDoYouRespond,
    responses: [
      const RowModel(
        icon: AuraIcons.chat,
        title: respondNoComment,
        subtitle: respondNoCommentNote,
      ),
      RowModel(
        icon: AuraIcons.alert,
        title: respondDeny,
        subtitle: denyNote(Decimal.parse(event.denialPenaltyPct)),
        trailing: risky,
        trailingTone: AuraTone.warn,
      ),
      RowModel(
        icon: AuraIcons.clock,
        title: respondNothing,
        subtitle: rulingLandsIn(left),
      ),
    ],
    footer: rumorFooter(event.subject.ticker),
  );
}

/// The ruling on you (W02), from the ruled event, its stock page and your
/// membership's super-injunctions. The rating's change ("Downgrade") isn't
/// in the contract until Phase 2 (contract request #9b).
RulingOnYouModel rulingOnYouModel({
  required Event event,
  required ListingDetail listing,
  required Freshness market,
  required int superInjunctionsLeft,
  required tz.Location zone,
  String? ratingChange,
  int? superInjunctionsPerSeason,
  required DateTime now,
}) {
  final ruling = event.ruling!;
  final landsAt = ruling.landsAt;
  return RulingOnYouModel(
    chip: marketChip(market, zone, now: now),
    subject: _subject(
      event,
      rulingAboutYou(formatClock(ruling.ruledAt, zone)),
      impact: ruling.impactFinal,
    ),
    landsLabel: landsAt == null
        ? 'Landed ${formatClock(ruling.ruledAt, zone)}'
        : landsAtOpen(landsAt, zone, now: now),
    indicated: Decimal.parse(ruling.indicatedPrice ?? listing.price),
    movePct: Decimal.parse(ruling.priceMovePct),
    from: indicatedFrom(Decimal.parse(listing.prevClose)),
    headline: ruling.headline,
    note: quoted(ruling.analystNote),
    noteSource: analystSource(
      ratingChange,
      Decimal.parse(listing.analyst?.priceTarget ?? listing.price),
    ),
    stats: [
      (statAnalyst, formatImpact(ruling.impactAnalyst)),
      (
        coSignCount(event.reactions.cosigns),
        multiplier(Decimal.parse(ruling.multipliers.cosign)),
      ),
      (groupVote, voteScore(event.votes?.up ?? 0, event.votes?.down ?? 0)),
    ],
    actions: [
      const RowModel(
        icon: AuraIcons.chat,
        title: postStatement,
        subtitle: postStatementNote,
      ),
      RowModel(
        icon: AuraIcons.hide,
        title: superInjunction,
        subtitle: superInjunctionNote,
        trailing: leftOf(superInjunctionsLeft, superInjunctionsPerSeason),
      ),
      RowModel(
        icon: AuraIcons.gavel,
        title: appealRuling,
        subtitle: appealNote,
        trailing: event.appeal == null
            ? null
            : daysLeft(event.appeal!.deadline, now: now),
      ),
    ],
  );
}

/// An SEC charge against you, as contract request #9 asks the server to
/// describe one. SEC cases are Phase 2 and `/v1` has no schema for them yet,
/// so fixtures supply it. Amounts are decimal strings, like the API's.
@immutable
class SecCharge {
  const SecCharge({
    required this.caseNumber,
    required this.at,
    required this.headline,
    required this.taken,
    required this.finePct,
    required this.filedWhat,
    required this.filedAt,
    required this.tradeQuantity,
    required this.tradeTicker,
    required this.tradeAt,
    required this.tradePrice,
    required this.profit,
    required this.oddsPct,
    required this.scandalTicker,
    required this.scandalImpact,
    required this.scandalMovePct,
    required this.appealDeadline,
    required this.cleanWindowMinutes,
  });

  final String caseNumber;
  final DateTime at;

  /// The Analyst's headline, as-is.
  final String headline;
  final String taken;
  final String finePct;

  /// "the gym rumor": how the case names the event you filed.
  final String filedWhat;
  final DateTime filedAt;
  final String tradeQuantity;
  final String tradeTicker;
  final DateTime tradeAt;
  final String tradePrice;
  final String profit;
  final String oddsPct;

  /// The scandal the charge filed against your own stock.
  final String scandalTicker;
  final int scandalImpact;
  final String scandalMovePct;
  final DateTime appealDeadline;
  final int cleanWindowMinutes;
}

/// An SEC charge (W03).
SecChargeModel secChargeModel({
  required SecCharge charge,
  required tz.Location zone,
  required DateTime now,
}) {
  final c = charge;
  final taken = Decimal.parse(c.taken);
  final move = Decimal.parse(c.scandalMovePct);
  return SecChargeModel(
    caseLine: secCaseLine(c.caseNumber, formatClock(c.at, zone)),
    headline: c.headline,
    heroLabel: takenFromCash,
    taken: taken,
    takenNote: clawbackNote(Decimal.parse(c.finePct)),
    evidence: [
      AuraReceiptRow(youFiled(c.filedWhat), formatClock(c.filedAt, zone)),
      AuraReceiptRow(
        youBought(Decimal.parse(c.tradeQuantity), c.tradeTicker),
        atPrice(formatClock(c.tradeAt, zone), Decimal.parse(c.tradePrice)),
      ),
      AuraReceiptRow(profitWhenRuled, formatMoney(Decimal.parse(c.profit))),
      AuraReceiptRow(
        oddsOfGettingCaught,
        percentWhole(Decimal.parse(c.oddsPct)),
      ),
    ],
    total: AuraReceiptRow(
      clawedBackPlusFine,
      formatMoney(taken),
      tone: AuraTone.down,
    ),
    actions: [
      RowModel(
        icon: AuraIcons.alert,
        title: scandalAgainst(c.scandalTicker),
        subtitle: impactOnTape(c.scandalImpact),
        trailing: formatPercent(move),
        trailingTone: move.sign < 0 ? AuraTone.down : AuraTone.up,
      ),
      RowModel(
        icon: AuraIcons.gavel,
        title: appealCharge,
        subtitle: appealNote,
        trailing: daysLeft(c.appealDeadline, now: now),
      ),
    ],
    footer: stayClean(c.cleanWindowMinutes),
  );
}

/// A rumor about someone else (SCREENS.md #13), on W01's layout: the
/// teaser, the countdown to the ruling, the co-signs and caps, the insider
/// notice once you've backed it, and your call.
RumorModel rumorModel({
  required Event event,
  required Freshness market,
  required tz.Location zone,
  required DateTime now,
}) {
  final left = (event.rumorEndsAt ?? now).difference(now);
  final mine = event.reactions.mine;
  final insider = event.insiderUntil;
  final ticker = formatTicker(event.subject.ticker);
  return RumorModel(
    chip: marketChip(market, zone, now: now),
    subject: _subject(
      event,
      unconfirmedReport(formatClock(event.createdAt, zone)),
    ),
    teaser: event.teaser,
    explainer: rumorPublicExplainer,
    stats: [
      (rulingIn, formatCountdown(left.isNegative ? Duration.zero : left)),
      (coSigns, '${event.reactions.cosigns}'),
      (caps, '${event.reactions.caps}'),
    ],
    banner: insider == null
        ? null
        : BannerModel(
            tone: AuraBannerTone.rumor,
            title: insiderTitle(formatMoment(insider, zone, now: now)),
            body: insiderBody(ticker),
          ),
    respondTitle: didItHappen,
    responses: [
      RowModel(
        icon: AuraIcons.vote,
        title: iSawIt,
        subtitle: iSawItNote,
        trailing: mine == Mine2.cosign ? yourCall : null,
      ),
      RowModel(
        icon: AuraIcons.close,
        title: didntHappen,
        subtitle: didntHappenNote,
        trailing: mine == Mine2.cap ? yourCall : null,
      ),
      if (mine != null)
        const RowModel(
          icon: AuraIcons.back,
          title: takeItBack,
          subtitle: takeItBackNote,
        ),
    ],
    reactions: [Kind.cosign, Kind.cap, if (mine != null) Kind.withdraw],
  );
}

/// A ruling, as everyone sees it (SCREENS.md #15), on W02's layout: the
/// headline and impact, the Analyst's note, how it was weighted, the group's
/// verdict on a halt, a correction after an appeal, and the up/down vote
/// while it's open (with the conflicted note when you hold the stock).
RulingModel rulingModel({
  required Event event,
  required Freshness market,
  required bool holdsStock,
  required tz.Location zone,
  required DateTime now,
}) {
  final ruling = event.ruling;
  final votes = event.votes;
  final ticker = formatTicker(event.subject.ticker);
  final open = votes != null && votes.closesAt.isAfter(now);
  final hidden = event.status == EventStatus.hidden;
  final correction = ruling?.correction;
  final BannerModel? banner = event.status == EventStatus.voided
      ? const BannerModel(
          tone: AuraBannerTone.neutral,
          title: voidedTitle,
          body: voidedBody,
        )
      : hidden
      ? const BannerModel(
          tone: AuraBannerTone.neutral,
          title: storyHiddenTitle,
          body: storyHiddenBody,
        )
      : correction != null
      ? BannerModel(
          tone: AuraBannerTone.neutral,
          title: correctionTitle,
          body: correction,
        )
      : switch (event.halt?.status) {
          HaltStatus.confirmed => const BannerModel(
            tone: AuraBannerTone.neutral,
            title: confirmedTitle,
          ),
          HaltStatus.declined => const BannerModel(
            tone: AuraBannerTone.neutral,
            title: declinedTitle,
            body: voidedBody,
          ),
          HaltStatus.reconsidered => const BannerModel(
            tone: AuraBannerTone.neutral,
            title: reconsideredTitle,
            body: reconsideredBody,
          ),
          _ => null,
        };
  return RulingModel(
    chip: marketChip(market, zone, now: now),
    subject: _subject(
      event,
      ruling == null
          ? unconfirmedReport(formatClock(event.createdAt, zone))
          : ruledLine(formatClock(ruling.ruledAt, zone)),
      impact: hidden ? null : ruling?.impactFinal,
    ),
    banner: banner,
    headline: hidden ? null : ruling?.headline ?? event.teaser,
    note: hidden || ruling == null ? null : quoted(ruling.analystNote),
    noteSource: theAnalyst,
    movePct: ruling == null ? null : Decimal.parse(ruling.priceMovePct),
    stats: ruling == null
        ? const []
        : [
            (statAnalyst, formatImpact(ruling.impactAnalyst)),
            (
              coSignCount(event.reactions.cosigns),
              multiplier(Decimal.parse(ruling.multipliers.cosign)),
            ),
            (groupVote, voteScore(votes?.up ?? 0, votes?.down ?? 0)),
          ],
    voteTitle: votes == null ? null : groupVoteHeading,
    voteStatus: votes == null
        ? null
        : open
        ? votingClosesAt(formatMoment(votes.closesAt, zone, now: now))
        : votingClosed,
    votes: open
        ? [
            RowModel(
              icon: AuraIcons.plus,
              title: voteUp,
              subtitle: voteUpNote,
              trailing: votes.mine == Mine3.up ? yourVoteLabel : null,
            ),
            RowModel(
              icon: AuraIcons.minus,
              title: voteDown,
              subtitle: voteDownNote,
              trailing: votes.mine == Mine3.down ? yourVoteLabel : null,
            ),
          ]
        : const [],
    voteNote: open && (votes.conflicted || holdsStock)
        ? conflictedNote(ticker)
        : null,
  );
}
