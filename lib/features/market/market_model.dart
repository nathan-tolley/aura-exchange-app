import 'package:flutter/foundation.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../api/errors.dart';
import '../../api/generated/export.dart' hide Freshness;
import '../../data/freshness.dart';
import '../../data/live_market.dart';
import '../../design/widgets/aura_banner.dart';
import '../../design/widgets/aura_status_chip.dart';
import '../../design/widgets/aura_tape.dart';
import '../../format/ticker.dart';
import '../../l10n/strings.dart';
import '../home/home_view.dart' show HomeRow;
import '../shared/banner_model.dart';
import '../shared/listing_tag.dart';
import '../shared/market_chip.dart';
import '../system/exchange_down_model.dart';

/// The Market tab (SCREENS.md #6), worded.
@immutable
class MarketListModel {
  const MarketListModel({
    required this.tape,
    required this.heading,
    required this.status,
    required this.rows,
    this.statusLabel,
    this.banner,
    this.empty,
  });

  final List<AuraTapeItem> tape;

  /// "All stocks", or "2 results" while searching.
  final String heading;
  final AuraStatus status;
  final String? statusLabel;
  final BannerModel? banner;

  /// By today's change, biggest gain first (COMPONENTS.md → StockRow: the
  /// market sorts by % change).
  final List<HomeRow> rows;

  /// "Nobody matches “zz”": a search with no results.
  final (String, String)? empty;
}

MarketListModel marketListModel({
  required LiveMarket market,
  required Liveness liveness,
  required String query,
  required tz.Location zone,
  required DateTime now,
}) {
  final freshness = market.freshness;
  final (status, statusLabel) = marketChip(
    freshness,
    liveness,
    zone: zone,
    now: now,
  );
  final q = query.trim().toLowerCase().replaceFirst(r'$', '');
  final matches = [
    for (final l in market.listings)
      if (q.isEmpty ||
          formatTicker(l.summary.ticker).toLowerCase().contains(q) ||
          l.summary.displayName.toLowerCase().contains(q))
        l,
  ]..sort((a, b) => b.changePct.compareTo(a.changePct));
  return MarketListModel(
    tape: [
      for (final l in market.listings)
        AuraTapeItem(
          ticker: formatTicker(l.summary.ticker),
          price: l.price,
          pct: l.changePct,
        ),
    ],
    heading: q.isEmpty ? allStocks : resultsCount(matches.length),
    status: status,
    statusLabel: statusLabel,
    banner: _banner(market, zone: zone, now: now),
    rows: [for (final l in matches) _row(l)],
    empty: q.isNotEmpty && matches.isEmpty
        ? (nobodyMatches(query.trim()), searchByNameOrTicker)
        : null,
  );
}

/// One banner, the most severe: offline (W11), the exchange halted, closed
/// (W09).
BannerModel? _banner(
  LiveMarket market, {
  required tz.Location zone,
  required DateTime now,
}) {
  final f = market.freshness;
  if (market.problem?.code == ApiError.appOffline) {
    final copy = offlineBanner(f.asOf, zone, now: now);
    return BannerModel(
      tone: AuraBannerTone.offline,
      title: copy.title,
      body: copy.body,
      action: copy.action,
    );
  }
  final problem = market.problem;
  if (problem != null && isExchangeDown(problem)) {
    final copy = errorCopy(problem);
    return BannerModel(
      tone: AuraBannerTone.down,
      title: copy.title,
      body: copy.body,
      action: copy.action,
    );
  }
  if (f.marketState == MarketState.halted) {
    final copy = exchangeHaltedBanner(f.nextChangeAt, zone, now: now);
    return BannerModel(
      tone: AuraBannerTone.warn,
      title: copy.title,
      body: copy.body,
    );
  }
  if (f.marketState == MarketState.closed) {
    final copy = closedBanner(
      opensAt: f.nextChangeAt,
      queued: [
        for (final l in market.listings)
          if (l.summary.badges.contains(Badge.queuedForOpen))
            formatTicker(l.summary.ticker),
      ],
      zone: zone,
      now: now,
    );
    return BannerModel(
      tone: AuraBannerTone.neutral,
      title: copy.title,
      body: copy.body,
    );
  }
  return null;
}

HomeRow _row(LiveListing l) {
  final (tag, tone) = listingTag(l);
  return HomeRow(
    id: l.id,
    ticker: formatTicker(l.summary.ticker),
    name: l.summary.displayName,
    price: l.price,
    abs: l.changeAbs,
    pct: l.changePct,
    points: [for (final p in l.summary.sparkline) double.parse(p)],
    tag: tag,
    tagTone: tone,
  );
}
