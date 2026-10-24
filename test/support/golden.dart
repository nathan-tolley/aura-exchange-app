import 'package:aura_exchange/design/text.dart';
import 'package:aura_exchange/design/tokens.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// The component references (design/reference/components/*.png) are 420 pt
/// wide at 2×: a 390 pt column with 16 pt padding, rows 16 pt apart.
const previewWidth = 420.0;

const _stageKey = ValueKey('golden-stage');

/// Pumps [rows] the way the reference previews were drawn and compares the
/// result with `test/goldens/<path>.png` at 2×.
///
/// The capture comes from the root view (nothing above the stage is a repaint
/// boundary), which gives physical pixels; a `RepaintBoundary` would be 1×.
Future<void> expectPreview(
  WidgetTester tester,
  String path,
  List<Widget> rows, {
  double height = 400,
  Color background = AuraColors.bg,
}) async {
  tester.view.physicalSize = Size(previewWidth * 2, height * 2);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    KeyedSubtree(
      key: _stageKey,
      child: AuraTestApp(
        background: background,
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 390,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 16,
                children: rows,
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  await expectLater(find.byKey(_stageKey), matchesGoldenFile('$path.png'));
}

/// One preview row: items side by side, wrapping, 16 pt apart, centered.
Widget previewRow(List<Widget> children, {double spacing = 16}) => Wrap(
  spacing: spacing,
  runSpacing: 16,
  crossAxisAlignment: WrapCrossAlignment.center,
  children: children,
);

/// What the app gives every screen, without the router: direction, media
/// query (from the test view), the base text style with Inter, and `bg`.
class AuraTestApp extends StatelessWidget {
  const AuraTestApp({
    super.key,
    required this.child,
    this.background = AuraColors.bg,
  });

  final Widget child;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: DefaultTextStyle(
        style: auraBaseTextStyle(systemSans: false),
        child: ColoredBox(color: background, child: child),
      ),
    );
  }
}
