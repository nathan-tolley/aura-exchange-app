import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/errors.dart';
import '../api/generated/export.dart' hide Freshness;
import '../api/stream.dart';
import 'api_providers.dart';
import 'freshness.dart';
import 'lifecycle.dart';
import 'repositories.dart';

/// The real socket. Tests override it.
final socketConnectorProvider = Provider<SocketConnector>(
  (ref) => connectWebSocket,
);

/// The one realtime stream. It runs while someone is signed in and the app is
/// in the foreground; it stops when signed out or backgrounded and starts
/// again on sign-in or resume. While it's down, each watched market refetches
/// when its `PollDue` arrives. A reconnect fires the refetch signal, so the
/// screen on show refetches what it may have missed.
final auraStreamProvider = Provider<AuraStream>((ref) {
  final client = ref.watch(auraClientProvider);
  final session = client.session;
  final stream = AuraStream(
    uri: client.config.streamUri,
    session: session,
    connector: ref.watch(socketConnectorProvider),
  );
  void follow() {
    if (!ref.read(foregroundProvider)) {
      stream.stop();
      return;
    }
    switch (session.signedIn.value) {
      case true:
        stream.start();
      case false:
        stream.stop();
      case null:
        break;
    }
  }

  session.signedIn.addListener(follow);
  ref.listen(foregroundProvider, (_, _) => follow());
  final reconnects = stream.messages.listen((message) {
    if (message is StreamReconnected) {
      ref.read(refetchSignalProvider.notifier).fire();
    }
  });
  ref.onDispose(() {
    session.signedIn.removeListener(follow);
    unawaited(reconnects.cancel());
    stream.dispose();
  });
  if (ref.read(foregroundProvider)) stream.start();
  return stream;
});

/// Whether the socket is up. False makes every price Delayed.
final streamConnectedProvider = NotifierProvider<StreamConnected, bool>(
  StreamConnected.new,
);

class StreamConnected extends Notifier<bool> {
  @override
  bool build() {
    final connected = ref.watch(auraStreamProvider).connected;
    void update() => state = connected.value;
    connected.addListener(update);
    ref.onDispose(() => connected.removeListener(update));
    return connected.value;
  }
}

/// One listing's numbers as shown: the latest tick over the REST payload,
/// as decimals.
@immutable
class LiveListing {
  const LiveListing({
    required this.summary,
    required this.price,
    required this.changeAbs,
    required this.changePct,
    required this.state,
  });

  /// The REST payload: ticker, name, badges, sparkline, your position.
  final ListingSummary summary;
  final Decimal price;
  final Decimal changeAbs;

  /// Percent units: 6.70 means 6.70%.
  final Decimal changePct;
  final ListingState state;

  String get id => summary.id;
}

/// An exchange's market as the app shows it: the last `GET /market` with
/// the stream's ticks on top, and how fresh that is.
@immutable
class LiveMarket {
  const LiveMarket({
    required this.market,
    required this.freshness,
    this.ticks = const {},
    this.problem,
  });

  factory LiveMarket.from(Market market) => LiveMarket(
    market: market,
    freshness: Freshness(
      asOf: market.asOf,
      marketState: market.marketState,
      nextChangeAt: market.nextChangeAt,
    ),
  );

  final Market market;
  final Freshness freshness;

  /// The latest tick per listing id since [market] was fetched.
  final Map<String, ListingTick> ticks;

  /// Why the last refetch failed (offline, the exchange down), while the
  /// numbers shown are older ones. Null once a refetch succeeds.
  final ApiError? problem;

  List<LiveListing> get listings => [
    for (final summary in market.listings) _live(summary),
  ];

  LiveListing _live(ListingSummary summary) {
    final tick = ticks[summary.id];
    if (tick == null) {
      return LiveListing(
        summary: summary,
        price: Decimal.parse(summary.price),
        changeAbs: Decimal.parse(summary.changeAbs),
        changePct: Decimal.parse(summary.changePct),
        state: summary.state,
      );
    }
    final price = Decimal.parse(tick.price);
    final pct = Decimal.parse(tick.changePct);
    final abs = tick.changeAbs;
    return LiveListing(
      summary: summary,
      price: price,
      changeAbs: abs == null ? _changeAbs(price, pct) : Decimal.parse(abs),
      changePct: pct,
      state: tick.state,
    );
  }

  /// A tick without `changeAbs` (a server older than draft.7) gets the
  /// amount from its own numbers: the move from the price the percent is
  /// measured against, rounded half-up like the server. It can be a cent
  /// off, since the percent is already rounded.
  static Decimal _changeAbs(Decimal price, Decimal pct) {
    final hundred = Decimal.fromInt(100);
    final base = (price * hundred / (hundred + pct)).toDecimal(
      scaleOnInfinitePrecision: 8,
    );
    return (price - base).round(scale: 2);
  }

  /// Applies ticks newer than what's shown.
  LiveMarket withTicks(TicksMessage message) {
    if (message.asOf.isBefore(freshness.asOf)) return this;
    return LiveMarket(
      market: market,
      freshness: Freshness(
        asOf: message.asOf,
        marketState: message.marketState,
        nextChangeAt: freshness.nextChangeAt,
      ),
      ticks: {...ticks, for (final t in message.listings) t.id: t},
      problem: problem,
    );
  }

  /// The market opened, closed or halted.
  LiveMarket withMarketState(MarketMessage message) => LiveMarket(
    market: market,
    freshness: Freshness(
      asOf: freshness.asOf,
      marketState: message.marketState,
      nextChangeAt: message.nextChangeAt,
    ),
    ticks: ticks,
    problem: problem,
  );

  LiveMarket withProblem(ApiError problem) => LiveMarket(
    market: market,
    freshness: freshness,
    ticks: ticks,
    problem: problem,
  );
}

/// The live market for one exchange, while a screen is watching it.
final marketProvider = AsyncNotifierProvider.autoDispose
    .family<MarketNotifier, LiveMarket, String>(MarketNotifier.new);

class MarketNotifier extends AsyncNotifier<LiveMarket> {
  MarketNotifier(this.exchangeId);

  final String exchangeId;

  @override
  Future<LiveMarket> build() async {
    final stream = ref.watch(auraStreamProvider);
    final messages = stream.messages.listen(_receive);
    stream.subscribe(exchangeId);
    // Back in the foreground, or reconnected after missing messages.
    ref.listen(refetchSignalProvider, (_, _) => unawaited(refresh()));
    ref.onDispose(() {
      unawaited(messages.cancel());
      stream.unsubscribe(exchangeId);
    });
    return LiveMarket.from(
      await ref.read(marketRepositoryProvider).market(exchangeId),
    );
  }

  /// Refetches: while polling, after a reconnect, and when the app resumes.
  /// The numbers on screen stay until new ones arrive; a failure is kept as
  /// [LiveMarket.problem] (they go Delayed meanwhile), and only replaces the
  /// screen when there were no numbers yet.
  Future<void> refresh() async {
    try {
      final market = await ref
          .read(marketRepositoryProvider)
          .market(exchangeId);
      if (ref.mounted) state = AsyncData(LiveMarket.from(market));
    } on ApiError catch (error, stack) {
      if (!ref.mounted) return;
      final shown = state.value;
      state = shown == null
          ? AsyncError(error, stack)
          : AsyncData(shown.withProblem(error));
    }
  }

  void _receive(StreamMessage message) {
    final shown = state.value;
    if (shown == null) return;
    switch (message) {
      case TicksMessage() when message.exchangeId == exchangeId:
        state = AsyncData(shown.withTicks(message));
      case MarketMessage() when message.exchangeId == exchangeId:
        state = AsyncData(shown.withMarketState(message));
      case PollDue() when message.exchangeId == exchangeId:
        unawaited(refresh());
      default:
        break;
    }
  }
}

/// How an exchange's prices are labelled right now: live, at the close, or
/// Delayed. Null while the market hasn't loaded. Re-evaluated every second,
/// so numbers go Delayed on their own once they're a minute old.
final marketLivenessProvider = Provider.autoDispose.family<Liveness?, String>((
  ref,
  exchangeId,
) {
  final freshness = ref.watch(
    marketProvider(exchangeId).select((m) => m.value?.freshness),
  );
  if (freshness == null) return null;
  return liveness(
    freshness,
    connected: ref.watch(streamConnectedProvider),
    now: ref.watch(clockProvider),
  );
});
