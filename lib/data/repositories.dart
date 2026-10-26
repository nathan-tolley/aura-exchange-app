import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/client.dart';
import '../api/errors.dart';
import '../api/generated/export.dart';
import '../api/session.dart';
import 'api_providers.dart';

// One repository per resource. Each call goes through `guardApi`, so every
// failure reaches the screen as an `ApiError`, and every write takes the
// `IdempotencyKey` the user's action created, so a retry can reuse it.
// Repositories for events, tape, notifications and the rest come with their
// screens in A4.

final systemRepositoryProvider = Provider<SystemRepository>(
  (ref) => SystemRepository(ref.watch(auraApiProvider)),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(
    ref.watch(auraApiProvider),
    ref.watch(authSessionProvider),
  ),
);

final meRepositoryProvider = Provider<MeRepository>(
  (ref) => MeRepository(ref.watch(auraApiProvider)),
);

final exchangesRepositoryProvider = Provider<ExchangesRepository>(
  (ref) => ExchangesRepository(ref.watch(auraApiProvider)),
);

final marketRepositoryProvider = Provider<MarketRepository>(
  (ref) => MarketRepository(ref.watch(auraApiProvider)),
);

final eventsRepositoryProvider = Provider<EventsRepository>(
  (ref) => EventsRepository(ref.watch(auraApiProvider)),
);

final tapeRepositoryProvider = Provider<TapeRepository>(
  (ref) => TapeRepository(ref.watch(auraApiProvider)),
);

final tradingRepositoryProvider = Provider<TradingRepository>(
  (ref) => TradingRepository(ref.watch(auraApiProvider)),
);

class SystemRepository {
  SystemRepository(this._api);

  final AuraApi _api;

  /// Server status and the minimum build (W13, update required).
  Future<Health> health() => guardApi(_api.system.getHealth);
}

/// Sign-in by emailed code (no Sign in with Apple until the paid program).
class AuthRepository {
  AuthRepository(this._api, this._session);

  final AuraApi _api;
  final AuthSession _session;

  /// Emails a 6-digit code. In development the server logs it instead.
  Future<void> sendCode(String email, IdempotencyKey key) => guardApi(
    () => _api.auth.postAuthEmailStart(
      idempotencyKey: key.value,
      body: AuthEmailStartRequestBody(email: email),
    ),
  );

  /// Exchanges the code for tokens and signs in. Each submitted code needs
  /// its own key: the server replays a stored `LOGIN_CODE_INVALID` for a
  /// repeated key and body.
  Future<User> verifyCode(String email, String code, IdempotencyKey key) async {
    final pair = await guardApi(
      () => _api.auth.postAuthEmailVerify(
        idempotencyKey: key.value,
        body: AuthEmailVerifyRequestBody(email: email, code: code),
      ),
    );
    await _session.signIn(
      Tokens(accessToken: pair.accessToken, refreshToken: pair.refreshToken),
    );
    return pair.user;
  }

  /// Revokes this device's refresh-token family, then forgets the tokens.
  /// Signs out locally even when the server can't be reached.
  Future<void> signOut(IdempotencyKey key) async {
    final tokens = await _session.current();
    try {
      if (tokens != null) {
        await guardApi(
          () => _api.auth.postAuthLogout(
            idempotencyKey: key.value,
            body: AuthLogoutRequestBody(refreshToken: tokens.refreshToken),
          ),
        );
      }
    } on ApiError {
      // The tokens are dropped below either way; the family expires.
    } finally {
      await _session.signOut();
    }
  }
}

class MeRepository {
  MeRepository(this._api);

  final AuraApi _api;

  /// You and your memberships: which exchanges you're in, and whether you're
  /// listed in each.
  Future<Me> me() => guardApi(_api.me.getMe);

  /// The inbox (push comes later), newest first.
  Future<GetMeNotificationsResponse> notifications({
    String? exchangeId,
    String? cursor,
  }) => guardApi(
    () => _api.me.getMeNotifications(exchangeId: exchangeId, cursor: cursor),
  );

  /// Marks everything up to [upTo] read.
  Future<void> markRead(DateTime upTo, IdempotencyKey key) => guardApi(
    () => _api.me.postMeNotificationsRead(
      idempotencyKey: key.value,
      body: MeNotificationsReadRequestBody(upTo: upTo),
    ),
  );

  /// What you're notified about, and quiet hours.
  Future<NotificationPrefs> prefs() => guardApi(_api.me.getMeNotificationPrefs);

  /// Changes what you're notified about.
  Future<NotificationPrefs> setPrefs(
    NotificationPrefs prefs,
    IdempotencyKey key,
  ) => guardApi(
    () => _api.me.patchMeNotificationPrefs(
      idempotencyKey: key.value,
      body: prefs,
    ),
  );
}

/// Exchanges, invites and your IPO: everything onboarding needs.
class ExchangesRepository {
  ExchangesRepository(this._api);

  final AuraApi _api;

  /// One exchange: its name, timezone, hours, season and how many are
  /// listed.
  Future<Exchange> exchange(String exchangeId) => guardApi(
    () => _api.exchanges.getExchangesExchangeId(exchangeId: exchangeId),
  );

  /// Creates an exchange with you as its admin.
  Future<Exchange> create(ExchangeCreate body, IdempotencyKey key) => guardApi(
    () => _api.exchanges.postExchanges(idempotencyKey: key.value, body: body),
  );

  /// A new invite link for the exchange.
  Future<Invite> invite(String exchangeId, IdempotencyKey key) => guardApi(
    () => _api.exchanges.postExchangesExchangeIdInvites(
      exchangeId: exchangeId,
      idempotencyKey: key.value,
    ),
  );

  /// What an invite leads to, before joining: the exchange, who's listed,
  /// and whether it's still valid.
  Future<InvitePreview> previewInvite(String code) =>
      guardApi(() => _api.exchanges.getInvitesCode(code: code));

  /// Joins the exchange the invite is for.
  Future<Membership> acceptInvite(String code, IdempotencyKey key) => guardApi(
    () => _api.exchanges.postInvitesCodeAccept(
      code: code,
      idempotencyKey: key.value,
    ),
  );

  /// Whether a ticker is free in the exchange, with suggestions if not.
  Future<TickerCheck> checkTicker(String exchangeId, String ticker) => guardApi(
    () => _api.exchanges.getExchangesExchangeIdTickersCheck(
      exchangeId: exchangeId,
      ticker: ticker,
    ),
  );

  /// Your IPO: lists you under [ticker] (3–5 letters, no `$`), with your
  /// consent.
  Future<ListingRef> list(
    String exchangeId,
    String ticker,
    IdempotencyKey key,
  ) => guardApi(
    () => _api.exchanges.postExchangesExchangeIdListing(
      exchangeId: exchangeId,
      idempotencyKey: key.value,
      body: IpoRequest(ticker: ticker, consent: true),
    ),
  );
}

class MarketRepository {
  MarketRepository(this._api);

  final AuraApi _api;

  /// Every listing with price, change, state and sparkline, plus freshness.
  Future<Market> market(String exchangeId) => guardApi(
    () => _api.marketData.getExchangesExchangeIdMarket(exchangeId: exchangeId),
  );

  /// One stock page.
  Future<ListingDetail> listing(String listingId) => guardApi(
    () => _api.marketData.getListingsListingId(listingId: listingId),
  );

  /// A stock's chart for a range, with its ruling markers.
  Future<CandleSeries> candles(String listingId, Range range) => guardApi(
    () => _api.marketData.getListingsListingIdCandles(
      listingId: listingId,
      range: range,
    ),
  );
}

/// Filing, the rumor, the ruling and the votes (SCREENS.md #11–#17).
class EventsRepository {
  EventsRepository(this._api);

  final AuraApi _api;

  /// Files an event. It starts in `SENDING` for its unsend window.
  Future<Event> file(EventCreate event, IdempotencyKey key) => guardApi(
    () => _api.events.postEvents(idempotencyKey: key.value, body: event),
  );

  /// One event, as you're allowed to see it.
  Future<Event> event(String eventId) =>
      guardApi(() => _api.events.getEventsEventId(eventId: eventId));

  /// Takes a filing back while it's `SENDING`.
  Future<Event> unsend(String eventId, IdempotencyKey key) => guardApi(
    () => _api.events.postEventsEventIdUnsend(
      eventId: eventId,
      idempotencyKey: key.value,
    ),
  );

  /// Co-sign, cap or withdraw during the rumor.
  Future<Event> react(String eventId, Kind kind, IdempotencyKey key) =>
      guardApi(
        () => _api.events.postEventsEventIdReactions(
          eventId: eventId,
          idempotencyKey: key.value,
          body: EventsEventIdReactionsRequestBody(kind: kind),
        ),
      );

  /// The subject's statement during the rumor: no comment, or deny.
  Future<Event> statement(String eventId, Kind2 kind, IdempotencyKey key) =>
      guardApi(
        () => _api.events.postEventsEventIdStatement(
          eventId: eventId,
          idempotencyKey: key.value,
          body: EventsEventIdStatementRequestBody(kind: kind),
        ),
      );

  /// Up, down, or take your vote back, on a ruling.
  Future<Event> vote(String eventId, Direction direction, IdempotencyKey key) =>
      guardApi(
        () => _api.events.postEventsEventIdVotes(
          eventId: eventId,
          idempotencyKey: key.value,
          body: EventsEventIdVotesRequestBody(direction: direction),
        ),
      );

  /// Confirm, decline or reconsider a news halt.
  Future<Halt> haltVote(String haltId, Choice choice, IdempotencyKey key) =>
      guardApi(
        () => _api.events.postHaltsHaltIdVotes(
          haltId: haltId,
          idempotencyKey: key.value,
          body: HaltsHaltIdVotesRequestBody(choice: choice),
        ),
      );
}

class TapeRepository {
  TapeRepository(this._api);

  final AuraApi _api;

  /// The tape, newest first: everything, one listing's, or some types
  /// (comma-separated `TapeItemType` values).
  Future<GetExchangesExchangeIdTapeResponse> tape(
    String exchangeId, {
    String? listingId,
    String? types,
    String? cursor,
    int limit = 30,
  }) => guardApi(
    () => _api.tape.getExchangesExchangeIdTape(
      exchangeId: exchangeId,
      listingId: listingId,
      types: types,
      cursor: cursor,
      limit: limit,
    ),
  );
}

class TradingRepository {
  TradingRepository(this._api);

  final AuraApi _api;

  /// Prices a market order; holds for 15 s. Rejections (cash, size, short
  /// cap, closed, halted) come back here as `ApiError`s before the slide.
  Future<Quote> quote(QuoteRequest request, IdempotencyKey key) => guardApi(
    () => _api.trading.postQuotes(idempotencyKey: key.value, body: request),
  );

  /// Executes a quote. `QUOTE_STALE` means requote with `previousQuoteId`.
  Future<Trade> trade(String quoteId, IdempotencyKey key) => guardApi(
    () => _api.trading.postTrades(
      idempotencyKey: key.value,
      body: TradeRequest(quoteId: quoteId),
    ),
  );

  /// Cash, positions and open orders.
  Future<Portfolio> portfolio(String exchangeId) => guardApi(
    () => _api.trading.getExchangesExchangeIdPortfolio(exchangeId: exchangeId),
  );

  /// A limit, stop-loss or take-profit order. It rests until its trigger
  /// price trades.
  Future<Order> placeOrder(OrderCreate order, IdempotencyKey key) => guardApi(
    () => _api.trading.postOrders(idempotencyKey: key.value, body: order),
  );

  /// Cancels a resting order.
  Future<Order> cancelOrder(String orderId, IdempotencyKey key) => guardApi(
    () => _api.trading.deleteOrdersOrderId(
      orderId: orderId,
      idempotencyKey: key.value,
    ),
  );

  /// One position, with its margin detail when it's a short.
  Future<Position> position(String positionId) => guardApi(
    () => _api.trading.getPositionsPositionId(positionId: positionId),
  );
}
