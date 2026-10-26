import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'api/generated/export.dart';
import 'data/me.dart';
import 'design/gallery/gallery_screen.dart';
import 'design/gallery/screen_states.dart';
import 'design/sheet_route.dart';
import 'design/tokens.dart';
import 'design/widgets/aura_tab_bar.dart';
import 'features/events/event_screen.dart';
import 'features/events/file_sheet.dart';
import 'features/home/home_screen.dart';
import 'features/market/market_screen.dart';
import 'features/onboarding/create_exchange_screen.dart';
import 'features/portfolio/portfolio_screen.dart';
import 'features/onboarding/ipo_screen.dart';
import 'features/onboarding/join_screen.dart';
import 'features/onboarding/sign_in_screen.dart';
import 'features/stock/stock_screen.dart';
import 'features/system/boot_screen.dart';
import 'features/tape/tape_screen.dart';
import 'features/trade/trade_screen.dart';
import 'features/you/you_screen.dart';

/// Every screen is a route, so `aura://` deep links land on real screens
/// (`aura://invite/JAKE-7F2K` arrives as `/invite/JAKE-7F2K`). The redirect
/// keeps you on sign-in until you're signed in, then on onboarding until you
/// have an exchange and a listing ([appRedirect]).
final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _Refresh();
  ref.listen(signedInProvider, (_, _) => refresh.ping());
  ref.listen(meProvider, (_, _) => refresh.ping());
  final router = GoRouter(
    initialLocation: Routes.home,
    refreshListenable: refresh,
    redirect: (context, state) => appRedirect(
      state.uri,
      signedIn: ref.read(signedInProvider),
      me: ref.read(meProvider),
    ),
    routes: _routes,
  );
  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});

/// The app's paths.
abstract final class Routes {
  /// Before the Keychain and `/me` have answered (or when `/me` failed).
  static const boot = '/boot';
  static const signIn = '/sign-in';
  static const createExchange = '/exchanges/new';
  static const createInvite = '/exchanges/new/invite';
  static const createWaiting = '/exchanges/new/waiting';
  static const ipo = '/ipo';
  static const home = '/home';
  static const market = '/market';
  static const tape = '/tape';
  static const portfolio = '/portfolio';
  static const you = '/you';
  static const gallery = '/gallery';
  static const notifications = '/notifications';
  static const settings = '/settings';
  static const file = '/file';

  static String invite(String code) => '/invite/$code';
  static String stock(String listingId) => '/stock/$listingId';
  static String fileAbout(String listingId) =>
      Uri(path: file, queryParameters: {'subject': listingId}).toString();
  static String event(String eventId) => '/events/$eventId';
  static String trade(String listingId, Side side, {int? quantity}) => Uri(
    path: '/trade/$listingId',
    queryParameters: {'side': side.json, 'quantity': ?quantity?.toString()},
  ).toString();
  static String position(String positionId) => '/positions/$positionId';

  /// The tab roots, in tab-bar order.
  static const tabs = [home, market, tape, portfolio, you];
}

/// Where [location] should go instead, or null to stay.
///
/// - Signed-out state unknown (the Keychain is being read): `/boot`.
/// - Signed out: sign-in, remembering where you were going (an invite link).
/// - Signed in, `/me` not loaded yet or failed: `/boot`, which shows the
///   failure with Try again.
/// - In no exchange: create one, unless you're following an invite.
/// - Otherwise sign-in and boot forward to where you were going, or Home.
@visibleForTesting
String? appRedirect(
  Uri location, {
  required bool? signedIn,
  required AsyncValue<Me?> me,
}) {
  final path = location.path;
  if (path.startsWith(Routes.gallery)) return null;
  final from = _from(location);

  if (signedIn == null) {
    return path == Routes.boot ? null : _with(Routes.boot, from);
  }
  if (!signedIn) {
    if (path.startsWith(Routes.signIn)) return null;
    return _with(Routes.signIn, from);
  }
  final known = me.value;
  if (known == null) {
    return path == Routes.boot ? null : _with(Routes.boot, from);
  }

  final arriving = path == Routes.boot || path.startsWith(Routes.signIn);
  final target = arriving ? (from ?? Routes.home) : location.toString();
  final onboarding = _onboarding(Uri.parse(target), known);
  final next = onboarding ?? target;
  return next == location.toString() ? null : next;
}

/// Where someone part-way through onboarding has to be, or null when
/// [location] is fine for them. Only having no exchange holds you: being
/// unlisted doesn't, because you can opt out (SCREENS.md #31). Creating and
/// joining lead into your IPO themselves, and You offers it after.
String? _onboarding(Uri location, Me me) {
  final path = location.path;
  // An invite can always be followed: it's how you join.
  if (path.startsWith('/invite/')) return null;
  if (me.memberships.isEmpty) {
    return path.startsWith(Routes.createExchange)
        ? null
        : Routes.createExchange;
  }
  return null;
}

/// Where the user was going when they were sent to boot or sign-in: the
/// `from` parameter when already there, otherwise the location itself. Only
/// paths inside the app count.
String? _from(Uri location) {
  final path = location.path;
  if (path == Routes.boot || path.startsWith(Routes.signIn)) {
    final from = location.queryParameters['from'];
    return from != null && from.startsWith('/') && !from.startsWith('//')
        ? from
        : null;
  }
  if (path == '/' || path == Routes.home) return null;
  return location.toString();
}

String _with(String path, String? from) => from == null
    ? path
    : Uri(path: path, queryParameters: {'from': from}).toString();

final List<RouteBase> _routes = [
  GoRoute(path: '/', redirect: (_, _) => Routes.home),
  GoRoute(path: Routes.boot, builder: (_, _) => const BootScreen()),
  GoRoute(path: Routes.signIn, builder: (_, _) => const SignInScreen()),
  GoRoute(
    path: Routes.createExchange,
    builder: (_, _) => const CreateExchangeScreen(),
    routes: [
      GoRoute(path: 'invite', builder: (_, _) => const InviteScreen()),
      GoRoute(path: 'waiting', builder: (_, _) => const WaitingScreen()),
    ],
  ),
  GoRoute(path: Routes.ipo, builder: (_, _) => const IpoScreen()),
  GoRoute(
    path: '/invite/:code',
    builder: (_, state) => JoinScreen(code: state.pathParameters['code']!),
  ),
  // Screens still to come in A4: the background until they're built.
  GoRoute(path: Routes.notifications, builder: (_, _) => const InboxScreen()),
  GoRoute(path: Routes.settings, builder: (_, _) => const SettingsScreen()),
  GoRoute(
    path: '/positions/:id',
    builder: (_, state) =>
        PositionScreen(positionId: state.pathParameters['id']!),
  ),
  GoRoute(
    path: Routes.file,
    pageBuilder: (_, state) => AuraSheetPage(
      key: state.pageKey,
      child: FileSheet(subjectId: state.uri.queryParameters['subject']),
    ),
  ),
  GoRoute(
    path: '/stock/:id',
    builder: (_, state) => StockScreen(listingId: state.pathParameters['id']!),
  ),
  GoRoute(
    path: '/events/:id',
    builder: (_, state) => EventScreen(eventId: state.pathParameters['id']!),
  ),
  GoRoute(
    path: '/trade/:listingId',
    pageBuilder: (_, state) => AuraSheetPage(
      key: state.pageKey,
      child: TradeSheet(
        listingId: state.pathParameters['listingId']!,
        side: Side.fromJson(state.uri.queryParameters['side'] ?? 'BUY'),
        quantity:
            int.tryParse(state.uri.queryParameters['quantity'] ?? '') ?? 1,
      ),
    ),
  ),
  StatefulShellRoute.indexedStack(
    builder: (context, state, shell) => shell,
    branches: [
      for (final tab in AuraTab.values)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.tabs[tab.index],
              builder: (_, _) => switch (tab) {
                AuraTab.home => const HomeScreen(),
                AuraTab.market => const MarketScreen(),
                AuraTab.tape => const TapeScreen(),
                AuraTab.portfolio => const PortfolioScreen(),
                AuraTab.you => const YouScreen(),
              },
            ),
          ],
        ),
    ],
  ),
  // The State Gallery: debug builds only (aura://gallery on the phone).
  if (kDebugMode)
    GoRoute(
      path: Routes.gallery,
      builder: (context, state) => AuraGalleryScreen(
        onOpenScreen: (id) => context.push('${Routes.gallery}/screens/$id'),
      ),
      routes: [
        // A screen state full size: swipe back to the gallery.
        GoRoute(
          path: 'screens/:id',
          builder: (context, state) {
            final id = state.pathParameters['id'];
            final screen = screenStates.where((s) => s.id == id).firstOrNull;
            // An id that isn't in the gallery: the plain background.
            return screen == null
                ? const ColoredBox(
                    color: AuraColors.bg,
                    child: SizedBox.expand(),
                  )
                : Builder(builder: screen.build);
          },
        ),
      ],
    ),
];

/// Switches to [tab], or back to its root when it's already showing. For the
/// tab screens' `AuraTabBar`.
void goTab(BuildContext context, AuraTab tab) {
  final shell = StatefulNavigationShell.of(context);
  shell.goBranch(tab.index, initialLocation: tab.index == shell.currentIndex);
}

/// Re-runs the redirect when sign-in or `/me` changes.
class _Refresh extends ChangeNotifier {
  void ping() => notifyListeners();
}
