import 'package:decimal/decimal.dart';
import 'package:flutter/widgets.dart';

import '../../api/generated/export.dart' hide Freshness;
import '../../data/live_market.dart';
import '../../design/icons.dart';
import '../../design/tokens.dart';
import '../../design/widgets/aura_avatar.dart';
import '../../design/widgets/aura_button.dart';
import '../../design/widgets/aura_empty_state.dart';
import '../../design/widgets/aura_hero_card.dart';
import '../../design/widgets/aura_nav_card.dart';
import '../../design/widgets/aura_quote_card.dart';
import '../../design/widgets/aura_section_header.dart';
import '../../design/widgets/aura_sheet.dart';
import '../../design/widgets/aura_skeleton.dart';
import '../../design/widgets/aura_slide_to_confirm.dart';
import '../../design/widgets/aura_stat_card.dart';
import '../../design/widgets/aura_tab_bar.dart';
import '../../design/widgets/aura_toggle_row.dart';
import '../../format/money.dart';
import '../../format/ticker.dart';
import '../../format/time.dart';
import '../../l10n/strings.dart';
import '../shared/banner_model.dart';
import '../shared/top_bar.dart';

/// You (SCREENS.md #30), worded: your listing as the market sees it, your
/// stats, and the super-injunctions you have left.
@immutable
class YouModel {
  const YouModel({
    required this.name,
    required this.email,
    this.ticker,
    this.price,
    this.changeAbs,
    this.changePct,
    this.stats = const [],
    this.analyst,
  });

  final String name;
  final String email;

  /// Null when you're not listed.
  final String? ticker;
  final Decimal? price;
  final Decimal? changeAbs;
  final Decimal? changePct;
  final List<(String, String)> stats;
  final (String, String)? analyst;

  bool get listed => ticker != null;
}

YouModel youModel({
  required User user,
  required Membership membership,
  required ListingDetail? listing,
  required LiveListing? live,
}) {
  final ref = membership.listing;
  if (ref == null || listing == null) {
    return YouModel(
      name: user.displayName,
      email: user.email,
      ticker: ref == null ? null : formatTicker(ref.ticker),
    );
  }
  final analyst = listing.analyst;
  return YouModel(
    name: user.displayName,
    email: user.email,
    ticker: formatTicker(ref.ticker),
    price: live?.price ?? Decimal.parse(listing.price),
    changeAbs: live?.changeAbs ?? Decimal.parse(listing.changeAbs),
    changePct: live?.changePct ?? Decimal.parse(listing.changePct),
    stats: [
      (statSeasonHigh, formatMoney(Decimal.parse(listing.seasonHigh))),
      (statSeasonLow, formatMoney(Decimal.parse(listing.seasonLow))),
      (
        statShortInterest,
        percentWhole(Decimal.parse(listing.shortInterestPct)),
      ),
      (statSuperInjunctions, leftOf(membership.superInjunctionsLeft, null)),
    ],
    analyst: analyst == null ? null : (quoted(analyst.note), theAnalyst),
  );
}

/// The You tab: who you are on the exchange, your stock, and where to go
/// next. [model] null is loading.
class YouView extends StatelessWidget {
  const YouView({
    super.key,
    required this.model,
    this.onStock,
    this.onInvite,
    this.onSettings,
    this.onList,
    this.onTab,
  });

  final YouModel? model;
  final VoidCallback? onStock;
  final VoidCallback? onInvite;
  final VoidCallback? onSettings;
  final VoidCallback? onList;
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
                const Row(
                  spacing: 12,
                  children: [
                    AuraSkeleton(
                      width: 40,
                      height: 40,
                      radius: AuraRadius.full,
                    ),
                    AuraSkeleton(width: 120, height: 12),
                  ],
                ),
                const SizedBox(height: 28),
                const AuraSkeleton(width: 210, height: 34),
                const SizedBox(height: 28),
                const AuraSkeleton(height: 120),
              ] else ...[
                Row(
                  spacing: 12,
                  children: [
                    AuraAvatar(m.name.characters.first, size: 40),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 2,
                        children: [
                          Text(m.ticker ?? m.name, style: AuraType.title),
                          Text(
                            m.ticker == null ? m.email : m.name,
                            style: AuraType.footnote.copyWith(
                              color: AuraColors.inkTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (m.price case final price?) ...[
                  const SizedBox(height: 24),
                  AuraHeroCard(
                    label: yourStockToday,
                    value: price,
                    abs: m.changeAbs,
                    pct: m.changePct,
                    period: today,
                  ),
                  const SizedBox(height: 20),
                  AuraStatGrid(
                    rowGap: 6,
                    children: [
                      for (final (label, value) in m.stats)
                        AuraStatCard(label: label, value: value),
                    ],
                  ),
                  if (m.analyst case (final quote, final source)) ...[
                    const SizedBox(height: 20),
                    AuraQuoteCard(quote: quote, source: source),
                  ],
                ] else if (!m.listed)
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: AuraEmptyState(
                      icon: AuraIcons.you,
                      title: notListedTitle,
                      body: notListedBody,
                      action: listYourself,
                      onAction: onList,
                    ),
                  ),
                const SizedBox(height: 24),
                AuraNavCard(
                  children: [
                    if (m.listed)
                      AuraNavRow(
                        icon: AuraIcons.line,
                        title: yourStockPage,
                        subtitle: yourStockPageNote,
                        onTap: onStock,
                      ),
                    AuraNavRow(
                      icon: AuraIcons.plus,
                      title: inviteSomeone,
                      subtitle: inviteSomeoneNote,
                      onTap: onInvite,
                    ),
                    AuraNavRow(
                      icon: AuraIcons.filter,
                      title: settingsTitle,
                      subtitle: settingsNote,
                      onTap: onSettings,
                    ),
                  ],
                ),
              ],
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 30,
            child: Center(
              child: AuraTabBar(active: AuraTab.you, onSelect: onTab),
            ),
          ),
        ],
      ),
    );
  }
}

/// The notification types Settings can turn off, in order: (type, title,
/// note). Margin warnings and liquidations stay on.
const settingsTypes = [
  ('RUMOR_ABOUT_YOU', notifyRumors, notifyRumorsNote),
  ('RULING_ABOUT_YOU', notifyRulings, null),
  ('HALT_VOTE', notifyHalts, null),
  ('ORDER_FILLED', notifyFills, null),
  ('HOLDING_MOVED', notifyMoves, null),
  ('PRICE_ALERT', notifyAlerts, null),
];

/// Settings (SCREENS.md #31): what reaches you, quiet hours, opting out of
/// being listed, signing out. [prefs] null is loading.
class SettingsView extends StatelessWidget {
  const SettingsView({
    super.key,
    required this.prefs,
    required this.email,
    this.listed = true,
    this.banner,
    this.onBack,
    this.onType,
    this.onBells,
    this.onQuiet,
    this.onOptOut,
    this.onSignOut,
  });

  final NotificationPrefs? prefs;
  final String email;
  final bool listed;

  /// A setting that didn't save.
  final BannerModel? banner;
  final VoidCallback? onBack;
  final void Function(String type, bool on)? onType;
  final ValueChanged<bool>? onBells;
  final ValueChanged<bool>? onQuiet;
  final VoidCallback? onOptOut;
  final VoidCallback? onSignOut;

  @override
  Widget build(BuildContext context) {
    final p = prefs;
    final top = MediaQuery.paddingOf(context).top;
    final quiet = p?.quietHours;
    return ColoredBox(
      color: AuraColors.bg,
      child: ListView(
        padding: EdgeInsets.only(top: top, bottom: 64),
        children: [
          TopBar(onPressed: onBack),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 15, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(settingsTitle, style: AuraType.title),
                if (banner case final banner?) ...[
                  const SizedBox(height: 16),
                  ModelBanner(banner),
                ],
                const SizedBox(height: 24),
                const AuraSectionHeader(notificationsHeading),
                if (p == null)
                  for (var i = 0; i < 5; i++)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: AuraSkeleton(height: 44),
                    )
                else ...[
                  for (final (type, title, note) in settingsTypes)
                    AuraToggleRow(
                      title: title,
                      subtitle: switch ((type, p.holdingMovedPct)) {
                        ('HOLDING_MOVED', final pct?) => notifyMovesNote(
                          Decimal.parse(pct),
                        ),
                        _ => note,
                      },
                      value: !(p.disabledTypes ?? const []).contains(type),
                      onChanged: onType == null
                          ? null
                          : (v) => onType!(type, v),
                    ),
                  AuraToggleRow(
                    title: notifyBells,
                    value: p.bells ?? true,
                    onChanged: onBells,
                  ),
                  const AuraToggleRow(
                    title: notifyMargin,
                    subtitle: notifyMarginNote,
                    value: true,
                  ),
                  const SizedBox(height: 24),
                  AuraToggleRow(
                    title: quietHoursLabel,
                    subtitle: quiet == null
                        ? quietHoursOff
                        : quietHoursRange(
                            formatWallClock(quiet.start),
                            formatWallClock(quiet.end),
                          ),
                    value: quiet != null,
                    onChanged: onQuiet,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    inboxOnlyNote,
                    style: AuraType.footnote.copyWith(
                      color: AuraColors.inkTertiary,
                    ),
                  ),
                ],
                if (listed) ...[
                  const SizedBox(height: 28),
                  const AuraSectionHeader(yourListingHeading),
                  AuraNavCard(
                    children: [
                      AuraNavRow(
                        icon: AuraIcons.eyeOff,
                        title: optOut,
                        subtitle: optOutNote,
                        onTap: onOptOut,
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 28),
                const AuraSectionHeader(accountHeading),
                AuraNavCard(
                  children: [
                    AuraNavRow(
                      icon: AuraIcons.lock,
                      title: signOut,
                      subtitle: '$email · $signOutNote',
                      onTap: onSignOut,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "Delist yourself?": it moves holders' money, so it ends in the slide.
class DelistSheet extends StatelessWidget {
  const DelistSheet({
    super.key,
    required this.exchange,
    this.onConfirmed,
    this.onStay,
  });

  final String exchange;
  final VoidCallback? onConfirmed;
  final VoidCallback? onStay;

  @override
  Widget build(BuildContext context) {
    return AuraSheet(
      title: delistTitle,
      onClose: onStay,
      children: [
        Text(
          delistBody(exchange),
          style: AuraType.body.copyWith(
            height: 22 / 15,
            color: AuraColors.inkSecondary,
          ),
        ),
        AuraSlideToConfirm(label: slideToDelist, onConfirmed: onConfirmed),
        AuraButton(
          stayListed,
          variant: AuraButtonVariant.ghost,
          size: AuraButtonSize.md,
          block: true,
          onPressed: onStay,
        ),
      ],
    );
  }
}
