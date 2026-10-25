import 'package:flutter/widgets.dart';

import '../../features/home/home_view.dart';
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
];

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
