import 'package:aura_exchange/design/tone.dart';
import 'package:aura_exchange/design/widgets/aura_code_field.dart';
import 'package:aura_exchange/design/widgets/aura_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/golden.dart';

/// The two fields onboarding types into.
void main() {
  // Text fields need an Overlay (selection handles), so a CupertinoApp.
  Future<void> pump(WidgetTester tester, Widget child) => tester.pumpWidget(
    CupertinoApp(
      home: AuraTestApp(
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(width: 358, child: child),
        ),
      ),
    ),
  );

  group('AuraCodeField', () {
    testWidgets('fires once the sixth digit lands, and only digits go in', (
      tester,
    ) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      final completed = <String>[];
      await pump(
        tester,
        AuraCodeField(controller: controller, onCompleted: completed.add),
      );

      await tester.enterText(find.byType(CupertinoTextField), '48a2');
      expect(controller.text, '482');
      expect(completed, isEmpty);

      await tester.enterText(find.byType(CupertinoTextField), '4829131');
      expect(controller.text, '482913');
      expect(completed, ['482913']);
    });

    testWidgets('a pasted code fills every cell', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await pump(tester, AuraCodeField(controller: controller));
      await tester.enterText(find.byType(CupertinoTextField), '482913');
      await tester.pump();
      for (final digit in '482913'.split('')) {
        expect(find.text(digit), findsOneWidget);
      }
    });

    testWidgets('says what it is and what the note says', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await pump(
        tester,
        AuraCodeField(
          controller: controller,
          note: "That code isn't right.",
          noteTone: AuraTone.down,
        ),
      );
      expect(find.bySemanticsLabel('Sign-in code, 6 digits'), findsOneWidget);
      final node = tester.getSemantics(
        find.bySemanticsLabel('Sign-in code, 6 digits'),
      );
      expect(node.hint, "That code isn't right.");
    });

    testWidgets('accepts one-time-code autofill', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await pump(tester, AuraCodeField(controller: controller));
      final field = tester.widget<CupertinoTextField>(
        find.byType(CupertinoTextField),
      );
      expect(field.autofillHints, [AutofillHints.oneTimeCode]);
      expect(field.keyboardType, TextInputType.number);
    });
  });

  group('AuraTextField', () {
    testWidgets('is named by its label and passes typing through', (
      tester,
    ) async {
      final typed = <String>[];
      await pump(tester, AuraTextField(label: 'Email', onChanged: typed.add));
      expect(find.bySemanticsLabel(RegExp('^Email')), findsWidgets);
      await tester.enterText(find.byType(CupertinoTextField), 'a@b.co');
      expect(typed.last, 'a@b.co');
    });

    testWidgets('a disabled field keeps its own fill', (tester) async {
      await pump(tester, const AuraTextField(label: 'Email', enabled: false));
      final field = tester.widget<CupertinoTextField>(
        find.byType(CupertinoTextField),
      );
      expect(field.decoration, const BoxDecoration());
    });

    testWidgets('a problem shows its glyph; help does not', (tester) async {
      await pump(
        tester,
        const Column(
          children: [
            AuraFieldNote('Help'),
            AuraFieldNote('Problem', tone: AuraTone.down),
          ],
        ),
      );
      expect(find.byType(CustomPaint), findsWidgets);
      final help = find.ancestor(
        of: find.text('Help'),
        matching: find.byType(Row),
      );
      expect(
        find.descendant(of: help, matching: find.byType(CustomPaint)),
        findsNothing,
      );
      final problem = find.ancestor(
        of: find.text('Problem'),
        matching: find.byType(Row),
      );
      expect(
        find.descendant(of: problem, matching: find.byType(CustomPaint)),
        findsOneWidget,
      );
    });
  });
}
