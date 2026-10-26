import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/client.dart';
import '../api/errors.dart';
import '../api/generated/aura_api.dart';
import '../api/session.dart';

/// Riverpod 3 retries failed providers by itself; the app doesn't. A
/// failure reaches the screen at once as an `ApiError`, and recovery is the
/// screen's Try again, the stream's polling and the refetch on reconnect.
Duration? noRetry(int retryCount, Object error) => null;

/// The bundle's version and build. `main()` overrides it from the bundle;
/// tests and the State Gallery get [AppIdentity.unknown].
final appIdentityProvider = Provider<AppIdentity>((ref) => AppIdentity.unknown);

final apiConfigProvider = Provider<ApiConfig>(
  (ref) => ApiConfig.fromEnvironment(ref.watch(appIdentityProvider)),
);

/// The Keychain on the phone. Tests override it with a [MemoryTokenStore].
final tokenStoreProvider = Provider<TokenStore>((ref) => SecureTokenStore());

/// The network. Tests override it with a fake adapter.
final httpAdapterProvider = Provider<HttpClientAdapter?>((ref) => null);

final auraClientProvider = Provider<AuraClient>((ref) {
  final client = AuraClient(
    config: ref.watch(apiConfigProvider),
    tokens: ref.watch(tokenStoreProvider),
    adapter: ref.watch(httpAdapterProvider),
  );
  ref.onDispose(client.close);
  return client;
});

/// The generated `/v1` client. Repositories call it through `guardApi`, so
/// every failure arrives as an `ApiError`.
final auraApiProvider = Provider<AuraApi>(
  (ref) => ref.watch(auraClientProvider).api,
);

/// The `UPDATE_REQUIRED` that stopped this build, from any request; null
/// while the build is accepted. The app shows the update screen over
/// everything while it's set.
final updateRequiredProvider = NotifierProvider<UpdateRequired, ApiError?>(
  UpdateRequired.new,
);

class UpdateRequired extends Notifier<ApiError?> {
  @override
  ApiError? build() {
    final notifier = ref.watch(auraClientProvider).updateRequired;
    void follow() => state = notifier.value;
    notifier.addListener(follow);
    ref.onDispose(() => notifier.removeListener(follow));
    return notifier.value;
  }

  /// Check again: clear it, and the next request finds out.
  void clear() => ref.read(auraClientProvider).updateRequired.value = null;
}

final authSessionProvider = Provider<AuthSession>(
  (ref) => ref.watch(auraClientProvider).session,
);
