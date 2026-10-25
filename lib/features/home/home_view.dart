import 'package:decimal/decimal.dart';
import 'package:flutter/widgets.dart';

import '../../design/icons.dart';
import '../../design/text.dart';
import '../../design/tokens.dart';
import '../../design/tone.dart';
import '../../design/widgets/aura_banner.dart';
import '../../design/widgets/aura_button.dart';
import '../../design/widgets/aura_hero_card.dart';
import '../../design/widgets/aura_icon_button.dart';
import '../../design/widgets/aura_nav_card.dart';
import '../../design/widgets/aura_quote_card.dart';
import '../../design/widgets/aura_search_field.dart';
import '../../design/widgets/aura_section_header.dart';
import '../../design/widgets/aura_status_chip.dart';
import '../../design/widgets/aura_stock_row.dart';
import '../../design/widgets/aura_tab_bar.dart';
import '../../design/widgets/aura_tape.dart';

/// Everything Home shows, already decided and worded (`home_model.dart`
/// builds it from the market, the portfolio and freshness).
@immutable
class HomeViewModel {
  const HomeViewModel({
    required this.tape,
    required this.searchPlaceholder,
    required this.heroLabel,
    required this.netWorth,
    this.seasonAbs,
    this.seasonPct,
    this.heroNote,
    this.hideable = true,
    this.actions,
    this.offlineBanner,
    this.marketBanner,
    this.watchlist,
    this.ipo,
    this.tapeBadge = false,
  });

  final List<AuraTapeItem> tape;
  final String searchPlaceholder;

  /// "Net worth · at the close", "Net worth · as of 9:41 pm".
  final String heroLabel;
  final Decimal netWorth;
  final Decimal? seasonAbs;
  final Decimal? seasonPct;

  /// IPO day: "Your starting cash. The market opens at 3 listings."
  final String? heroNote;
  final bool hideable;

  /// File an event and Trade. Null on IPO day, when there's nothing to do
  /// with them yet.
  final HomeActions? actions;

  /// Above the hero (W11): the connection is the first thing to know.
  final HomeBanner? offlineBanner;

  /// Under the actions (W09): closed, halted.
  final HomeBanner? marketBanner;
  final HomeWatchlist? watchlist;
  final HomeIpo? ipo;
  final bool tapeBadge;
}

@immutable
class HomeActions {
  const HomeActions({required this.trade, required this.enabled});

  /// "Trade", or "Set an order" while the market is closed.
  final String trade;

  /// False while offline; the offline banner says why.
  final bool enabled;
}

@immutable
class HomeBanner {
  const HomeBanner({
    required this.tone,
    required this.title,
    this.body,
    this.action,
  });

  final AuraBannerTone tone;
  final String title;
  final String? body;
  final String? action;
}

@immutable
class HomeWatchlist {
  const HomeWatchlist({required this.rows, this.asOf});

  final List<HomeRow> rows;

  /// "As of 9:41 pm" when the prices aren't live.
  final String? asOf;
}

@immutable
class HomeRow {
  const HomeRow({
    required this.id,
    required this.ticker,
    required this.name,
    required this.price,
    required this.abs,
    required this.pct,
    required this.points,
    this.tag,
    this.tagTone = AuraTone.neutral,
  });

  final String id;
  final String ticker;
  final String name;
  final Decimal price;
  final Decimal abs;
  final Decimal pct;
  final List<double> points;
  final String? tag;
  final AuraTone tagTone;
}

/// IPO day (W12): who's listed so far, and the first line the tape will run.
@immutable
class HomeIpo {
  const HomeIpo({
    required this.title,
    required this.aside,
    required this.rows,
    required this.teaserLabel,
    required this.teaser,
    required this.teaserSource,
  });

  /// "1 of 3 listed".
  final String title;

  /// "You can't trade yourself".
  final String aside;
  final List<HomeIpoRow> rows;
  final String teaserLabel;

  /// The Analyst's line, from the server as-is (curly quotes included).
  final String teaser;
  final String teaserSource;
}

@immutable
class HomeIpoRow {
  const HomeIpoRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final AuraIcons icon;
  final String title;
  final String subtitle;

  /// "Almost", "Nudge".
  final String? trailing;
}

/// Home (SCREENS.md #5): tape, search and bell, net worth, File an event and
/// Trade, a banner when the market or the connection needs one, and the
/// watchlist. The tab bar floats over the bottom.
class HomeView extends StatelessWidget {
  const HomeView({
    super.key,
    required this.model,
    this.onBell,
    this.onToggleHidden,
    this.onFile,
    this.onTrade,
    this.onRetry,
    this.onMarketBannerAction,
    this.onEditWatchlist,
    this.onRow,
    this.onIpoRow,
    this.onTab,
  });

  final HomeViewModel model;
  final VoidCallback? onBell;
  final VoidCallback? onToggleHidden;
  final VoidCallback? onFile;
  final VoidCallback? onTrade;
  final VoidCallback? onRetry;
  final VoidCallback? onMarketBannerAction;
  final VoidCallback? onEditWatchlist;
  final ValueChanged<String>? onRow;
  final ValueChanged<int>? onIpoRow;
  final ValueChanged<AuraTab>? onTab;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final m = model;
    final actions = m.actions;
    return ColoredBox(
      color: AuraColors.bg,
      child: Stack(
        children: [
          ListView(
            padding: EdgeInsets.fromLTRB(16, top, 16 - _bellOverhang, 128),
            children: [
              _gutter(AuraTape(items: m.tape)),
              const SizedBox(height: 12),
              // The bell's 44 pt hit area reaches 10 pt into the right
              // gutter so its glyph lines up with the edge (DESIGN.md →
              // Layout): this row's right padding is 6, not 16, and every
              // other row adds the difference back with _gutter.
              Row(
                spacing: 6,
                children: [
                  Expanded(
                    child: AuraSearchField(
                      placeholder: m.searchPlaceholder,
                      enabled: m.ipo == null,
                    ),
                  ),
                  AuraIconButton(
                    icon: AuraIcons.bell,
                    label: 'Notifications',
                    onPressed: onBell,
                  ),
                ],
              ),
              if (m.offlineBanner case final banner?) ...[
                const SizedBox(height: 14),
                _gutter(_Banner(banner, onAction: onRetry)),
              ],
              // The search row is 44 pt (the bell's hit area) around a 40 pt
              // field, so this gap looks 2 pt bigger after it.
              SizedBox(height: m.offlineBanner == null ? 15 : 19),
              _gutter(
                AuraHeroCard(
                  label: m.heroLabel,
                  value: m.netWorth,
                  abs: m.seasonAbs,
                  pct: m.seasonPct,
                  period: m.seasonAbs == null ? null : 'this season',
                  note: m.heroNote,
                  hideable: m.hideable,
                  onToggleHidden: onToggleHidden,
                ),
              ),
              if (actions != null) ...[
                const SizedBox(height: 19),
                _gutter(
                  Row(
                    spacing: 8,
                    children: [
                      Expanded(
                        child: AuraButton(
                          'File an event',
                          icon: AuraIcons.file,
                          variant: AuraButtonVariant.primary,
                          size: AuraButtonSize.md,
                          block: true,
                          onPressed: actions.enabled ? onFile : null,
                        ),
                      ),
                      Expanded(
                        child: AuraButton(
                          actions.trade,
                          icon: AuraIcons.trade,
                          size: AuraButtonSize.md,
                          block: true,
                          onPressed: actions.enabled ? onTrade : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (m.marketBanner case final banner?) ...[
                const SizedBox(height: 22),
                _gutter(_Banner(banner, onAction: onMarketBannerAction)),
              ],
              if (m.watchlist case final watchlist?) ...[
                SizedBox(height: m.marketBanner == null ? 20 : 18),
                _gutter(
                  AuraSectionHeader(
                    'Watchlist',
                    status: watchlist.asOf == null ? null : AuraStatus.delayed,
                    statusLabel: watchlist.asOf,
                    action: watchlist.asOf == null ? 'Edit' : null,
                    onAction: onEditWatchlist,
                  ),
                ),
                for (final row in watchlist.rows)
                  _gutter(
                    AuraStockRow(
                      ticker: row.ticker,
                      name: row.name,
                      initial: row.name.characters.first,
                      tag: row.tag,
                      tagTone: row.tagTone,
                      price: row.price,
                      abs: row.abs,
                      pct: row.pct,
                      points: row.points,
                      onTap: onRow == null ? null : () => onRow!(row.id),
                    ),
                  ),
              ],
              if (m.ipo case final ipo?) _gutter(_Ipo(ipo, onRow: onIpoRow)),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 30,
            child: Center(
              child: AuraTabBar(
                active: AuraTab.home,
                tapeBadge: m.tapeBadge,
                onSelect: onTab,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// How far the bell's hit area reaches into the right gutter.
const _bellOverhang = 10.0;

/// The list's right padding is short by [_bellOverhang] for the search row;
/// everything else adds it back.
Widget _gutter(Widget child) => Padding(
  padding: const EdgeInsets.only(right: _bellOverhang),
  child: child,
);

class _Banner extends StatelessWidget {
  const _Banner(this.banner, {this.onAction});

  final HomeBanner banner;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => AuraBanner(
    tone: banner.tone,
    title: banner.title,
    body: banner.body,
    action: banner.action,
    onAction: banner.action == null ? null : onAction,
  );
}

class _Ipo extends StatelessWidget {
  const _Ipo(this.ipo, {this.onRow});

  final HomeIpo ipo;
  final ValueChanged<int>? onRow;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 27),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(child: Text(ipo.title, style: AuraType.heading)),
            auraLiftFootnote(
              Text(
                ipo.aside,
                style: AuraType.footnote.copyWith(
                  color: AuraColors.inkTertiary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        AuraNavCard(
          children: [
            for (final (i, row) in ipo.rows.indexed)
              AuraNavRow(
                icon: row.icon,
                title: row.title,
                subtitle: row.subtitle,
                trailing: row.trailing,
                onTap: onRow == null ? null : () => onRow!(i),
              ),
          ],
        ),
        const SizedBox(height: 26),
        auraLiftFootnote(
          Text(
            ipo.teaserLabel,
            style: AuraType.footnote.copyWith(color: AuraColors.inkTertiary),
          ),
        ),
        const SizedBox(height: 8),
        AuraQuoteCard(quote: ipo.teaser, source: ipo.teaserSource),
      ],
    );
  }
}
