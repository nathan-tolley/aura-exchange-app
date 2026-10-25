import 'package:aura_exchange/design/icons.dart';
import 'package:aura_exchange/design/tokens.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every icon path parses and stays inside the 24-unit grid', () {
    expect(AuraIcons.values, hasLength(34));
    for (final icon in AuraIcons.values) {
      final bounds = AuraIcon.pathOf(icon).getBounds();
      // Lines like `minus` have zero height, so check the extent, not isEmpty.
      expect(bounds.width + bounds.height, greaterThan(0), reason: icon.name);
      expect(bounds.left, greaterThanOrEqualTo(0), reason: icon.name);
      expect(bounds.top, greaterThanOrEqualTo(0), reason: icon.name);
      expect(
        bounds.right,
        lessThanOrEqualTo(AuraIcons.viewBox),
        reason: icon.name,
      );
      expect(
        bounds.bottom,
        lessThanOrEqualTo(AuraIcons.viewBox),
        reason: icon.name,
      );
    }
  });

  testWidgets('takes its size, and is silent unless labelled', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: DefaultTextStyle(
          style: TextStyle(color: AuraColors.inkTertiary),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AuraIcon(AuraIcons.bell, size: 22),
              AuraIcon(AuraIcons.close, semanticLabel: 'Close'),
            ],
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(AuraIcon).first), const Size.square(22));
    expect(tester.getSize(find.byType(AuraIcon).last), const Size.square(20));
    expect(find.bySemanticsLabel('Close'), findsOneWidget);
    expect(find.bySemanticsLabel('bell'), findsNothing);
    handle.dispose();
  });
}
