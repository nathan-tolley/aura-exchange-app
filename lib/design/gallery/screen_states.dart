import 'package:decimal/decimal.dart';
import 'package:flutter/widgets.dart';

import '../../features/events/about_you_views.dart';
import '../../features/home/home_loading_view.dart';
import '../../features/home/home_view.dart';
import '../../features/portfolio/bankruptcy_view.dart';
import '../../features/portfolio/liquidated_view.dart';
import '../../features/stock/halted_view.dart';
import '../../features/stock/short_view.dart';
import '../../features/stock/stock_header.dart';
import '../../features/system/exchange_down_view.dart';
import '../../features/trade/trade_sheet_view.dart';
import '../../l10n/strings.dart' show stockLine;
import '../widgets/aura_status_chip.dart';
import 'fixtures/events.dart';
import 'fixtures/frames.dart';
import 'fixtures/market.dart';
import 'fixtures/onboarding.dart';
import 'fixtures/stock.dart';
import 'fixtures/tape.dart';
import 'fixtures/trade.dart';
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
  GalleryScreen('S02a', 'Join, the invite', (_) => joinPreview()),
  GalleryScreen('S02b', 'Join, invite expired', (_) => joinExpired()),
  GalleryScreen('S02c', 'Join, exchange full', (_) => joinFull()),
  GalleryScreen('S02d', 'Join, link not found', (_) => joinNotFound()),
  GalleryScreen('S02e', 'Join, loading', (_) => joinLoading()),
  GalleryScreen('S02f', 'Join, offline', (_) => joinNoNetwork()),
  GalleryScreen('S03a', 'Your IPO, consent', (_) => ipoConsent()),
  GalleryScreen('S03b', 'Your IPO, ticker free', (_) => ipoFree()),
  GalleryScreen('S03c', 'Your IPO, ticker taken', (_) => ipoTaken()),
  GalleryScreen('S03d', 'Your IPO, typing', (_) => ipoTyping()),
  GalleryScreen('S03e', 'Your IPO, offline', (_) => ipoNoNetwork()),
  GalleryScreen('S03f', 'Your IPO, listed', (_) => ipoListed()),
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
  GalleryScreen(
    'S04d',
    'Create an exchange, offline',
    (_) => createNoNetwork(),
  ),
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
  // No watchlist editor yet, so no Edit link (as the live screen).
  GalleryScreen(
    'S05a',
    'Home, default',
    (_) => HomeView(
      model: homeOpen(),
      onBell: _noop,
      onToggleHidden: _noop,
      onFile: _noop,
      onTrade: _noop,
      onRow: (_) {},
      onTab: (_) {},
    ),
  ),
  GalleryScreen(
    'S05b',
    'Home, loading',
    (_) => HomeLoadingView(onBell: _noop, onTab: (_) {}),
  ),
  GalleryScreen('S06a', 'Market, by change', (_) => marketSorted()),
  GalleryScreen('S06b', 'Market, a halted row', (_) => marketHaltedRow()),
  GalleryScreen('S06c', 'Market, search results', (_) => marketSearch()),
  GalleryScreen('S06d', 'Market, no results', (_) => marketNoResults()),
  GalleryScreen('S06e', 'Market, loading', (_) => marketLoading()),
  GalleryScreen('S06f', 'Market, offline', (_) => marketOffline()),
  GalleryScreen('S07a', 'Stock page, default', (_) => stockDefault()),
  GalleryScreen('S07b', 'Stock page, your own stock', (_) => stockYours()),
  GalleryScreen(
    'S07c',
    'Stock page, closed with indicated price',
    (_) => stockClosedIndicated(),
  ),
  GalleryScreen(
    'S07d',
    'Stock page, rumor pending',
    (_) => stockRumorPending(),
  ),
  GalleryScreen('S07e', 'Stock page, delisted', (_) => stockDelisted()),
  GalleryScreen('S07f', 'Stock page, offline', (_) => stockOfflineState()),
  GalleryScreen(
    'S07g',
    'Stock page, chart loading',
    (_) => stockChartLoading(),
  ),
  GalleryScreen('S07h', 'Stock page, tape', (_) => stockTape()),
  GalleryScreen('S07i', 'Stock page, analyst', (_) => stockAnalyst()),
  GalleryScreen(
    'S08b',
    'Stock overview, no events yet',
    (_) => stockNoEvents(),
  ),
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
  GalleryScreen('S09a', 'Trade sheet, buy', (_) => tradeBuy()),
  GalleryScreen('S09b', 'Trade sheet, sell', (_) => tradeSell()),
  GalleryScreen(
    'S09c',
    'Trade sheet, short with liquidation price',
    (_) => tradeShort(),
  ),
  GalleryScreen('S09d', 'Trade sheet, cover', (_) => tradeCover()),
  GalleryScreen('S09e', 'Trade sheet, limit order', (_) => tradeLimit()),
  GalleryScreen('S09f', 'Trade sheet, stop-loss', (_) => tradeStopLoss()),
  GalleryScreen('S10a', 'Trade, quote expiring', (_) => tradeExpiring()),
  GalleryScreen('S10b', 'Trade, rejected size', (_) => tradeTooLarge()),
  GalleryScreen('S10c', 'Trade, rejected short cap', (_) => tradeShortCap()),
  GalleryScreen('S10d', 'Trade, filled', (_) => tradeFilled()),
  GalleryScreen('S10e', 'Trade, resting order', (_) => tradeResting()),
  GalleryScreen('S10f', 'Trade, getting a price', (_) => tradeQuoting()),
  GalleryScreen('S10g', 'Trade, offline', (_) => tradeNoNetwork()),
  GalleryScreen('S11a', 'File an event, pick subject', (_) => fileSubject()),
  GalleryScreen('S11b', 'File an event, compose', (_) => fileCompose()),
  GalleryScreen('S11c', 'File an event, about yourself', (_) => fileSelf()),
  GalleryScreen('S11d', 'File an event, daily limit', (_) => fileLimit()),
  GalleryScreen('S11e', 'File an event, discard', (_) => fileDiscard()),
  GalleryScreen('S11f', 'File an event, nothing typed', (_) => fileEmpty()),
  GalleryScreen('S12a', 'Your filing, sending', (_) => filingSending()),
  GalleryScreen('S12b', 'Your filing, rumor live', (_) => filingRumor()),
  GalleryScreen('S12c', 'Your filing, ruled', (_) => filingRuled()),
  GalleryScreen('S12d', 'Your filing, halted', (_) => filingHalted()),
  GalleryScreen('S12e', 'Your filing, voided', (_) => filingVoided()),
  GalleryScreen('S12f', 'Your filing, unsent', (_) => filingUnsent()),
  GalleryScreen('S13a', 'Rumor, teaser', (_) => rumorTeaser()),
  GalleryScreen('S13b', 'Rumor, co-signed (insider)', (_) => rumorCosigned()),
  GalleryScreen('S13c', 'Rumor, capped', (_) => rumorCapped()),
  GalleryScreen('S15a', 'Ruling, public with the vote', (_) => rulingPublic()),
  GalleryScreen('S15b', 'Ruling, conflicted voter', (_) => rulingConflicted()),
  GalleryScreen('S15c', 'Ruling, corrected', (_) => rulingCorrected()),
  GalleryScreen('S15d', 'Ruling, story hidden', (_) => rulingHidden()),
  GalleryScreen('S15e', 'Ruling, voided', (_) => rulingVoided()),
  GalleryScreen('S17a', 'Halt vote, your vote', (_) => haltYourVote()),
  GalleryScreen('S17b', 'Halt vote, result', (_) => haltResult()),
  GalleryScreen('S18a', 'Tape, all with unread', (_) => tapeAll()),
  GalleryScreen('S18b', 'Tape, filtered', (_) => tapeFiltered()),
  GalleryScreen('S18c', 'Tape, empty', (_) => tapeEmpty()),
  GalleryScreen('S18d', 'Tape, filter empty', (_) => tapeFilteredEmpty()),
  GalleryScreen('S18e', 'Tape, loading', (_) => tapeLoading()),
  GalleryScreen('S19a', 'Notifications, by stock', (_) => inboxGrouped()),
  GalleryScreen('S19b', 'Notifications, quiet hours', (_) => inboxQuiet()),
  GalleryScreen('S19c', 'Notifications, empty', (_) => inboxEmpty()),
  GalleryScreen('S19d', 'Notifications, loading', (_) => inboxLoading()),
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
