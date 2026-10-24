import 'package:aura_exchange/design/icons.dart';
import 'package:aura_exchange/design/widgets/aura_countdown.dart';
import 'package:aura_exchange/design/widgets/aura_icon_button.dart';
import 'package:aura_exchange/design/widgets/aura_impact_disc.dart';
import 'package:aura_exchange/design/widgets/aura_money.dart';
import 'package:aura_exchange/design/widgets/aura_price_change.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/golden.dart';

/// Behavior the goldens can't show: what VoiceOver hears, hit areas, taps.
void main() {
  Decimal d(String s) => Decimal.parse(s);

  Future<SemanticsHandle> pump(WidgetTester tester, Widget child) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(AuraTestApp(child: Center(child: child)));
    return handle;
  }

  testWidgets('a price change is read as a word, never an arrow', (
    tester,
  ) async {
    final handle = await pump(
      tester,
      AuraPriceChange(abs: d('7.79'), pct: d('6.70'), period: 'today'),
    );
    expect(find.bySemanticsLabel('Up 7.79 (6.70%) today'), findsOneWidget);
    expect(find.text('↑ +7.79 (+6.70%) today'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('money uses the real minus sign', (tester) async {
    await tester.pumpWidget(
      AuraTestApp(child: Center(child: AuraMoney(d('-888')))),
    );
    final text = tester.widget<Text>(find.byType(Text)).textSpan!.toPlainText();
    expect(text, '−A\$888.00');
  });

  testWidgets('glyph buttons have a name and a 44 pt target', (tester) async {
    var taps = 0;
    final handle = await pump(
      tester,
      AuraIconButton(
        icon: AuraIcons.close,
        label: 'Close',
        onPressed: () => taps++,
      ),
    );
    expect(tester.getSize(find.byType(AuraIconButton)), const Size.square(44));
    final data = tester
        .getSemantics(find.byType(AuraIconButton))
        .getSemanticsData();
    expect(data.label, 'Close');
    expect(data.flagsCollection.isButton, isTrue);
    expect(data.hasAction(SemanticsAction.tap), isTrue);
    await tester.tap(find.byType(AuraIconButton));
    expect(taps, 1);
    handle.dispose();
  });

  testWidgets('countdowns and impacts read as one phrase', (tester) async {
    final handle = await pump(
      tester,
      const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AuraCountdown(label: 'Ruling in', time: Duration(minutes: 6, seconds: 42)),
          AuraImpactDisc(delta: -18, label: 'Loss'),
        ],
      ),
    );
    expect(find.bySemanticsLabel('Ruling in 6:42'), findsOneWidget);
    expect(find.bySemanticsLabel('Impact −18, Loss'), findsOneWidget);
    handle.dispose();
  });
}
