import 'package:decimal/decimal.dart';
import 'package:flutter/widgets.dart';

import '../../features/events/about_you_views.dart';
import '../../features/home/home_view.dart';
import '../../features/portfolio/bankruptcy_view.dart';
import '../../features/portfolio/liquidated_view.dart';
import '../../features/stock/halted_view.dart';
import '../../features/stock/short_view.dart';
import '../../features/stock/stock_header.dart';
import '../../features/system/exchange_down_view.dart';
import '../../features/trade/trade_sheet_view.dart';
import '../../l10n/strings.dart';
import '../tokens.dart';
import '../widgets/aura_status_chip.dart';
import 'screen_fixtures.dart';

/// A screen in one of its states, built from fixtures. The State Gallery
/// opens it full size, and `test/goldens/screens_test.dart` compares it with
/// its drawn reference when it has one.
class GalleryScreen {
  const GalleryScreen(this.id, this.label, this.build, {this.reference});

  /// "W09".
  final String id;

  /// "Home, closed".
  final String label;
  final WidgetBuilder build;

  /// The drawn reference's file name in design/reference/screens, without
  /// `.png`: "W09-MarketClosed".
  final String? reference;
}

/// Every screen state built so far. A screen is done when every state in its
/// SCREENS.md row is here (CLAUDE.md → Every state exists).
final List<GalleryScreen> screenStates = [
  GalleryScreen(
    'W09',
    'Home, closed',
    (_) => _home(homeClosed()),
    reference: 'W09-MarketClosed',
  ),
  GalleryScreen(
    'W11',
    'Home, offline',
    (_) => _home(homeOffline()),
    reference: 'W11-Offline',
  ),
  GalleryScreen(
    'W12',
    'Home, IPO day',
    (_) => _home(homeIpoDay()),
    reference: 'W12-EmptyExchange',
  ),
  GalleryScreen(
    'W05',
    'Trade sheet, rejected',
    (_) => _sheetOver(
      _annaPage('124.10'),
      TradeTicketView(
        model: tradeRejected(),
        onClose: _noop,
        onOrderType: (_) {},
        onQuantity: (_) {},
        onBannerAction: _noop,
        onTrade: _noop,
      ),
    ),
    reference: 'W05-TradeRejected',
  ),
  GalleryScreen(
    'W06',
    'Trade sheet, requote',
    (_) => _sheetOver(
      _annaPage('125.36'),
      RequoteView(
        model: requote(),
        onClose: _noop,
        onConfirmed: _noop,
        onDecline: _noop,
      ),
    ),
    reference: 'W06-Requote',
  ),
  GalleryScreen(
    'W10',
    'Stock page, halted for a vote',
    (_) => HaltedStockView(model: halted(), onBack: _noop, onVote: (_) {}),
    reference: 'W10-Halted',
  ),
  GalleryScreen(
    'W07',
    'Stock page, your short near liquidation',
    (_) => ShortPageView(
      model: shortNearLiquidation(),
      onBack: _noop,
      onCoverPart: _noop,
      onCoverAll: _noop,
    ),
    reference: 'W07-MarginWarning',
  ),
  GalleryScreen(
    'W08',
    'Liquidated',
    (_) => LiquidatedView(
      model: liquidated(),
      onClose: _noop,
      onSeeStock: _noop,
      onPortfolio: _noop,
    ),
    reference: 'W08-Liquidated',
  ),
  GalleryScreen(
    'W04',
    'Chapter 7 offer',
    (_) => BankruptcyView(
      model: bankrupt(),
      onBack: _noop,
      onFile: _noop,
      onKeepGoing: _noop,
    ),
    reference: 'W04-Bankruptcy',
  ),
  GalleryScreen(
    'W01',
    'A rumor about you',
    (_) => RumorAboutYouView(
      model: rumorOnYou(),
      onClose: _noop,
      onRespond: (_) {},
    ),
    reference: 'W01-RumorAboutYou',
  ),
  GalleryScreen(
    'W02',
    'A ruling on you',
    (_) =>
        RulingOnYouView(model: rulingOnYou(), onClose: _noop, onAction: (_) {}),
    reference: 'W02-RulingOnYou',
  ),
  GalleryScreen(
    'W03',
    'An SEC charge',
    (_) => SecChargeView(model: secCharge(), onClose: _noop, onAction: (_) {}),
    reference: 'W03-SECCharge',
  ),
  GalleryScreen(
    'W13',
    'The exchange is down',
    (_) => ExchangeDownView(model: exchangeDown(), onRetry: _noop),
    reference: 'W13-ServerError',
  ),
];

/// $ANNA's stock page as it shows behind the trade sheet.
Widget _annaPage(String price) => StockHeader(
  status: AuraStatus.open,
  line: stockLine(r'$ANNA', 'Anna'),
  price: Decimal.parse(price),
  onBack: _noop,
);

/// A sheet presented over a screen, as the app's modal route draws it: the
/// screen on `bg` under the scrim, the sheet at the bottom.
Widget _sheetOver(Widget page, Widget sheet) => Builder(
  builder: (context) => ColoredBox(
    color: AuraColors.bg,
    child: Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
          child: page,
        ),
        const Positioned.fill(child: ColoredBox(color: AuraColors.scrim)),
        Align(alignment: Alignment.bottomCenter, child: sheet),
      ],
    ),
  ),
);

/// Home with every control live, as on the phone, so nothing in the gallery
/// or a golden looks disabled unless the state disables it.
Widget _home(HomeViewModel model) => HomeView(
  model: model,
  onBell: _noop,
  onToggleHidden: _noop,
  onFile: _noop,
  onTrade: _noop,
  onRetry: _noop,
  onMarketBannerAction: _noop,
  onEditWatchlist: _noop,
  onRow: (_) {},
  onIpoRow: (_) {},
  onTab: (_) {},
);

void _noop() {}
