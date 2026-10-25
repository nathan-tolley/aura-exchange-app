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
import '../widgets/aura_status_chip.dart';
import 'fixtures/frames.dart';
import 'fixtures/onboarding.dart';
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

  /// The golden's file name in test/goldens/screens: the reference's name,
  /// or the id and label for a screen that isn't drawn ("S01c-SignInWrongCode").
  String get golden => reference ?? '$id-${_pascal(label)}';
}

String _pascal(String label) => label
    .split(RegExp('[^A-Za-z0-9]+'))
    .where((w) => w.isNotEmpty)
    .map((w) => w[0].toUpperCase() + w.substring(1))
    .join();

/// Every screen state built so far. A screen is done when every state in its
/// SCREENS.md row is here (CLAUDE.md → Every state exists).
final List<GalleryScreen> screenStates = [
  GalleryScreen('S01a', 'Sign in, email', (_) => signInEmail()),
  GalleryScreen('S01b', 'Sign in, code sent', (_) => signInCodeSent()),
  GalleryScreen('S01c', 'Sign in, wrong code', (_) => signInWrongCode()),
  GalleryScreen('S01d', 'Sign in, code expired', (_) => signInCodeExpired()),
  GalleryScreen('S01e', 'Sign in, offline', (_) => signInNoNetwork()),
  GalleryScreen('S04a', 'Create an exchange, name', (_) => createName()),
  GalleryScreen(
    'S04b',
    'Create an exchange, timezone and hours',
    (_) => createHours(),
  ),
  GalleryScreen(
    'S04c',
    'Create an exchange, picking a timezone',
    (_) => createZoneSheet(),
  ),
  GalleryScreen('S04d', 'Create an exchange, offline', (_) => createNoNetwork()),
  GalleryScreen(
    'S04e',
    'Invite friends, making the link',
    (_) => inviteLoading(),
  ),
  GalleryScreen('S04f', 'Invite friends, link copied', (_) => inviteReady()),
  GalleryScreen('S04g', 'Invite friends, offline', (_) => inviteOfflineState()),
  GalleryScreen('S04h', 'Waiting for friends', (_) => waiting()),
  GalleryScreen(
    'S04i',
    'Waiting for friends, loading',
    (_) => waitingLoading(),
  ),
  GalleryScreen('S24a', 'Launch, offline', (_) => launchOffline()),
  GalleryScreen(
    'S24b',
    'Launch, update required',
    (_) => launchUpdateRequired(),
  ),
  GalleryScreen('S24c', 'Launch, unknown error', (_) => launchUnknown()),
  GalleryScreen('S24d', 'Launch, exchange down', (_) => launchExchangeDown()),
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

/// A sheet over a screen, the screen below the status bar as in W05.
Widget _sheetOver(Widget page, Widget sheet) => Builder(
  builder: (context) => sheetOver(
    Padding(
      padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
      child: page,
    ),
    sheet,
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
