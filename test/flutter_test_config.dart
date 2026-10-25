import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

/// Runs before every test file. `flutter test` renders text in a placeholder
/// font of square glyphs unless real fonts are loaded, so load the bundled
/// ones; goldens then show Inter where iOS shows SF Pro (CLAUDE.md).
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  await _loadFont('Inter', ['Inter-Variable.ttf']);
  await _loadFont('Newsreader', [
    'Newsreader-Variable.ttf',
    'Newsreader-Italic-Variable.ttf',
  ]);
  await _loadFont('JetBrainsMono', ['JetBrainsMono-Variable.ttf']);
  await testMain();
}

Future<void> _loadFont(String family, List<String> files) async {
  final loader = FontLoader(family);
  for (final file in files) {
    final bytes = File('assets/fonts/$file').readAsBytesSync();
    loader.addFont(
      Future.value(ByteData.sublistView(Uint8List.fromList(bytes))),
    );
  }
  await loader.load();
}
