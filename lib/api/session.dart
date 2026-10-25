import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// The signed-in user's token pair (API-CONTRACT.md → Transport). Access
/// tokens last 15 minutes; refresh tokens rotate on every refresh.
@immutable
class Tokens {
  const Tokens({required this.accessToken, required this.refreshToken});

  final String accessToken;
  final String refreshToken;
}

/// Where the tokens live between launches.
abstract interface class TokenStore {
  Future<Tokens?> read();
  Future<void> write(Tokens tokens);
  Future<void> clear();
}

/// The iOS Keychain. `first_unlock_this_device`: readable whenever the app
/// runs after the phone's first unlock, and never restored onto another
/// phone from a backup (a refresh-token family belongs to one device).
class SecureTokenStore implements TokenStore {
  SecureTokenStore([FlutterSecureStorage? storage])
    : _storage =
          storage ??
          const FlutterSecureStorage(
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock_this_device,
            ),
          );

  final FlutterSecureStorage _storage;

  static const _access = 'aura.accessToken';
  static const _refresh = 'aura.refreshToken';

  @override
  Future<Tokens?> read() async {
    final access = await _storage.read(key: _access);
    final refresh = await _storage.read(key: _refresh);
    if (access == null || refresh == null) return null;
    return Tokens(accessToken: access, refreshToken: refresh);
  }

  @override
  Future<void> write(Tokens tokens) async {
    await _storage.write(key: _access, value: tokens.accessToken);
    await _storage.write(key: _refresh, value: tokens.refreshToken);
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _access);
    await _storage.delete(key: _refresh);
  }
}

/// Tokens in memory only: tests and the State Gallery.
class MemoryTokenStore implements TokenStore {
  MemoryTokenStore([this._tokens]);

  Tokens? _tokens;

  @override
  Future<Tokens?> read() async => _tokens;

  @override
  Future<void> write(Tokens tokens) async => _tokens = tokens;

  @override
  Future<void> clear() async => _tokens = null;
}

/// Thrown by a [Refresher] when the server refuses the refresh token
/// (expired, revoked, or reused, which revokes its whole family). The user
/// has to sign in again.
class RefreshRejected implements Exception {
  const RefreshRejected();
}

/// Exchanges a refresh token for a new pair. Throws [RefreshRejected] when
/// the server refuses it; any other failure (offline, the server down) is
/// thrown as-is, the tokens are kept, and the caller shows that failure.
typedef Refresher = Future<Tokens> Function(String refreshToken);

/// The signed-in state: the current tokens, kept in memory after the first
/// read, and the one place that refreshes them.
///
/// Refreshes are single-flight. Refresh tokens rotate and reusing an old one
/// revokes the family, so two requests that expire together must share one
/// refresh, and a request that failed on a token that has since been replaced
/// just retries with the new one.
class AuthSession {
  AuthSession({required this._store, required this._refresher});

  final TokenStore _store;
  final Refresher _refresher;

  Tokens? _tokens;
  bool _loaded = false;
  Future<Tokens?>? _refreshing;

  /// Whether someone is signed in; null until the Keychain has been read.
  /// The router sends the user to sign-in when this turns false.
  final ValueNotifier<bool?> signedIn = ValueNotifier(null);

  /// The current tokens, read from the store on first use.
  Future<Tokens?> current() async {
    if (!_loaded) {
      _tokens = await _store.read();
      _loaded = true;
      signedIn.value = _tokens != null;
    }
    return _tokens;
  }

  /// After `POST /auth/email/verify`.
  Future<void> signIn(Tokens tokens) async {
    await _store.write(tokens);
    _tokens = tokens;
    _loaded = true;
    signedIn.value = true;
  }

  /// After sign-out, or when the server rejects the refresh token.
  Future<void> signOut() async {
    await _store.clear();
    _tokens = null;
    _loaded = true;
    signedIn.value = false;
  }

  /// Fresh tokens after a request was refused with `AUTH_EXPIRED` while
  /// carrying [failedAccessToken]. If the tokens have changed since that
  /// request was sent, returns the new ones without refreshing again.
  ///
  /// Returns null when the user is signed out (no tokens, or the server
  /// rejected the refresh token, which signs out). Rethrows the [Refresher]'s
  /// failure when the refresh itself couldn't finish.
  Future<Tokens?> refreshAfter(String? failedAccessToken) async {
    final tokens = await current();
    if (tokens == null) return null;
    if (failedAccessToken != null && tokens.accessToken != failedAccessToken) {
      return tokens;
    }
    return _refreshing ??= _refresh(tokens)
        .whenComplete(() => _refreshing = null);
  }

  Future<Tokens?> _refresh(Tokens tokens) async {
    try {
      final next = await _refresher(tokens.refreshToken);
      await _store.write(next);
      _tokens = next;
      return next;
    } on RefreshRejected {
      await signOut();
      return null;
    }
  }

  void dispose() => signedIn.dispose();
}
