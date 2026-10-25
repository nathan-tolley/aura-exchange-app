import 'package:decimal/decimal.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../api/generated/export.dart' hide Freshness;
import '../../design/icons.dart';
import '../../format/time.dart';
import '../../l10n/strings.dart';
import 'halted_view.dart';

/// A stock page halted for a news vote, from the listing (which carries the
/// halt and its vote) and the event the vote is about (W10).
HaltedStockModel haltedStockModel({
  required ListingDetail listing,
  required EventSummary event,
  required tz.Location zone,
  required DateTime now,
}) {
  final halt = listing.halt!;
  final vote = halt.vote;
  final impact = event.impactFinal ?? 0;
  final lastTrade = listing.lastTradeAt;
  return HaltedStockModel(
    statusLabel: haltStatus(halt.reason),
    line: stockLine(
      listing.ticker,
      listing.displayName,
      lastTrade: lastTrade == null ? null : formatClock(lastTrade, zone),
    ),
    price: Decimal.parse(listing.price),
    voteLabel: voteClosesIn,
    voteLeft: halt.endsAt.difference(now),
    voted: vote == null
        ? ''
        : votedOf(vote.confirm + vote.decline + vote.reconsider, vote.eligible),
    headline: event.headline ?? event.teaser,
    impact: impact,
    impactLabel: impactWord(impact),
    explainer: haltExplainer(
      listing.ticker,
      Decimal.parse(halt.ifConfirmedMovePct ?? '0'),
    ),
    voteTitle: yourVote,
    options: [
      HaltOption(
        choice: 'CONFIRM',
        icon: AuraIcons.vote,
        title: voteConfirm,
        subtitle: voteConfirmNote(impact),
      ),
      const HaltOption(
        choice: 'DECLINE',
        icon: AuraIcons.close,
        title: voteDecline,
        subtitle: voteDeclineNote,
      ),
      const HaltOption(
        choice: 'RECONSIDER',
        icon: AuraIcons.gavel,
        title: voteReconsider,
        subtitle: voteReconsiderNote,
      ),
    ],
    footnote: vote == null ? '' : votingPays(Decimal.parse(vote.reward)),
    sell: sell,
    buy: buy,
    disabledReason: tradingResumesAfterVote,
  );
}
