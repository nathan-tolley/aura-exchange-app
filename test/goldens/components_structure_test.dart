@Tags(['golden'])
library;

import 'package:aura_exchange/design/icons.dart';
import 'package:aura_exchange/design/tone.dart';
import 'package:aura_exchange/design/widgets/aura_banner.dart';
import 'package:aura_exchange/design/widgets/aura_empty_state.dart';
import 'package:aura_exchange/design/widgets/aura_nav_card.dart';
import 'package:aura_exchange/design/widgets/aura_quote_card.dart';
import 'package:aura_exchange/design/widgets/aura_range_bar.dart';
import 'package:aura_exchange/design/widgets/aura_receipt.dart';
import 'package:aura_exchange/design/widgets/aura_section_header.dart';
import 'package:aura_exchange/design/widgets/aura_stat_card.dart';
import 'package:aura_exchange/design/widgets/aura_status_chip.dart';
import 'package:aura_exchange/design/widgets/aura_toast.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/golden.dart';

/// Goldens for the structural components (headers, spec sheets, receipts,
/// lists, banners), drawn with the same content as
/// `design/reference/components/<Name>.png`.
void main() {
  Decimal d(String s) => Decimal.parse(s);
  void tap() {}

  testWidgets('SectionHeader', (tester) async {
    await expectPreview(tester, 'components/SectionHeader', [
      AuraSectionHeader(
        'Watchlist',
        status: AuraStatus.open,
        action: 'View all',
        onAction: tap,
      ),
      const AuraSectionHeader('How it was scored'),
    ]);
  });

  testWidgets('StatCard', (tester) async {
    await expectPreview(tester, 'components/StatCard', [
      const AuraStatGrid(
        children: [
          AuraStatCard(label: 'Market cap', value: r'A$124.1M'),
          AuraStatCard(label: 'Volume', value: '2,140'),
          AuraStatCard(
            label: 'Short interest',
            value: '18.2%',
            trailing: 'Hard to borrow',
            trailingTone: AuraTone.warn,
          ),
          AuraStatCard(
            label: 'Analyst',
            value: 'Underweight',
            tone: AuraTone.down,
          ),
        ],
      ),
    ]);
  });

  testWidgets('RangeBar', (tester) async {
    await expectPreview(tester, 'components/RangeBar', [
      AuraRangeBar(
        low: d('88.40'),
        high: d('126.30'),
        current: d('124.10'),
        note: 'Near high',
      ),
    ]);
  });

  testWidgets('Receipt', (tester) async {
    await expectPreview(tester, 'components/Receipt', [
      const AuraReceipt(
        rows: [
          AuraReceiptRow('Shares bought back', '60'),
          AuraReceiptRow('Average price', r'A$118.10'),
          AuraReceiptRow('Fee', r'A$35.43'),
          AuraReceiptRow('Collateral held', r'A$8,775.00'),
        ],
        total: AuraReceiptRow('Returned to your cash', r'A$1,653.57'),
      ),
    ]);
  });

  testWidgets('NavCard', (tester) async {
    await expectPreview(tester, 'components/NavCard', [
      AuraNavCard(
        children: [
          AuraNavRow(
            icon: AuraIcons.chat,
            title: 'Post a statement',
            subtitle: 'Runs on the tape next to the story',
            onTap: tap,
          ),
          AuraNavRow(
            icon: AuraIcons.hide,
            title: 'Super-injunction',
            subtitle: 'Hides the story · price hit stays',
            trailing: '2 of 3 left',
            onTap: tap,
          ),
          AuraNavRow(
            icon: AuraIcons.gavel,
            title: 'Appeal',
            subtitle: 'The admin reviews it',
            trailing: '6 days left',
            trailingTone: AuraTone.warn,
            onTap: tap,
          ),
        ],
      ),
      AuraNavCard(
        children: [
          AuraNavRow(
            icon: AuraIcons.bell,
            title: 'Closing bell recap',
            subtitle: r'$ANNA led; $SAM charged by the SEC',
            onTap: tap,
          ),
        ],
      ),
    ]);
  });

  testWidgets('QuoteCard', (tester) async {
    await expectPreview(tester, 'components/QuoteCard', [
      const AuraQuoteCard(
        quote:
            '“We are moving to Underweight. Management reached out to a former '
            'partner at 2 a.m. without a clear strategy and received no '
            'recognition in return.”',
        source: r'The Analyst · Downgrade · target A$96.00',
      ),
    ]);
  });

  testWidgets('Banner', (tester) async {
    await expectPreview(tester, 'components/Banner', height: 483, [
      const AuraBanner(
        title: 'Market closed',
        body: 'Reopens 7:00 am · 3 events queued for the open',
      ),
      const AuraBanner(
        tone: AuraBannerTone.offline,
        title: 'You’re offline',
        body:
            'Prices delayed · as of 9:41 pm. Trading is paused until you '
            'reconnect.',
      ),
      AuraBanner(
        tone: AuraBannerTone.warn,
        title: r'Margin warning on $JAKE',
        body: r'Your short liquidates at A$117.00, 4.1% away.',
        action: 'Cover',
        onAction: tap,
      ),
      AuraBanner(
        tone: AuraBannerTone.down,
        title: r'You’re A$230.00 short',
        body: 'Sell something or wait for Monday’s stimulus check.',
        action: 'Sell',
        onAction: tap,
      ),
      const AuraBanner(
        tone: AuraBannerTone.rumor,
        title: 'You’re an insider on this one',
        body: r'Trading $ELI until 1:21 pm may get the SEC’s attention.',
      ),
    ]);
  });

  testWidgets('EmptyState', (tester) async {
    await expectPreview(tester, 'components/EmptyState', [
      AuraEmptyState(
        icon: AuraIcons.portfolio,
        title: 'No positions yet',
        body:
            'Your portfolio is all cash. Very conservative. Buy or short a '
            'friend to get started.',
        action: 'Browse the market',
        onAction: tap,
      ),
    ]);
  });

  testWidgets('Toast', (tester) async {
    await expectPreview(tester, 'components/Toast', [
      AuraToast(
        icon: AuraIcons.file,
        message: 'Filed. The rumor goes live in 0:28.',
        action: 'Undo',
        onAction: tap,
      ),
      AuraToast(
        icon: AuraIcons.trade,
        message: r'Bought 12 $ANNA at A$124.06.',
        action: 'View',
        onAction: tap,
      ),
    ]);
  });
}
