import 'package:flutter/widgets.dart';

import '../surface.dart';

/// A placeholder block where content is loading, at the real content's size
/// (DESIGN.md → States: never a full-screen spinner). `raised` on `bg`,
/// lifted inside sheets, breathing slowly; still with Reduce Motion.
///
/// Give it the size of what will be there: a row's 64 pt, a title's line
/// height, a number's cap height. [AuraSkeletonText] stands in for lines of
/// text.
class AuraSkeleton extends StatefulWidget {
  const AuraSkeleton({
    super.key,
    this.width,
    required this.height,
    this.radius = 6,
  });

  /// Null fills the width.
  final double? width;
  final double height;
  final double radius;

  @override
  State<AuraSkeleton> createState() => _AuraSkeletonState();
}

class _AuraSkeletonState extends State<AuraSkeleton>
    with SingleTickerProviderStateMixin {
  late final _breath = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _breath
        ..stop()
        ..value = 1;
    } else if (!_breath.isAnimating) {
      _breath.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _breath.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final block = Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: AuraSheetScope.raised(context),
        borderRadius: BorderRadius.circular(widget.radius),
      ),
    );
    return ExcludeSemantics(
      child: FadeTransition(
        opacity: Tween(begin: 0.55, end: 1.0).animate(_breath),
        child: block,
      ),
    );
  }
}

/// Lines of text loading: blocks at [style]'s cap height on its line
/// height, the last one shorter, as a paragraph would end.
class AuraSkeletonText extends StatelessWidget {
  const AuraSkeletonText({
    super.key,
    required this.style,
    this.lines = 1,
    this.width,
    this.lastLineFraction = 0.6,
  });

  final TextStyle style;
  final int lines;

  /// The first lines' width; null fills.
  final double? width;
  final double lastLineFraction;

  @override
  Widget build(BuildContext context) {
    final size = style.fontSize ?? 15;
    final lineHeight = size * (style.height ?? 1.2);
    final cap = (size * 0.72).roundToDouble();
    return LayoutBuilder(
      builder: (context, constraints) {
        final full = width ?? constraints.maxWidth;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < lines; i++)
              SizedBox(
                height: lineHeight,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: AuraSkeleton(
                    width: i == lines - 1 && lines > 1
                        ? full * lastLineFraction
                        : full,
                    height: cap,
                    radius: 4,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
