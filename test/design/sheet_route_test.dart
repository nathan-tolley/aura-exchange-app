import 'package:aura_exchange/design/sheet_route.dart';
import 'package:aura_exchange/design/tokens.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

/// The modal route every `AuraSheet` is presented with.
void main() {
  Future<NavigatorState> pumpHost(WidgetTester tester) async {
    final key = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      CupertinoApp(
        navigatorKey: key,
        home: const ColoredBox(color: AuraColors.bg, child: SizedBox.expand()),
      ),
    );
    return key.currentState!;
  }

  Widget sheet({bool canPop = true, VoidCallback? onBlocked}) => PopScope(
    canPop: canPop,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop) onBlocked?.call();
    },
    child: const SizedBox(
      key: ValueKey('sheet'),
      height: 300,
      width: double.infinity,
      child: ColoredBox(color: AuraColors.raised),
    ),
  );

  testWidgets('dims the screen with the scrim, at the bottom', (tester) async {
    final nav = await pumpHost(tester);
    nav.push(AuraSheetRoute<void>(builder: (_) => sheet()));
    await tester.pumpAndSettle();

    final barrier = tester.widget<ModalBarrier>(find.byType(ModalBarrier).last);
    expect(barrier.color, AuraColors.scrim);
    expect(tester.getBottomLeft(find.byKey(const ValueKey('sheet'))).dy, 600);
  });

  testWidgets('a tap on the scrim or a drag down closes it', (tester) async {
    final nav = await pumpHost(tester);
    nav.push(AuraSheetRoute<void>(builder: (_) => sheet()));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(200, 100));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('sheet')), findsNothing);

    nav.push(AuraSheetRoute<void>(builder: (_) => sheet()));
    await tester.pumpAndSettle();
    await tester.drag(find.byKey(const ValueKey('sheet')), const Offset(0, 160));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('sheet')), findsNothing);
  });

  testWidgets('a small drag springs back', (tester) async {
    final nav = await pumpHost(tester);
    nav.push(AuraSheetRoute<void>(builder: (_) => sheet()));
    await tester.pumpAndSettle();
    await tester.timedDrag(
      find.byKey(const ValueKey('sheet')),
      const Offset(0, 40),
      const Duration(milliseconds: 400),
    );
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.byKey(const ValueKey('sheet'))).dy, 300);
  });

  testWidgets('a half-filled sheet can stop the close and ask', (
    tester,
  ) async {
    var asked = 0;
    final nav = await pumpHost(tester);
    nav.push(
      AuraSheetRoute<void>(
        builder: (_) => sheet(canPop: false, onBlocked: () => asked++),
      ),
    );
    await tester.pumpAndSettle();
    await tester.drag(find.byKey(const ValueKey('sheet')), const Offset(0, 200));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('sheet')), findsOneWidget);
    expect(asked, 1);
  });
}
