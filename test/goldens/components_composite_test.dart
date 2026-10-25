@Tags(['golden'])
library;

import 'package:aura_exchange/design/icons.dart';
import 'package:aura_exchange/design/tone.dart';
import 'package:aura_exchange/design/widgets/aura_banner.dart';
import 'package:aura_exchange/design/widgets/aura_button.dart';
import 'package:aura_exchange/design/widgets/aura_chart_tooltip.dart';
import 'package:aura_exchange/design/widgets/aura_hero_card.dart';
import 'package:aura_exchange/design/widgets/aura_money.dart';
import 'package:aura_exchange/design/widgets/aura_receipt.dart';
import 'package:aura_exchange/design/widgets/aura_sheet.dart';
import 'package:aura_exchange/design/widgets/aura_slide_to_confirm.dart';
import 'package:aura_exchange/design/widgets/aura_sparkline.dart';
import 'package:aura_exchange/design/widgets/aura_stat_card.dart';
import 'package:aura_exchange/design/widgets/aura_stock_row.dart';
import 'package:aura_exchange/design/widgets/aura_tab_bar.dart';
import 'package:aura_exchange/design/widgets/aura_tape.dart';
import 'package:aura_exchange/format/change.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/golden.dart';

/// Goldens for the composite components (rows, hero, tape, tab bar, sheet),
/// drawn with the same content as `design/reference/components/<Name>.png`.
/// Sparkline points approximate the reference curves; its data isn't given.
void main() {
  Decimal d(String s) => Decimal.parse(s);
  void tap() {}

  const annaPoints = [
    118.0,
    117.6,
    118.5,
    118.2,
    119.0,
    118.8,
    119.8,
    119.5,
    120.5,
    120.2,
    121.0,
    121.5,
    121.2,
    122.2,
    122.0,
    123.0,
    123.4,
    123.1,
    124.1,
  ];
  const jakePoints = [
    112.4,
    112.2,
    112.5,
    104.0,
    103.6,
    103.2,
    103.0,
    103.4,
    104.2,
    105.1,
    104.6,
    104.9,
    104.5,
    104.8,
    104.6,
    104.3,
    104.5,
    104.5,
  ];
  const eliPoints = [
    89.7,
    89.2,
    89.5,
    88.8,
    89.0,
    88.5,
    88.7,
    88.2,
    88.0,
    87.6,
    87.55,
  ];
  const samPoints = [
    96.8,
    96.7,
    96.8,
    96.75,
    96.8,
    96.8,
    92.2,
    92.3,
    92.1,
    92.05,
    92.05,
  ];

  testWidgets('Sparkline', (tester) async {
    await expectPreview(tester, 'components/Sparkline', [
      previewRow(const [
        AuraSparkline(points: annaPoints),
        AuraSparkline(points: jakePoints),
        AuraSparkline(
          points: [10, 14, 6, 12, 8, 16, 10, 11],
          trend: Trend.flat,
        ),
      ]),
    ]);
  });

  testWidgets('ChartTooltip', (tester) async {
    await expectPreview(tester, 'components/ChartTooltip', [
      previewRow([
        AuraChartTooltip(
          price: d('118.20'),
          badge: '+22 ruling',
          tone: AuraTone.up,
        ),
        AuraChartTooltip(
          price: d('98.70'),
          badge: '−18 ruling',
          tone: AuraTone.down,
        ),
      ]),
      AuraChartTooltip(price: d('99.20'), badge: 'Rumor'),
    ]);
  });

  testWidgets('StockRow', (tester) async {
    await expectPreview(tester, 'components/StockRow', [
      Column(
        children: [
          AuraStockRow(
            ticker: r'$ANNA',
            name: 'Anna',
            tag: 'Holding',
            price: d('124.10'),
            abs: d('7.79'),
            pct: d('6.70'),
            points: annaPoints,
            onTap: tap,
          ),
          AuraStockRow(
            ticker: r'$JAKE',
            name: 'Jake',
            tag: 'Short',
            price: d('101.90'),
            abs: d('-10.50'),
            pct: d('-9.34'),
            points: jakePoints,
            onTap: tap,
          ),
          AuraStockRow(
            ticker: r'$ELI',
            name: 'Eli',
            tag: 'Rumor',
            price: d('87.55'),
            abs: d('-2.15'),
            pct: d('-2.40'),
            points: eliPoints,
            onTap: tap,
          ),
          AuraStockRow(
            ticker: r'$SAM',
            name: 'Sam',
            tag: 'SEC',
            tagTone: AuraTone.down,
            price: d('92.05'),
            abs: d('-4.74'),
            pct: d('-4.90'),
            points: samPoints,
            onTap: tap,
          ),
        ],
      ),
    ]);
  });

  testWidgets('HeroCard', (tester) async {
    await expectPreview(tester, 'components/HeroCard', [
      AuraHeroCard(
        label: 'Net worth · Season 1',
        value: d('12486.20'),
        abs: d('2486.20'),
        pct: d('24.86'),
        period: 'this season',
        hideable: true,
        onToggleHidden: tap,
      ),
      // The reference card used medium buttons sized by their content.
      Row(
        spacing: 10,
        children: [
          Expanded(
            flex: 203,
            child: AuraButton(
              'File an event',
              icon: AuraIcons.file,
              variant: AuraButtonVariant.primary,
              size: AuraButtonSize.md,
              block: true,
              onPressed: tap,
            ),
          ),
          Expanded(
            flex: 145,
            child: AuraButton(
              'Trade',
              icon: AuraIcons.trade,
              size: AuraButtonSize.md,
              block: true,
              onPressed: tap,
            ),
          ),
        ],
      ),
      AuraHeroCard(
        label: 'Hits at the 7:00 am open',
        value: d('98.70'),
        approx: true,
        pct: d('-12.20'),
        note: r'From A$112.40',
      ),
    ]);
  });

  testWidgets('Tape', (tester) async {
    await expectPreview(tester, 'components/Tape', [
      AuraTape(
        items: [
          AuraTapeItem(ticker: r'$ANNA', price: d('124.10'), pct: d('6.70')),
          AuraTapeItem(ticker: r'$JAKE', price: d('101.90'), pct: d('-9.34')),
          AuraTapeItem(ticker: r'$NATE', price: d('100.00'), pct: d('0')),
          AuraTapeItem(ticker: r'$ELI', price: d('87.55'), pct: d('-2.40')),
        ],
      ),
    ]);
  });

  testWidgets('TabBar', (tester) async {
    await expectPreview(tester, 'components/TabBar', [
      Center(
        child: AuraTabBar(
          active: AuraTab.home,
          tapeBadge: true,
          onSelect: (_) {},
        ),
      ),
    ]);
  });

  testWidgets('Sheet', (tester) async {
    await expectPreview(tester, 'components/Sheet', [
      AuraSheet(
        title: r'Buy $ANNA',
        onClose: tap,
        children: [
          AuraStatGrid(
            children: [
              const AuraStatCard(label: 'Shares', value: '12'),
              AuraStatCard(
                label: 'Est. cost',
                valueChild: AuraMoney(d('1496.40')),
              ),
            ],
          ),
          const AuraBanner(
            title: 'Quote holds for 0:15',
            body: r'Price impact 0.4% · fee A$7.44',
          ),
          AuraSlideToConfirm(label: r'Slide to buy 12 $ANNA', onConfirmed: tap),
        ],
      ),
    ]);
  });

  // No reference image: this checks the inside-a-sheet variants (W05's
  // pattern). Banner and disabled button lift to raised2; hairlines are
  // lineStrong.
  testWidgets('Sheet, inside variants', (tester) async {
    await expectPreview(tester, 'components/SheetInside', height: 460, [
      AuraSheet(
        title: r'Buy $ANNA',
        onClose: tap,
        children: [
          const AuraReceipt(
            rows: [
              AuraReceiptRow(r'20 × A$124.10', r'A$2,482.00'),
              AuraReceiptRow('Fee (0.5%)', r'A$12.41'),
            ],
            total: AuraReceiptRow('Estimated total', r'A$2,494.41'),
          ),
          AuraBanner(
            tone: AuraBannerTone.down,
            title: r'You' + '’' + r're A$229.91 short',
            body: r'You have A$2,264.50. Buy 18 instead.',
            action: 'Buy 18',
            onAction: tap,
          ),
          const AuraButton(
            r'Buy 20 $ANNA',
            variant: AuraButtonVariant.buy,
            block: true,
          ),
        ],
      ),
    ]);
  });
}
