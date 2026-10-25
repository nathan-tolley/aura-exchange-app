import 'package:flutter/widgets.dart';
import 'package:path_drawing/path_drawing.dart';

import 'icon_paths.dart';
import 'tokens.dart';

export 'icon_paths.dart';

/// One of the line icons from design/icons.json, painted as strokes on a
/// 24-unit grid with round caps and joins. Never mix in Material or Cupertino
/// icons (design/DESIGN.md → Icons).
///
/// Like text, it takes the current color: [color] if given, otherwise the
/// ambient [DefaultTextStyle] color. Icons are decorative unless given a
/// [semanticLabel]; a glyph button names itself instead (AuraIconButton).
class AuraIcon extends StatelessWidget {
  const AuraIcon(
    this.icon, {
    super.key,
    this.size = 20,
    this.weight = AuraIcons.strokeWidth,
    this.filled = false,
    this.color,
    this.semanticLabel,
  });

  final AuraIcons icon;

  /// Side of the square, in logical pixels.
  final double size;

  /// Stroke width in viewBox units: 1.7 by default, 2.0 inside buttons.
  final double weight;

  /// Filled instead of stroked: only the starred watchlist star uses it.
  final bool filled;

  final Color? color;
  final String? semanticLabel;

  static final Map<AuraIcons, Path> _paths = {};

  /// The parsed path in viewBox units, parsed once per icon.
  static Path pathOf(AuraIcons icon) =>
      _paths.putIfAbsent(icon, () => parseSvgPathData(icon.path));

  @override
  Widget build(BuildContext context) {
    final paint = CustomPaint(
      size: Size.square(size),
      painter: _AuraIconPainter(
        path: pathOf(icon),
        color:
            color ?? DefaultTextStyle.of(context).style.color ?? AuraColors.ink,
        weight: weight,
        filled: filled,
      ),
    );
    return semanticLabel == null
        ? ExcludeSemantics(child: paint)
        : Semantics(label: semanticLabel, image: true, child: paint);
  }
}

class _AuraIconPainter extends CustomPainter {
  const _AuraIconPainter({
    required this.path,
    required this.color,
    required this.weight,
    required this.filled,
  });

  final Path path;
  final Color color;
  final double weight;
  final bool filled;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.shortestSide / AuraIcons.viewBox);
    final paint = Paint()
      ..color = color
      ..isAntiAlias = true;
    if (filled) {
      paint.style = PaintingStyle.fill;
    } else {
      paint
        ..style = PaintingStyle.stroke
        ..strokeWidth = weight
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_AuraIconPainter old) =>
      old.path != path ||
      old.color != color ||
      old.weight != weight ||
      old.filled != filled;
}
