import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/client.dart';
import '../api/generated/aura_api.dart';
import '../api/session.dart';

/// The bundle's version and build. `main()` overrides it from the bundle;
/// tests and the State Gallery get [AppIdentity.unknown].
final appIdentityProvider = Provider<AppIdentity>((ref) => AppIdentity.unknown);

final apiConfigProvider = Provider<ApiConfig>(
  (ref) => ApiConfig.fromEnvironment(ref.watch(appIdentityProvider)),
);

/// The Keychain on the phone. Tests override it with a [MemoryTokenStore].
final tokenStoreProvider = Provider<TokenStore>((ref) => SecureTokenStore());

final auraClientProvider = Provider<AuraClient>((ref) {
  final client = AuraClient(
    config: ref.watch(apiConfigProvider),
    tokens: ref.watch(tokenStoreProvider),
  );
  ref.onDispose(client.close);
  return client;
});

/// The generated `/v1` client. Repositories call it through `guardApi`, so
/// every failure arrives as an `ApiError`.
final auraApiProvider = Provider<AuraApi>(
  (ref) => ref.watch(auraClientProvider).api,
);

final authSessionProvider = Provider<AuthSession>(
  (ref) => ref.watch(auraClientProvider).session,
);
