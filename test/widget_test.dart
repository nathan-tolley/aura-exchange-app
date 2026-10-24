import 'package:aura_exchange/app.dart';
import 'package:aura_exchange/design/tokens.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('boots dark onto the bg background', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: AuraApp()));

    final app = tester.widget<CupertinoApp>(find.byType(CupertinoApp));
    expect(app.theme?.brightness, Brightness.dark);
    expect(
      find.byWidgetPredicate((w) => w is ColoredBox && w.color == AuraColors.bg),
      findsOneWidget,
    );
  });
}
