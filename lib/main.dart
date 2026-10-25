import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'api/client.dart';
import 'app.dart';
import 'data/api_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(_fontLicenses);
  final app = await _appIdentity();
  runApp(
    ProviderScope(
      retry: noRetry,
      overrides: [appIdentityProvider.overrideWithValue(app)],
      child: const AuraApp(),
    ),
  );
}

/// The bundle's version and build, sent with every request. If the bundle
/// can't be read (the web preview without its `version.json`), the build is
/// `0`, which a server with a minimum build answers with UPDATE_REQUIRED.
Future<AppIdentity> _appIdentity() async {
  try {
    final info = await PackageInfo.fromPlatform();
    return AppIdentity(version: info.version, build: info.buildNumber);
  } on Object {
    return AppIdentity.unknown;
  }
}

/// The bundled fonts are OFL: their licenses ship with the app.
Stream<LicenseEntry> _fontLicenses() async* {
  for (final family in ['Newsreader', 'JetBrainsMono', 'Inter']) {
    final text = await rootBundle.loadString('assets/fonts/OFL-$family.txt');
    yield LicenseEntryWithLineBreaks([family], text);
  }
}
