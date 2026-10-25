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

final marketRepositoryProvider = Provider<MarketRepository>(
  (ref) => MarketRepository(ref.watch(auraApiProvider)),
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
}
