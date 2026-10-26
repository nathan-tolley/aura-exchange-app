import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../api/errors.dart';
import '../../api/generated/export.dart' hide Freshness;
import '../../data/freshness.dart';
import '../../data/live_market.dart';
import '../../design/tone.dart';
import '../../design/widgets/aura_banner.dart';
import '../../design/widgets/aura_chart.dart';
import '../../design/widgets/aura_status_chip.dart';
import '../../format/change.dart';
import '../../format/money.dart';
import '../../format/ticker.dart';
import '../../format/time.dart';
import '../../l10n/strings.dart';
import '../shared/banner_model.dart';
import '../shared/market_chip.dart';

/// The stock page's sections (AuraTabs).
enum StockTab { overview, tape, analyst }

/// The chart's ranges, as the segmented control labels them and as the API
/// asks for them.
const chartRangeFor = {
  '1D': Range.value1d,
  '1W': Range.value1w,
  '1M': Range.value1m,
  'SZN': Range.season,
};

/// Everything the stock page shows (SCREENS.md #7, #8), decided and worded.
@immutable
class StockPageModel {
  const StockPageModel({
    required this.status,
    required this.line,
    required this.price,
    required this.range,
    required this.tab,
    required this.stats,
    required this.rangeLow,
    required this.rangeHigh,
    required this.events,
    required this.actions,
    this.statusLabel,
    this.approx = false,
    this.changeAbs,
    this.changePct,
    this.changePeriod,
    this.banner,
    this.bannerEventId,
    this.chart,
    this.tape,
    this.analyst,
    this.note,
    this.name = '',
    this.ticker = '',
  });

  final AuraStatus status;
  final String? statusLabel;

  /// "$ANNA · Anna · Rumor pending".
  final String line;

  /// The last trade, or the indicated opening price ([approx]).
  final Decimal price;
  final bool approx;
  final Decimal? changeAbs;
  final Decimal? changePct;

  /// "today", or "indicated" before the open.
  final String? changePeriod;
  final BannerModel? banner;

  /// The event the banner's action opens (a pending rumor).
  final String? bannerEventId;

  /// Null while the chart loads.
  final StockChartModel? chart;

  /// "1D", "1W", "1M", "SZN".
  final String range;
  final StockTab tab;

  /// The spec sheet: (label, value).
  final List<(String, String)> stats;
  final Decimal rangeLow;
  final Decimal rangeHigh;
  final List<StockEventRow> events;

  /// Null while the tape loads.
  final List<StockTapeRow>? tape;

  /// The Analyst's note and its source line, if there's coverage.
  final (String, String)? analyst;

  /// The trade bar's buttons, secondary first. Empty for your own stock and
  /// a delisted one.
  final List<StockAction> actions;

  /// Under the trade bar: why it's missing or disabled.
  final String? note;
  final String name;
  final String ticker;
}

@immutable
class StockChartModel {
  const StockChartModel({
    required this.points,
    required this.markers,
    this.previousClose,
  });

  final List<AuraChartPoint> points;
  final List<AuraChartMarker> markers;
  final Decimal? previousClose;
}

@immutable
class StockEventRow {
  const StockEventRow({
    required this.id,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.trailingTone = AuraTone.neutral,
  });

  final String id;
  final String title;

  /// "Ruled · 2 h ago".
  final String subtitle;

  /// The final impact, "−18".
  final String? trailing;
  final AuraTone trailingTone;
}

@immutable
class StockTapeRow {
  const StockTapeRow({
    required this.source,
    required this.headline,
    this.movePct,
    this.eventId,
  });

  final String source;
  final String headline;
  final Decimal? movePct;
  final String? eventId;
}

/// One of the trade bar's buttons.
@immutable
class StockAction {
  const StockAction(this.label, this.side, {this.primary = false});

  final String label;
  final Side side;

  /// Buy and Cover are `ink`; Sell, Short and Short more are secondary.
  final bool primary;
}

StockPageModel stockPageModel({
  required ListingDetail detail,
  required LiveListing? live,
  required Freshness freshness,
  required Liveness liveness,
  required bool offline,
  required CandleSeries? candles,
  required String range,
  required StockTab tab,
  required List<TapeItem>? tape,
  required tz.Location zone,
  required DateTime now,
}) {
  final ticker = formatTicker(detail.ticker);
  final last = live?.price ?? Decimal.parse(detail.price);
  final state = live?.state ?? detail.state;
  final delisted = state == ListingState.delisted;
  final beforeOpen =
      freshness.marketState == MarketState.closed ||
      freshness.marketState == MarketState.pre;
  final indicatedPrice = detail.indicatedPrice;
  final showIndicated = beforeOpen && indicatedPrice != null && !delisted;
  final (status, statusLabel) = marketChip(
    freshness,
    liveness,
    zone: zone,
    now: now,
  );
  final rumor = detail.events
      .where((e) => e.status == EventStatus.rumor)
      .firstOrNull;
  final lastTrade = detail.lastTradeAt;

  BannerModel? banner;
  if (offline) {
    final copy = offlineBanner(freshness.asOf, zone, now: now);
    banner = BannerModel(
      tone: AuraBannerTone.offline,
      title: copy.title,
      body: copy.body,
      action: copy.action,
    );
  } else if (delisted) {
    banner = BannerModel(
      tone: AuraBannerTone.neutral,
      title: delistedTitle(ticker),
      body: delistedBody(detail.displayName, last),
    );
  } else if (rumor != null) {
    banner = BannerModel(
      tone: AuraBannerTone.rumor,
      title: rumorPendingTitle(ticker),
      body: rumorPendingBody,
      action: readIt,
    );
  } else if (beforeOpen && freshness.marketState == MarketState.closed) {
    final copy = closedBanner(
      opensAt: freshness.nextChangeAt,
      queued: detail.badges.contains(Badge.queuedForOpen) ? [ticker] : [],
      zone: zone,
      now: now,
    );
    banner = BannerModel(
      tone: AuraBannerTone.neutral,
      title: copy.title,
      body: copy.body,
    );
  }

  final position = detail.myPosition;
  final actions = detail.isMine || delisted
      ? const <StockAction>[]
      : switch (position?.side) {
          PositionSide.long => const [
            StockAction(sell, Side.sell),
            StockAction(buy, Side.buy, primary: true),
          ],
          PositionSide.short => const [
            StockAction(shortMore, Side.short),
            StockAction(coverLabel, Side.cover, primary: true),
          ],
          _ => const [
            StockAction(short, Side.short),
            StockAction(buy, Side.buy, primary: true),
          ],
        };
  final note = detail.isMine
      ? youCantTradeYourself
      : delisted
      ? delistedNoTrading
      : offline
      ? offlineNoTrading
      : freshness.marketState == MarketState.closed
      ? closedOrdersNote
      : null;

  final analyst = detail.analyst;
  return StockPageModel(
    status: status,
    statusLabel: statusLabel,
    line: stockLine(
      detail.ticker,
      detail.displayName,
      badges: detail.badges,
      lastTrade: beforeOpen && lastTrade != null
          ? formatClock(lastTrade, zone)
          : null,
    ),
    price: showIndicated ? Decimal.parse(indicatedPrice) : last,
    approx: showIndicated,
    changeAbs: showIndicated ? null : live?.changeAbs ?? _d(detail.changeAbs),
    changePct: showIndicated
        ? _d(detail.indicatedChangePct)
        : live?.changePct ?? _d(detail.changePct),
    changePeriod: showIndicated ? indicated : today,
    banner: banner,
    bannerEventId: offline || delisted ? null : rumor?.id,
    chart: candles == null ? null : _chart(candles, range),
    range: range,
    tab: tab,
    stats: [
      (statOpen, detail.open == null ? notYet : _money(detail.open!)),
      (statPrevClose, _money(detail.prevClose)),
      (statDayRange, '${_money(detail.dayLow)} – ${_money(detail.dayHigh)}'),
      (statVolume, formatQuantity(Decimal.parse(detail.volume))),
      (statShortInterest, percentWhole(Decimal.parse(detail.shortInterestPct))),
      (statBorrowFee, perDay(Decimal.parse(detail.borrowFeeDailyPct))),
    ],
    rangeLow: Decimal.parse(detail.seasonLow),
    rangeHigh: Decimal.parse(detail.seasonHigh),
    events: [
      for (final e in detail.events)
        StockEventRow(
          id: e.id,
          title: e.headline ?? e.teaser,
          subtitle:
              '${eventStatusWord(e.status)} · '
              '${formatWhen(e.createdAt, zone, now: now)}',
          trailing: e.impactFinal == null ? null : formatImpact(e.impactFinal!),
          trailingTone: switch ((e.impactFinal ?? 0).sign) {
            > 0 => AuraTone.up,
            < 0 => AuraTone.down,
            _ => AuraTone.neutral,
          },
        ),
    ],
    tape: tape == null
        ? null
        : [
            for (final t in tape)
              StockTapeRow(
                source: [
                  ?t.listing == null ? null : formatTicker(t.listing!.ticker),
                  tapeTypeWord(t.type),
                  formatWhen(t.at, zone, now: now),
                ].join(' · '),
                headline: t.headline,
                movePct: _d(t.priceMovePct),
                eventId: t.eventId,
              ),
          ],
    analyst: analyst == null
        ? null
        : (
            quoted(analyst.note),
            analystRatingSource(
              _rating(analyst.rating),
              Decimal.parse(analyst.priceTarget),
            ),
          ),
    actions: actions,
    note: note,
    name: detail.displayName,
    ticker: ticker,
  );
}

StockChartModel _chart(CandleSeries series, String range) {
  final markers = [
    for (final m in series.markers)
      AuraChartMarker(
        at: m.t,
        label: '${formatImpact(m.impact)} ruling',
        tone: m.impact < 0
            ? AuraTone.down
            : m.impact > 0
            ? AuraTone.up
            : AuraTone.neutral,
      ),
  ];
  return StockChartModel(
    points: [
      for (final c in series.candles) AuraChartPoint(c.t, Decimal.parse(c.c)),
    ],
    markers: markers,
    // The dotted previous close belongs to the day's chart.
    previousClose: range == '1D' ? Decimal.parse(series.prevClose) : null,
  );
}

String _rating(Rating rating) => switch (rating) {
  Rating.buy => 'Buy',
  Rating.hold => 'Hold',
  Rating.sell => 'Sell',
  Rating.$unknown => 'Rated',
};

Decimal? _d(String? s) => s == null ? null : Decimal.parse(s);

String _money(String s) => formatMoney(Decimal.parse(s));

/// Whether a stock page's numbers are live, from the market it's in.
bool stockOffline(LiveMarket? market) =>
    market?.problem?.code == ApiError.appOffline;
