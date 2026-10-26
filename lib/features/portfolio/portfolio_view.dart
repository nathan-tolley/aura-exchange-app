import 'package:decimal/decimal.dart';
import 'package:flutter/widgets.dart';

import '../../api/generated/export.dart' hide Freshness;
import '../../design/icons.dart';
import '../../design/tokens.dart';
import '../../design/tone.dart';
import '../../design/widgets/aura_banner.dart';
import '../../design/widgets/aura_button.dart';
import '../../design/widgets/aura_empty_state.dart';
import '../../design/widgets/aura_hero_card.dart';
import '../../design/widgets/aura_nav_card.dart';
import '../../design/widgets/aura_section_header.dart';
import '../../design/widgets/aura_sheet.dart';
import '../../design/widgets/aura_skeleton.dart';
import '../../design/widgets/aura_stat_card.dart';
import '../../design/widgets/aura_stock_row.dart';
import '../../design/widgets/aura_tab_bar.dart';
import '../../format/change.dart';
import '../../format/money.dart';
import '../../format/ticker.dart';
import '../../l10n/strings.dart';
import '../shared/banner_model.dart';

/// The Portfolio tab (SCREENS.md #20), worded from `GET /portfolio`.
@immutable
class PortfolioModel {
  const PortfolioModel({
    required this.netWorth,
    required this.dayAbs,
    required this.dayPct,
    required this.stats,
    required this.positions,
    required this.orders,
    this.banner,
    this.bannerPositionId,
  });

  final Decimal netWorth;
  final Decimal dayAbs;
  final Decimal dayPct;

  /// Cash, held for orders, this season: (label, value, tone).
  final List<(String, String, AuraTone)> stats;

  /// A short near liquidation (W07's banner).
  final BannerModel? banner;
  final String? bannerPositionId;
  final List<PositionRow> positions;
  final List<OrderRow> orders;

  bool get empty => positions.isEmpty && orders.isEmpty;
}

@immutable
class PositionRow {
  const PositionRow({
    required this.id,
    required this.listingId,
    required this.ticker,
    required this.name,
    required this.price,
    required this.pnl,
    required this.pnlPct,
    required this.tag,
    this.tagTone = AuraTone.neutral,
    this.short = false,
    this.open = true,
  });

  final String id;
  final String listingId;
  final String ticker;
  final String name;
  final Decimal price;

  /// The unrealized gain or loss, and its percent.
  final Decimal pnl;
  final Decimal pnlPct;

  /// "12 shares", "Short 60", "Liquidated".
  final String tag;
  final AuraTone tagTone;
  final bool short;
  final bool open;
}

@immutable
class OrderRow {
  const OrderRow({
    required this.id,
    required this.title,
    required this.subtitle,
  });

  final String id;
  final String title;
  final String subtitle;
}

PortfolioModel portfolioModel(Portfolio p) {
  final season = Decimal.parse(p.seasonChangeAbs);
  final warning = p.positions.where((x) {
    final s = x.short;
    return x.status == PositionStatus.open &&
        s != null &&
        Decimal.parse(s.collateralRatioPct) <= Decimal.parse(s.warningRatioPct);
  }).firstOrNull;
  return PortfolioModel(
    netWorth: Decimal.parse(p.netWorth),
    dayAbs: Decimal.parse(p.dayChangeAbs),
    dayPct: Decimal.parse(p.dayChangePct),
    stats: [
      (statCash, formatMoney(Decimal.parse(p.cash)), AuraTone.neutral),
      (
        statHeldForOrders,
        formatMoney(Decimal.parse(p.reservedCash)),
        AuraTone.neutral,
      ),
      (
        statSeason,
        formatSigned(season),
        season > Decimal.zero
            ? AuraTone.up
            : season < Decimal.zero
            ? AuraTone.down
            : AuraTone.neutral,
      ),
    ],
    banner: warning == null
        ? null
        : BannerModel(
            tone: AuraBannerTone.warn,
            title: nearLiquidationTitle(warning.listing.ticker),
            body: marginBannerBody(
              Decimal.parse(warning.short!.collateralRatioPct),
              Decimal.parse(warning.short!.maintenanceRatioPct),
            ),
            action: seeIt,
          ),
    bannerPositionId: warning?.id,
    positions: [
      for (final x in p.positions)
        PositionRow(
          id: x.id,
          listingId: x.listing.id,
          ticker: formatTicker(x.listing.ticker),
          name: x.listing.displayName,
          price: Decimal.parse(x.marketPrice),
          pnl: Decimal.parse(x.unrealizedPnl),
          pnlPct: Decimal.parse(x.unrealizedPnlPct),
          tag: switch (x) {
            _ when x.status == PositionStatus.liquidated => tagLiquidated,
            _ when x.side == PositionSide.short => shortQuantity(
              Decimal.parse(x.quantity),
            ),
            _ => longQuantity(Decimal.parse(x.quantity)),
          },
          tagTone: x.status == PositionStatus.liquidated
              ? AuraTone.down
              : AuraTone.neutral,
          short: x.side == PositionSide.short,
          open: x.status == PositionStatus.open,
        ),
    ],
    orders: [
      for (final o in p.openOrders)
        OrderRow(
          id: o.id,
          title: orderTitle(
            o.type,
            Decimal.parse(o.quantity),
            o.listing.ticker,
          ),
          subtitle: orderSubtitle(
            Decimal.parse(o.triggerPrice),
            Decimal.parse(o.reservedCash),
          ),
        ),
    ],
  );
}

/// The Portfolio tab: net worth and today's move, the spec sheet, the
/// margin banner, your positions (their gain or loss) and open orders.
/// [model] null is loading.
class PortfolioView extends StatelessWidget {
  const PortfolioView({
    super.key,
    required this.model,
    this.hidden = false,
    this.onToggleHidden,
    this.onBannerAction,
    this.onPosition,
    this.onOrder,
    this.onBrowse,
    this.onTab,
  });

  final PortfolioModel? model;
  final bool hidden;
  final VoidCallback? onToggleHidden;
  final VoidCallback? onBannerAction;
  final ValueChanged<PositionRow>? onPosition;
  final ValueChanged<OrderRow>? onOrder;
  final VoidCallback? onBrowse;
  final ValueChanged<AuraTab>? onTab;

  @override
  Widget build(BuildContext context) {
    final m = model;
    final top = MediaQuery.paddingOf(context).top;
    return ColoredBox(
      color: AuraColors.bg,
      child: Stack(
        children: [
          ListView(
            padding: EdgeInsets.fromLTRB(16, top + 15, 16, 128),
            children: [
              if (m == null) ...[
                const AuraSkeleton(width: 120, height: 10),
                const SizedBox(height: 14),
                const AuraSkeleton(width: 230, height: 34),
                const SizedBox(height: 14),
                const AuraSkeleton(width: 170, height: 10),
                const SizedBox(height: 28),
                const AuraSkeleton(height: 120),
              ] else ...[
                AuraHeroCard(
                  label: netWorthToday,
                  value: m.netWorth,
                  abs: m.dayAbs,
                  pct: m.dayPct,
                  period: today,
                  hideable: true,
                  hidden: hidden,
                  onToggleHidden: onToggleHidden,
                ),
                const SizedBox(height: 20),
                AuraStatGrid(
                  columns: 3,
                  rowGap: 6,
                  children: [
                    for (final (label, value, tone) in m.stats)
                      AuraStatCard(label: label, value: value, tone: tone),
                  ],
                ),
                if (m.banner case final banner?) ...[
                  const SizedBox(height: 20),
                  ModelBanner(banner, onAction: onBannerAction),
                ],
                if (m.empty)
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: AuraEmptyState(
                      icon: AuraIcons.portfolio,
                      title: noPositionsTitle,
                      body: noPositionsBody,
                      action: browseTheMarket,
                      onAction: onBrowse,
                    ),
                  ),
                if (m.positions.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const AuraSectionHeader(positionsHeading),
                  for (final x in m.positions)
                    AuraStockRow(
                      ticker: x.ticker,
                      name: x.name,
                      initial: x.name.characters.first,
                      tag: x.tag,
                      tagTone: x.tagTone,
                      price: x.price,
                      abs: x.pnl,
                      pct: x.pnlPct,
                      sparkline: false,
                      onTap: onPosition == null ? null : () => onPosition!(x),
                    ),
                ],
                if (m.orders.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const AuraSectionHeader(openOrdersHeading),
                  AuraNavCard(
                    children: [
                      for (final o in m.orders)
                        AuraNavRow(
                          icon: AuraIcons.clock,
                          title: o.title,
                          subtitle: o.subtitle,
                          trailing: cancelLabel,
                          onTap: onOrder == null ? null : () => onOrder!(o),
                        ),
                    ],
                  ),
                ],
              ],
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 30,
            child: Center(
              child: AuraTabBar(active: AuraTab.portfolio, onSelect: onTab),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Cancel this order?", over the Portfolio.
class CancelOrderSheet extends StatelessWidget {
  const CancelOrderSheet({
    super.key,
    required this.order,
    this.busy = false,
    this.onCancel,
    this.onKeep,
  });

  final OrderRow order;
  final bool busy;
  final VoidCallback? onCancel;
  final VoidCallback? onKeep;

  @override
  Widget build(BuildContext context) {
    return AuraSheet(
      title: cancelOrderTitle,
      onClose: onKeep,
      children: [
        Text(
          '${order.title}. $cancelOrderBody',
          style: AuraType.body.copyWith(color: AuraColors.inkSecondary),
        ),
        AuraButton(
          busy ? cancelingOrder : cancelOrder,
          variant: AuraButtonVariant.primary,
          block: true,
          onPressed: busy ? null : onCancel,
        ),
        AuraButton(
          keepIt,
          variant: AuraButtonVariant.ghost,
          size: AuraButtonSize.md,
          block: true,
          onPressed: onKeep,
        ),
      ],
    );
  }
}
