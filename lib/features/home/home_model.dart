import 'package:decimal/decimal.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../api/errors.dart';
import '../../api/generated/export.dart' hide Freshness;
import '../../data/freshness.dart';
import '../../data/live_market.dart';
import '../../design/tone.dart';
import '../../design/widgets/aura_banner.dart';
import '../../design/widgets/aura_tape.dart';
import '../../format/ticker.dart';
import '../../l10n/strings.dart';
import 'home_view.dart';

/// Builds Home from the API's payloads: the live market (with freshness),
/// the portfolio, and the watchlist's order.
///
/// - Offline (a refetch failed with no connection): the offline banner
///   above the hero, every price stamped "as of", and both actions disabled
///   (W11).
/// - Closed: "at the close", a banner saying when it opens and what lands
///   then, and Trade becomes "Set an order" (W09).
/// - IPO day ([ipo] given): the listing progress instead of the actions and
///   the watchlist (W12).
HomeViewModel homeViewModel({
  required LiveMarket market,
  required Portfolio portfolio,
  required Liveness liveness,
  required List<String> watchlist,
  required int season,
  required tz.Location zone,
  required DateTime now,
  HomeIpoInput? ipo,
  bool tapeUnread = false,
}) {
  final listings = market.listings;
  final freshness = market.freshness;
  final offline = market.problem?.code == ApiError.appOffline;
  final delayed = liveness == Liveness.delayed;
  final closed = freshness.marketState == MarketState.closed;
  final byId = {for (final l in listings) l.id: l};

  final closedCopy = closed
      ? closedBanner(
          opensAt: freshness.nextChangeAt,
          queued: [
            for (final l in listings)
              if (l.summary.badges.contains(Badge.queuedForOpen))
                formatTicker(l.summary.ticker),
          ],
          zone: zone,
          now: now,
        )
      : null;
  final offlineCopy = offline
      ? offlineBanner(freshness.asOf, zone, now: now)
      : null;

  return HomeViewModel(
    tape: [
      for (final l in listings)
        AuraTapeItem(
          ticker: formatTicker(l.summary.ticker),
          price: l.price,
          pct: l.changePct,
        ),
    ],
    searchPlaceholder: ipo == null ? searchFriends : nobodyToSearch,
    heroLabel: netWorthLabel(
      closed: closed,
      delayed: delayed,
      season: season,
      asOf: freshness.asOf,
      zone: zone,
      now: now,
    ),
    netWorth: Decimal.parse(portfolio.netWorth),
    seasonAbs: ipo == null ? Decimal.parse(portfolio.seasonChangeAbs) : null,
    seasonPct: ipo == null ? Decimal.parse(portfolio.seasonChangePct) : null,
    heroNote: ipo?.heroNote,
    hideable: ipo == null,
    actions: ipo == null
        ? HomeActions(trade: closed ? setAnOrder : trade, enabled: !offline)
        : null,
    offlineBanner: offlineCopy == null
        ? null
        : HomeBanner(
            tone: AuraBannerTone.offline,
            title: offlineCopy.title,
            body: offlineCopy.body,
            action: offlineCopy.action,
          ),
    marketBanner: closedCopy == null
        ? null
        : HomeBanner(
            tone: AuraBannerTone.neutral,
            title: closedCopy.title,
            body: closedCopy.body,
          ),
    watchlist: ipo == null
        ? HomeWatchlist(
            asOf: delayed ? asOfStatus(freshness.asOf, zone, now: now) : null,
            rows: [
              for (final id in watchlist)
                if (byId[id] case final listing?) _row(listing),
            ],
          )
        : null,
    ipo: ipo?.section,
    tapeBadge: tapeUnread,
  );
}

HomeRow _row(LiveListing listing) {
  final s = listing.summary;
  final (tag, tone) = switch (s) {
    _ when s.badges.contains(Badge.queuedForOpen) => (tagRuled, AuraTone.warn),
    ListingSummary(myPosition: MyPosition(side: PositionSide.long)) => (
      tagHolding,
      AuraTone.neutral,
    ),
    ListingSummary(myPosition: MyPosition(side: PositionSide.short)) => (
      tagShort,
      AuraTone.neutral,
    ),
    _ => (null, AuraTone.neutral),
  };
  return HomeRow(
    id: s.id,
    ticker: formatTicker(s.ticker),
    name: s.displayName,
    price: listing.price,
    abs: listing.changeAbs,
    pct: listing.changePct,
    // A chart's points, not money: doubles are fine here.
    points: [for (final p in s.sparkline) double.parse(p)],
    tag: tag,
    tagTone: tone,
  );
}

/// What IPO day shows besides the market (W12). The contract has no member
/// or invite list yet, so A4 decides where these rows come from.
class HomeIpoInput {
  const HomeIpoInput({required this.heroNote, required this.section});

  /// "Your starting cash. The market opens at 3 listings."
  final String heroNote;
  final HomeIpo section;
}
