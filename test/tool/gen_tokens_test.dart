import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/gen_tokens.dart';

/// The generated design files must match their JSON sources: nobody edits
/// tokens or icons by hand (CLAUDE.md, design/DESIGN.md → Tokens).
void main() {
  Map<String, dynamic> source(String path) =>
      jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
  String committed(String path) =>
      File(path).readAsStringSync().replaceAll('\r\n', '\n');
  const fix = 'Run `dart run tool/gen_tokens.dart` and commit the result.';

  test('lib/design/tokens.dart is generated from design/tokens.json', () {
    expect(
      generateTokens(source(tokensSource)),
      committed(tokensOutput),
      reason: fix,
    );
  });

  test('lib/design/icon_paths.dart is generated from design/icons.json', () {
    expect(
      generateIconPaths(source(iconsSource)),
      committed(iconsOutput),
      reason: fix,
    );
  });
}
