import 'dart:ui' show Tristate;

import 'package:aura_exchange/design/surface.dart';
import 'package:aura_exchange/design/tokens.dart';
import 'package:aura_exchange/design/widgets/aura_hero_card.dart';
import 'package:aura_exchange/design/widgets/aura_sheet.dart';
import 'package:aura_exchange/design/widgets/aura_stock_row.dart';
import 'package:aura_exchange/design/widgets/aura_tab_bar.dart';
import 'package:aura_exchange/design/widgets/aura_tape.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/golden.dart';

/// Behavior of the composite components.
void main() {
  Decimal d(String s) => Decimal.parse(s);

  Future<void> pump(
    WidgetTester tester,
    Widget child, {
    bool reduceMotion = false,
  }) => tester.pumpWidget(
    AuraTestApp(
      reduceMotion: reduceMotion,
      child: Center(child: SizedBox(width: 358, child: child)),
    ),
  );

  testWidgets('a stock row taps, long-presses and reads as one line', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    var taps = 0, holds = 0;
    await pump(
      tester,
      AuraStockRow(
        ticker: 'anna',
        name: 'Anna',
        tag: 'Holding',
        price: d('124.10'),
        abs: d('7.79'),
        pct: d('6.70'),
        onTap: () => taps++,
        onLongPress: () => holds++,
      ),
    );
    expect(
      find.bySemanticsLabel(r'$ANNA, Anna, Holding, A$124.10, Up 7.79 (6.70%)'),
      findsOneWidget,
    );
    expect(tester.getSize(find.byType(AuraStockRow)).height, AuraSize.row);
    await tester.tap(find.byType(AuraStockRow));
    await tester.longPress(find.byType(AuraStockRow));
    expect((taps, holds), (1, 1));
    handle.dispose();
  });

  testWidgets('the tab bar reports the tab and marks the active one', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    AuraTab? picked;
    await pump(
      tester,
      Center(
        child: AuraTabBar(
          active: AuraTab.home,
          tapeBadge: true,
          onSelect: (t) => picked = t,
        ),
      ),
    );
    await tester.tap(find.bySemanticsLabel('Portfolio'));
    expect(picked, AuraTab.portfolio);
    final home = tester.getSemantics(find.bySemanticsLabel('Home'));
    expect(home.getSemanticsData().flagsCollection.isSelected, Tristate.isTrue);
    expect(find.bySemanticsLabel('Tape, new rulings'), findsOneWidget);
    handle.dispose();
  });

  final tapeItems = [
    AuraTapeItem(ticker: r'$ANNA', price: d('124.10'), pct: d('6.70')),
    AuraTapeItem(ticker: r'$JAKE', price: d('101.90'), pct: d('-9.34')),
  ];

  double tapeOffset(WidgetTester tester) =>
      tester.state<ScrollableState>(find.byType(Scrollable)).position.pixels;

  testWidgets('the tape scrolls on its own', (tester) async {
    await pump(tester, AuraTape(items: tapeItems));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(tapeOffset(tester), greaterThan(10));
  });

  testWidgets('with Reduce Motion the tape stays still', (tester) async {
    await pump(tester, AuraTape(items: tapeItems), reduceMotion: true);
    await tester.pump(const Duration(seconds: 2));
    expect(tapeOffset(tester), 0);
  });

  testWidgets('a sheet lifts what it holds', (tester) async {
    late bool inside;
    await pump(
      tester,
      AuraSheet(
        title: 'Buy',
        children: [
          Builder(
            builder: (context) {
              inside = AuraSheetScope.contains(context);
              return const SizedBox();
            },
          ),
        ],
      ),
    );
    expect(inside, isTrue);
  });

  testWidgets('a hidden balance hides the change too', (tester) async {
    await pump(
      tester,
      AuraHeroCard(
        label: 'Net worth',
        value: d('12486.20'),
        pct: d('24.86'),
        hideable: true,
        hidden: true,
        onToggleHidden: () {},
      ),
    );
    expect(find.text(r'A$••••••'), findsOneWidget);
    expect(find.textContaining('24.86'), findsNothing);
  });
}
