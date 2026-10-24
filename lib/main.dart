import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

void main() {
  LicenseRegistry.addLicense(_fontLicenses);
  runApp(const ProviderScope(child: AuraApp()));
}

/// The bundled fonts are OFL: their licenses ship with the app.
Stream<LicenseEntry> _fontLicenses() async* {
  for (final family in ['Newsreader', 'JetBrainsMono', 'Inter']) {
    final text = await rootBundle.loadString('assets/fonts/OFL-$family.txt');
    yield LicenseEntryWithLineBreaks([family], text);
  }
}
