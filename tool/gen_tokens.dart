// Regenerates the design tokens and icon paths from the design sources:
//
//   design/tokens.json → lib/design/tokens.dart
//   design/icons.json  → lib/design/icon_paths.dart
//
// Run `dart run tool/gen_tokens.dart` after changing either JSON file. Never
// hand-edit the outputs; test/tool/gen_tokens_test.dart fails if they drift.
import 'dart:convert';
import 'dart:io';

const tokensSource = 'design/tokens.json';
const tokensOutput = 'lib/design/tokens.dart';
const iconsSource = 'design/icons.json';
const iconsOutput = 'lib/design/icon_paths.dart';

void main() {
  File(tokensOutput).writeAsStringSync(
    generateTokens(_readJson(tokensSource)),
  );
  File(iconsOutput).writeAsStringSync(generateIconPaths(_readJson(iconsSource)));
  stdout.writeln('Wrote $tokensOutput and $iconsOutput');
}

Map<String, dynamic> _readJson(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;

/// `lib/design/tokens.dart` from `design/tokens.json`.
String generateTokens(Map<String, dynamic> json) {
  final color = json['color'] as Map<String, dynamic>;
  final theme = (color['themes'] as List<dynamic>).first as Map<String, dynamic>;
  final themeId = theme['id'] as String;
  final colors = _list(color['tokens']);
  final hexByName = <String, String>{};
  for (final t in colors) {
    final value = t['value'];
    if (value is Map) hexByName[t['name'] as String] = value[themeId] as String;
  }
  String hexOf(Map<String, dynamic> t) {
    final value = t['value'];
    if (value is Map) return value[themeId] as String;
    // A reference such as "{bg}".
    return hexByName[(value as String).replaceAll(RegExp(r'[{}]'), '')]!;
  }

  final out = StringBuffer()
    ..writeln(
      '// GENERATED from design/tokens.json (${json['name']} · ${theme['name']}). '
      'Do not edit by hand;',
    )
    ..writeln(
      '// change tokens.json and regenerate (see design/DESIGN.md → Tokens).',
    )
    ..writeln("import 'package:flutter/widgets.dart';")
    ..writeln()
    ..writeln(
      '/// Colors. `up`, `down` and `warn` are information, never decoration '
      '(DESIGN.md rule 3).',
    )
    ..writeln('abstract final class AuraColors {');
  for (final t in colors) {
    final hex = hexOf(t).substring(1).toUpperCase();
    out
      ..writeln('  /// ${t['usage']}')
      ..writeln(
        '  static const Color ${_camel(t['name'] as String)} = Color(0xFF$hex);',
      );
  }
  out
    ..writeln('}')
    ..writeln()
    ..writeln('/// 4pt spacing scale. 16 is the screen gutter.')
    ..writeln('abstract final class AuraSpace {');
  for (final t in _list((json['spacing'] as Map)['tokens'])) {
    final name = (t['name'] as String).replaceFirst('space-', 's');
    out.writeln(
      '  static const double $name = ${_px(t['value'])}; // ${t['usage']}',
    );
  }
  out
    ..writeln('  static const double gutter = 16.0;')
    ..writeln('}')
    ..writeln();
  _writeScale(out, 'AuraRadius', 'radius-', (json['radius'] as Map)['tokens']);
  out.writeln();
  _writeScale(out, 'AuraSize', 'size-', (json['size'] as Map)['tokens']);
  out
    ..writeln()
    ..write(_fonts)
    ..writeln()
    ..writeln(
      '/// Type styles. Tabular figures everywhere. Scale with '
      'MediaQuery.textScaler (Dynamic Type).',
    )
    ..writeln('abstract final class AuraType {')
    ..writeln('  static const _tabular = [FontFeature.tabularFigures()];');
  for (final group in _list((json['type'] as Map)['groups'])) {
    out.writeln('  // ${group['name']}: ${group['note']}');
    for (final s in _list(group['styles'])) {
      final size = _px(s['fontSize']);
      final props = [
        'fontFamily: AuraFonts.${group['family']}',
        'fontFamilyFallback: AuraFonts.fallback',
        'fontSize: $size',
        'height: ${_round(_px(s['lineHeight']) / size)}',
        'fontWeight: FontWeight.w${s['fontWeight']}',
        if (s['letterSpacing'] != null)
          'letterSpacing: ${_round(_em(s['letterSpacing']) * size)}',
        'color: AuraColors.ink',
        'fontFeatures: _tabular',
      ];
      out
        ..writeln('  /// ${s['usage']} Sample: ${s['sample']}')
        ..writeln(
          '  static const TextStyle ${_camel(s['name'] as String)} = '
          'TextStyle(${props.join(', ')});',
        );
    }
  }
  out.writeln('}');
  return out.toString();
}

/// `lib/design/icon_paths.dart` from `design/icons.json`.
String generateIconPaths(Map<String, dynamic> json) {
  final viewBox = (json['viewBox'] as String).split(' ').map(double.parse);
  final paths = (json['paths'] as Map<String, dynamic>).cast<String, String>();
  final out = StringBuffer()
    ..writeln('// GENERATED from design/icons.json by tool/gen_tokens.dart. '
        'Do not edit by hand.')
    ..writeln()
    ..writeln('/// The ${paths.length} line icons, as SVG path data on a '
        '${viewBox.last.toInt()}-unit grid.')
    ..writeln('/// Painted by `AuraIcon` with round caps and joins.')
    ..writeln('enum AuraIcons {');
  final names = paths.keys.toList();
  for (final name in names) {
    out.writeln("  $name('${paths[name]}')${name == names.last ? ';' : ','}");
  }
  out
    ..writeln()
    ..writeln('  const AuraIcons(this.path);')
    ..writeln()
    ..writeln('  /// SVG path data in the ${viewBox.last.toInt()}-unit viewBox.')
    ..writeln('  final String path;')
    ..writeln()
    ..writeln('  /// Side of the square viewBox the paths are drawn in.')
    ..writeln('  static const double viewBox = ${viewBox.last};')
    ..writeln()
    ..writeln('  /// Stroke width in viewBox units (2.0 inside buttons).')
    ..writeln('  static const double strokeWidth = ${json['strokeWidth']};')
    ..writeln('}');
  return out.toString();
}

const _fonts = '''
/// Font families. `sans`/`display` are null on purpose: Flutter then uses San Francisco on iOS.
/// The serif (the Analyst's voice) and the mono (tape, countdowns) are bundled assets.
abstract final class AuraFonts {
  static const String? sans = null; // SF Pro Text on iOS
  static const String? display = null; // SF Pro Display on iOS (Flutter picks Display at ≥20pt)
  static const String serif = 'Newsreader'; // assets/fonts/Newsreader-*.ttf (OFL)
  static const String mono = 'JetBrainsMono'; // assets/fonts/JetBrainsMono-*.ttf (OFL)
  static const List<String> fallback = ['Inter', 'Roboto']; // web/desktop preview only
}
''';

void _writeScale(
  StringBuffer out,
  String className,
  String prefix,
  Object? tokens,
) {
  out.writeln('abstract final class $className {');
  for (final t in _list(tokens)) {
    final name = _camel((t['name'] as String).replaceFirst(prefix, ''));
    out.writeln(
      '  static const double $name = ${_px(t['value'])}; // ${t['usage']}',
    );
  }
  out.writeln('}');
}

List<Map<String, dynamic>> _list(Object? value) =>
    (value as List<dynamic>).cast<Map<String, dynamic>>();

/// `ink-secondary` → `inkSecondary`, `raised-2` → `raised2`.
String _camel(String name) {
  final parts = name.split('-');
  return parts.first +
      parts.skip(1).map((p) => p[0].toUpperCase() + p.substring(1)).join();
}

double _px(Object? value) => double.parse((value as String).replaceAll('px', ''));

double _em(Object? value) => double.parse((value as String).replaceAll('em', ''));

double _round(double value) => double.parse(value.toStringAsFixed(4));
