import 'package:aura_exchange/design/icons.dart';
import 'package:aura_exchange/design/widgets/aura_banner.dart';
import 'package:aura_exchange/design/widgets/aura_nav_card.dart';
import 'package:aura_exchange/design/widgets/aura_range_bar.dart';
import 'package:aura_exchange/design/widgets/aura_receipt.dart';
import 'package:aura_exchange/design/widgets/aura_toast.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/golden.dart';

/// Behavior of the structural components: taps, and what VoiceOver hears.
void main() {
  Decimal d(String s) => Decimal.parse(s);

  Future<void> pump(WidgetTester tester, Widget child) => tester.pumpWidget(
    AuraTestApp(
      child: Center(child: SizedBox(width: 358, child: child)),
    ),
  );

  testWidgets('a nav row is one button that reads its whole line', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    var taps = 0;
    await pump(
      tester,
      AuraNavCard(
        children: [
          AuraNavRow(
            icon: AuraIcons.hide,
            title: 'Super-injunction',
            subtitle: 'Hides the story · price hit stays',
            trailing: '2 of 3 left',
            onTap: () => taps++,
          ),
        ],
      ),
    );
    expect(
      find.bySemanticsLabel(
        'Super-injunction, Hides the story · price hit stays, 2 of 3 left',
      ),
      findsOneWidget,
    );
    await tester.tap(find.byType(AuraNavRow));
    expect(taps, 1);
    expect(tester.getSize(find.byType(AuraNavRow)).height, 56);
    handle.dispose();
  });

  testWidgets('banner and toast actions are buttons', (tester) async {
    var fixes = 0;
    await pump(
      tester,
      Column(
        children: [
          AuraBanner(
            tone: AuraBannerTone.down,
            title: r'You’re A$229.91 short',
            action: 'Buy 18',
            onAction: () => fixes++,
          ),
          AuraToast(message: 'Filed.', action: 'Undo', onAction: () => fixes++),
        ],
      ),
    );
    await tester.tap(find.text('Buy 18'));
    await tester.tap(find.text('Undo'));
    expect(fixes, 2);
  });

  test('the most severe banner wins', () {
    final tones = [...AuraBannerTone.values]
      ..sort((a, b) => b.severity.compareTo(a.severity));
    expect(tones.first, AuraBannerTone.down);
    expect(
      AuraBannerTone.warn.severity,
      greaterThan(AuraBannerTone.offline.severity),
    );
    expect(
      AuraBannerTone.offline.severity,
      greaterThan(AuraBannerTone.neutral.severity),
    );
  });

  testWidgets('receipt rows read label and value together', (tester) async {
    final handle = tester.ensureSemantics();
    await pump(
      tester,
      const AuraReceipt(
        rows: [AuraReceiptRow('Fee (0.5%)', r'A$12.41')],
        total: AuraReceiptRow('Estimated total', r'A$2,494.41'),
      ),
    );
    expect(find.bySemanticsLabel(r'Fee (0.5%): A$12.41'), findsOneWidget);
    expect(
      find.bySemanticsLabel(r'Estimated total: A$2,494.41'),
      findsOneWidget,
    );
    handle.dispose();
  });

  test('the range bar clamps the price to its ends', () {
    AuraRangeBar bar(String current) =>
        AuraRangeBar(low: d('88.40'), high: d('126.30'), current: d(current));
    expect(bar('124.10').fraction, closeTo(0.942, 0.001));
    expect(bar('80').fraction, 0);
    expect(bar('130').fraction, 1);
    expect(
      AuraRangeBar(low: d('1'), high: d('1'), current: d('1')).fraction,
      0,
    );
  });
}
