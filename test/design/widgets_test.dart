import 'package:aura_exchange/design/icons.dart';
import 'package:aura_exchange/design/widgets/aura_button.dart';
import 'package:aura_exchange/design/widgets/aura_countdown.dart';
import 'package:aura_exchange/design/widgets/aura_icon_button.dart';
import 'package:aura_exchange/design/widgets/aura_impact_disc.dart';
import 'package:aura_exchange/design/widgets/aura_money.dart';
import 'package:aura_exchange/design/widgets/aura_price_change.dart';
import 'package:aura_exchange/design/widgets/aura_segmented_control.dart';
import 'package:aura_exchange/design/widgets/aura_slide_to_confirm.dart';
import 'package:aura_exchange/design/widgets/aura_stepper.dart';
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
          AuraCountdown(
            label: 'Ruling in',
            time: Duration(minutes: 6, seconds: 42),
          ),
          AuraImpactDisc(delta: -18, label: 'Loss'),
        ],
      ),
    );
    expect(find.bySemanticsLabel('Ruling in 6:42'), findsOneWidget);
    expect(find.bySemanticsLabel('Impact −18, Loss'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('the slider confirms once, and only at the end', (tester) async {
    var confirmed = 0;
    await tester.pumpWidget(
      AuraTestApp(
        child: Center(
          child: SizedBox(
            width: 358,
            child: AuraSlideToConfirm(
              label: r'Slide to buy 12 $ANNA',
              onConfirmed: () => confirmed++,
            ),
          ),
        ),
      ),
    );
    final knob =
        tester.getCenter(find.byType(AuraSlideToConfirm)) -
        const Offset(358 / 2 - 28, 0);

    await tester.dragFrom(knob, const Offset(150, 0));
    await tester.pumpAndSettle();
    expect(confirmed, 0, reason: 'released halfway: slides back');

    await tester.dragFrom(knob, const Offset(400, 0));
    await tester.pumpAndSettle();
    expect(confirmed, 1);

    await tester.dragFrom(knob, const Offset(400, 0));
    await tester.pumpAndSettle();
    expect(confirmed, 1, reason: 'a landed slider never submits twice');
  });

  testWidgets('the stepper steps by one and stops at one', (tester) async {
    Decimal? changed;
    await tester.pumpWidget(
      AuraTestApp(
        child: Center(
          child: SizedBox(
            width: 358,
            child: AuraStepper(value: d('1'), onChanged: (v) => changed = v),
          ),
        ),
      ),
    );
    await tester.tap(find.bySemanticsLabel('One fewer'));
    expect(changed, isNull);
    await tester.tap(find.bySemanticsLabel('One more'));
    expect(changed, d('2'));
  });

  testWidgets('segments report the new choice', (tester) async {
    String? picked;
    await tester.pumpWidget(
      AuraTestApp(
        child: Center(
          child: SizedBox(
            width: 358,
            child: AuraSegmentedControl(
              options: const ['1D', '1W', '1M'],
              value: '1D',
              label: 'Chart range',
              onChanged: (v) => picked = v,
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('1M'));
    expect(picked, '1M');
  });

  testWidgets('a disabled button says so to VoiceOver', (tester) async {
    final handle = await pump(tester, const AuraButton('Buy'));
    final data = tester
        .getSemantics(find.byType(AuraButton))
        .getSemanticsData();
    expect(data.label, 'Buy');
    expect(data.flagsCollection.isButton, isTrue);
    expect(data.hasAction(SemanticsAction.tap), isFalse);
    handle.dispose();
  });
}
