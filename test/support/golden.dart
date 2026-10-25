import 'package:aura_exchange/design/text.dart';
import 'package:aura_exchange/design/tokens.dart';
import 'package:flutter/cupertino.dart';
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
  double? height = 400,
  Color background = AuraColors.bg,
}) async {
  const columnKey = ValueKey('golden-column');
  Future<void> pumpAt(double h) async {
    tester.view.physicalSize = Size(previewWidth * 2, h * 2);
    tester.view.devicePixelRatio = 2;
    await tester.pumpWidget(
      KeyedSubtree(
        key: _stageKey,
        child: AuraTestApp(
          background: background,
          // Still frames: the tape stops, like with Reduce Motion.
          reduceMotion: true,
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 390,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  key: columnKey,
                  mainAxisSize: MainAxisSize.min,
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
  }

  addTearDown(tester.view.reset);
  if (height == null) {
    // Fit the content: lay it out tall, measure, then draw at that height.
    await pumpAt(4000);
    height = (tester.getSize(find.byKey(columnKey)).height + 32).ceilToDouble();
  }
  await pumpAt(height);
  await expectLater(find.byKey(_stageKey), matchesGoldenFile('$path.png'));
}

/// The drawn screens (design/reference/screens/W##-*.png) are an iPhone at
/// 390×844 pt, 2×, with a 52 pt status bar area.
const screenSize = Size(390, 844);
const screenPadding = EdgeInsets.only(top: 52, bottom: 34);

/// Pumps [screen] full size, as the references were drawn, and compares it
/// with `test/goldens/<path>.png` (780×1688 px).
Future<void> expectScreen(
  WidgetTester tester,
  String path,
  Widget screen,
) async {
  tester.view.physicalSize = screenSize * 2;
  tester.view.devicePixelRatio = 2;
  tester.view.padding = FakeViewPadding(
    top: screenPadding.top * 2,
    bottom: screenPadding.bottom * 2,
  );
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    KeyedSubtree(
      key: _stageKey,
      child: AuraTestApp(reduceMotion: true, child: screen),
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
    this.reduceMotion = false,
  });

  final Widget child;
  final Color background;

  /// Turns on Reduce Motion (MediaQuery.disableAnimations).
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final base = auraBaseTextStyle(systemSans: false);
    final media = MediaQuery.of(context);
    // The same Cupertino theme the app installs (lib/app.dart).
    return CupertinoTheme(
      data: CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: AuraColors.ink,
        textTheme: CupertinoTextThemeData(textStyle: base),
      ),
      child: MediaQuery(
        data: media.copyWith(disableAnimations: reduceMotion),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: DefaultTextStyle(
            style: base,
            child: ColoredBox(color: background, child: child),
          ),
        ),
      ),
    );
  }
}
