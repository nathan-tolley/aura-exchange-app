import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';

import '../../api/generated/export.dart' hide Freshness;
import '../../design/widgets/aura_banner.dart';
import '../../format/money.dart';
import '../../l10n/strings.dart';
import '../shared/banner_model.dart';
import 'bankruptcy_view.dart';

/// What filing for Chapter 7 would do, as contract request #8 asks the
/// server to send it: the minimum to trade, the cash you'd restart with, the
/// badge, and the tape's line. `/v1` only says "reset to A$2,000 with a
/// badge", and those are game rules, so fixtures supply them meanwhile.
/// Amounts are decimal strings, like the API's.
@immutable
class BankruptcyOffer {
  const BankruptcyOffer({
    required this.minimumEquity,
    required this.resetCash,
    required this.badge,
    required this.tapeHeadline,
  });

  final String minimumEquity;
  final String resetCash;

  /// "Chapter 7".
  final String badge;

  /// The Analyst's line for the moment you file, bare.
  final String tapeHeadline;
}

/// The Chapter 7 offer (W04), from your portfolio (when the server says you
/// can declare) and the offer.
BankruptcyModel bankruptcyModel({
  required Portfolio portfolio,
  required BankruptcyOffer offer,
  required int season,
}) {
  final netWorth = Decimal.parse(portfolio.netWorth);
  final copy = underMinimumCopy(Decimal.parse(offer.minimumEquity));
  return BankruptcyModel(
    heroLabel: 'Net worth · Season $season',
    netWorth: netWorth,
    seasonAbs: Decimal.parse(portfolio.seasonChangeAbs),
    seasonPct: Decimal.parse(portfolio.seasonChangePct),
    banner: BannerModel(
      tone: AuraBannerTone.down,
      title: copy.title,
      body: copy.body,
    ),
    sectionTitle: ifYouFile,
    youGet: formatMoney(Decimal.parse(offer.resetCash)),
    youGiveUp: netWorthAndPositions(netWorth, portfolio.positions.length),
    badgeLabel: badgeUntilSeasonEnds,
    badge: offer.badge,
    tapeLabel: whatTheTapeWillSay,
    tape: quoted(offer.tapeHeadline),
    tapeSource: tapeTheMomentYouFile,
    slide: slideToDeclareBankruptcy,
    keepGoing: keepGoingWith(netWorth),
  );
}
