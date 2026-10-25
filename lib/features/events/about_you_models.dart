import 'package:decimal/decimal.dart';
import 'package:flutter/widgets.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../api/generated/export.dart' hide Freshness;
import '../../data/freshness.dart';
import '../../design/icons.dart';
import '../../design/tone.dart';
import '../../design/widgets/aura_receipt.dart';
import '../../design/widgets/aura_status_chip.dart';
import '../../format/change.dart';
import '../../format/countdown.dart';
import '../../format/money.dart';
import '../../format/time.dart';
import '../../l10n/strings.dart';
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

/// A rumor about you (W01), from the event. [denialPenaltyPct] is how much
/// bigger a confirmed hit gets if you deny it: a game rule the contract
/// doesn't send yet (contract request #9).
RumorAboutYouModel rumorAboutYouModel({
  required Event event,
  required Freshness market,
  required Decimal denialPenaltyPct,
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
        subtitle: denyNote(denialPenaltyPct),
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

/// The ruling on you (W02), from the ruled event and its stock page. The
/// rating's change ("Downgrade") and the season's super-injunction count
/// aren't in the contract yet (contract request #9).
RulingOnYouModel rulingOnYouModel({
  required Event event,
  required ListingDetail listing,
  required Freshness market,
  required String ratingChange,
  required int superInjunctionsLeft,
  required int superInjunctionsPerSeason,
  required tz.Location zone,
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
