import 'package:decimal/decimal.dart';
import 'package:flutter/widgets.dart';

import '../icons.dart';
import '../tokens.dart';
import '../tone.dart';
import '../widgets/aura_avatar.dart';
import '../widgets/aura_banner.dart';
import '../widgets/aura_button.dart';
import '../widgets/aura_chart.dart';
import '../widgets/aura_chart_tooltip.dart';
import '../widgets/aura_code_field.dart';
import '../widgets/aura_countdown.dart';
import '../widgets/aura_empty_state.dart';
import '../widgets/aura_hero_card.dart';
import '../widgets/aura_icon_button.dart';
import '../widgets/aura_icon_tile.dart';
import '../widgets/aura_impact_disc.dart';
import '../widgets/aura_money.dart';
import '../widgets/aura_nav_card.dart';
import '../widgets/aura_news_row.dart';
import '../widgets/aura_photo_tile.dart';
import '../widgets/aura_price_change.dart';
import '../widgets/aura_quote_card.dart';
import '../widgets/aura_range_bar.dart';
import '../widgets/aura_receipt.dart';
import '../widgets/aura_search_field.dart';
import '../widgets/aura_section_header.dart';
import '../widgets/aura_segmented_control.dart';
import '../widgets/aura_sheet.dart';
import '../widgets/aura_skeleton.dart';
import '../widgets/aura_slide_to_confirm.dart';
import '../widgets/aura_sparkline.dart';
import '../widgets/aura_stat_card.dart';
import '../widgets/aura_status_chip.dart';
import '../widgets/aura_stepper.dart';
import '../widgets/aura_stock_row.dart';
import '../widgets/aura_tab_bar.dart';
import '../widgets/aura_tabs.dart';
import '../widgets/aura_tag.dart';
import '../widgets/aura_tape.dart';
import '../widgets/aura_text_field.dart';
import '../widgets/aura_toast.dart';
import '../widgets/aura_toggle_row.dart';
import '../widgets/aura_wordmark.dart';
import 'fixtures/photos.dart';
import 'gallery_screen.dart';

Decimal _d(String s) => Decimal.parse(s);
void _tap() {}

/// Side-by-side items, wrapping.
Widget _row(List<Widget> children) => Wrap(
  spacing: 16,
  runSpacing: 12,
  crossAxisAlignment: WrapCrossAlignment.center,
  children: children,
);

const _anna = [
  118.0,
  117.6,
  118.5,
  118.2,
  119.0,
  119.8,
  120.5,
  121.0,
  121.5,
  122.2,
  123.0,
  123.4,
  124.1,
];
const _jake = [
  112.4,
  112.2,
  112.5,
  104.0,
  103.6,
  103.0,
  103.4,
  104.2,
  105.1,
  104.6,
  104.9,
  104.5,
];

/// Every component in every state it supports, with fixtures from the drawn
/// screens (W01–W13). Add a state here when a component gains one.
final List<GallerySection> componentStates = [
  GallerySection('Money', [
    GalleryState(
      'Display, one per screen',
      (_) => AuraMoney(_d('12486.20'), size: AuraMoneySize.display),
    ),
    GalleryState(
      'Price, indicated (≈)',
      (_) => AuraMoney(_d('98.70'), size: AuraMoneySize.price, approx: true),
    ),
    GalleryState(
      'Row, small, negative',
      (_) => _row([
        AuraMoney(_d('124.10')),
        AuraMoney(_d('101.90'), size: AuraMoneySize.sm),
        AuraMoney(_d('-888.00')),
      ]),
    ),
  ]),
  GallerySection('PriceChange', [
    GalleryState(
      'Up, down, unchanged',
      (_) => _row([
        AuraPriceChange(abs: _d('7.79'), pct: _d('6.70'), period: 'today'),
        AuraPriceChange(abs: _d('-10.50'), pct: _d('-9.34')),
        AuraPriceChange(pct: _d('0')),
      ]),
    ),
    GalleryState(
      'Small (rows) and large (headers)',
      (_) => _row([
        AuraPriceChange(pct: _d('-2.40'), size: AuraChangeSize.sm),
        AuraPriceChange(
          abs: _d('2486.20'),
          pct: _d('24.86'),
          period: 'this season',
          size: AuraChangeSize.lg,
        ),
      ]),
    ),
  ]),
  GallerySection('Countdown', [
    GalleryState(
      'Neutral, at risk, over an hour',
      (_) => _row(const [
        AuraCountdown(
          label: 'Ruling in',
          time: Duration(minutes: 6, seconds: 42),
        ),
        AuraCountdown(
          label: 'Quote expires',
          time: Duration(seconds: 9),
          warn: true,
        ),
        AuraCountdown(
          label: 'Opens in',
          time: Duration(hours: 4, minutes: 18, seconds: 2),
        ),
      ]),
    ),
  ]),
  GallerySection('ImpactDisc', [
    GalleryState(
      'Loss, gain, lore',
      (_) => _row(const [
        AuraImpactDisc(delta: -18, label: 'Loss'),
        AuraImpactDisc(delta: 22, label: 'Gain'),
        AuraImpactDisc(delta: 0, label: 'Lore'),
      ]),
    ),
  ]),
  GallerySection('Avatar', [
    GalleryState(
      'Row (36) and header (40)',
      (_) => _row(const [AuraAvatar('A', size: 36), AuraAvatar('J')]),
    ),
  ]),
  GallerySection('Tag', [
    GalleryState(
      'Neutral, SEC, halted',
      (_) => _row(const [
        AuraTag('Holding'),
        AuraTag('Short'),
        AuraTag('Rumor'),
        AuraTag('SEC', tone: AuraTone.down),
        AuraTag('Halted', tone: AuraTone.warn),
      ]),
    ),
  ]),
  GallerySection('StatusChip', [
    GalleryState(
      'Market states (with a dot)',
      (_) => _row([
        for (final s in AuraStatus.values.where((s) => s.dot))
          AuraStatusChip(s),
      ]),
    ),
    GalleryState(
      'Object states',
      (_) => _row([
        for (final s in AuraStatus.values.where((s) => !s.dot))
          AuraStatusChip(s),
      ]),
    ),
    GalleryState(
      'With detail; glass',
      (_) => _row(const [
        AuraStatusChip(AuraStatus.closed, label: 'Closed · opens 7:00 am'),
        AuraStatusChip(AuraStatus.halted, label: 'Halted · news pending'),
        AuraStatusChip(
          AuraStatus.closed,
          label: 'Closed · opens 7:00 am',
          glass: true,
        ),
      ]),
    ),
  ]),
  GallerySection('Icon', [
    GalleryState(
      'All ${AuraIcons.values.length}, and filled',
      (_) => _row([
        for (final i in AuraIcons.values)
          AuraIcon(i, color: AuraColors.inkSecondary, semanticLabel: i.name),
        const AuraIcon(AuraIcons.star, filled: true),
      ]),
    ),
  ]),
  GallerySection('IconButton', [
    GalleryState(
      'Plain, badge, filled, small, disabled',
      (_) => _row([
        const AuraIconButton(
          icon: AuraIcons.back,
          label: 'Back',
          onPressed: _tap,
        ),
        const AuraIconButton(
          icon: AuraIcons.bell,
          label: 'Notifications, 3 unread',
          badge: true,
          onPressed: _tap,
        ),
        const AuraIconButton(
          icon: AuraIcons.star,
          label: 'Remove from watchlist',
          filled: true,
          onPressed: _tap,
        ),
        const AuraIconButton(
          icon: AuraIcons.eyeOff,
          label: 'Hide balance',
          small: true,
          onPressed: _tap,
        ),
        const AuraIconButton(icon: AuraIcons.minus, label: 'One fewer'),
      ]),
    ),
  ]),
  GallerySection('Button', [
    GalleryState(
      'Large: secondary and buy',
      (_) => const Row(
        spacing: 10,
        children: [
          Expanded(
            child: AuraButton(
              'Sell',
              icon: AuraIcons.minus,
              block: true,
              onPressed: _tap,
            ),
          ),
          Expanded(
            child: AuraButton(
              'Buy',
              icon: AuraIcons.plus,
              variant: AuraButtonVariant.buy,
              block: true,
              onPressed: _tap,
            ),
          ),
        ],
      ),
    ),
    GalleryState(
      'Medium: primary, secondary, ghost, danger',
      (_) => _row([
        const AuraButton(
          'Invite friends',
          variant: AuraButtonVariant.primary,
          size: AuraButtonSize.md,
          onPressed: _tap,
        ),
        const AuraButton(
          'Short more',
          size: AuraButtonSize.md,
          onPressed: _tap,
        ),
        const AuraButton(
          'Not now',
          variant: AuraButtonVariant.ghost,
          size: AuraButtonSize.md,
          onPressed: _tap,
        ),
        const AuraButton(
          'Declare bankruptcy',
          variant: AuraButtonVariant.danger,
          size: AuraButtonSize.md,
          onPressed: _tap,
        ),
      ]),
    ),
    GalleryState(
      'Disabled, with its reason',
      (_) => Column(
        spacing: 8,
        children: [
          const Row(
            spacing: 10,
            children: [
              Expanded(child: AuraButton('Sell', block: true)),
              Expanded(
                child: AuraButton(
                  'Buy',
                  variant: AuraButtonVariant.buy,
                  block: true,
                ),
              ),
            ],
          ),
          Text(
            'Trading resumes when the vote closes.',
            style: AuraType.footnote.copyWith(
              color: AuraColors.inkSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    ),
  ]),
  GallerySection('SlideToConfirm', [
    GalleryState(
      'Buy',
      (_) => const AuraSlideToConfirm(
        label: r'Slide to buy 12 $ANNA',
        onConfirmed: _tap,
      ),
    ),
    GalleryState(
      'Short or bankruptcy (down knob)',
      (_) => const AuraSlideToConfirm(
        label: r'Slide to short 20 $JAKE',
        down: true,
        onConfirmed: _tap,
      ),
    ),
    GalleryState(
      'Disabled',
      (_) => const AuraSlideToConfirm(label: r'Slide to buy 12 $ANNA'),
    ),
  ]),
  GallerySection('Stepper', [
    GalleryState('Live (tap ± or hold)', (_) => const _LiveStepper(start: 20)),
    GalleryState('At one: minus off', (_) => const _LiveStepper(start: 1)),
  ]),
  GallerySection('SegmentedControl', [
    GalleryState(
      'Chart ranges (live)',
      (_) => const _LiveSegments(
        options: ['1D', '1W', '1M', 'SZN', 'ALL'],
        start: '1M',
      ),
    ),
    GalleryState(
      'Order types',
      (_) => const _LiveSegments(
        options: ['Market', 'Limit', 'Stop'],
        start: 'Market',
      ),
    ),
  ]),
  GallerySection('Tabs', [
    GalleryState('Stock page sections (live)', (_) => const _LiveTabs()),
  ]),
  GallerySection('SearchField', [
    GalleryState('Default', (_) => const AuraSearchField()),
    GalleryState(
      'Empty exchange (disabled)',
      (_) => const AuraSearchField(
        placeholder: 'Nobody to search yet',
        enabled: false,
      ),
    ),
  ]),
  GallerySection('TextField', [
    GalleryState(
      'Empty, with help',
      (_) => const _LiveTextField(
        label: 'Email',
        placeholder: 'you@example.com',
        note: "We'll email you a 6-digit code. No password.",
      ),
    ),
    GalleryState(
      'Filled',
      (_) => const _LiveTextField(label: 'Email', text: 'nathan@example.com'),
    ),
    GalleryState(
      'A problem (glyph in down)',
      (_) => const _LiveTextField(
        label: 'Email',
        text: 'nathan@example',
        note: "That email address doesn't look right. Check it and try again.",
        noteTone: AuraTone.down,
      ),
    ),
    GalleryState(
      'Ticker, with a prefix',
      (_) => const _LiveTextField(
        label: 'Ticker',
        prefix: r'$',
        text: 'NATE',
        note: '3 to 5 letters. This is how the tape will name you.',
      ),
    ),
    GalleryState(
      'Disabled',
      (_) => const _LiveTextField(
        label: 'Email',
        text: 'nathan@example.com',
        enabled: false,
      ),
    ),
    GalleryState(
      'Read-only (an invite link)',
      (_) => const _LiveTextField(
        label: 'Invite link',
        text: 'https://aura.example/i/JAKE-7F2K',
        readOnly: true,
      ),
    ),
    GalleryState(
      'Inside a sheet',
      (_) => const AuraSheet(
        title: 'Name your exchange',
        children: [
          _LiveTextField(label: 'Name', placeholder: 'The Group Chat'),
        ],
      ),
    ),
  ]),
  GallerySection('CodeField', [
    GalleryState(
      'Empty, the first cell marked',
      (_) => const _LiveCodeField(note: 'We sent it to nathan@example.com.'),
    ),
    GalleryState('Part-way', (_) => const _LiveCodeField(text: '482')),
    GalleryState('Complete', (_) => const _LiveCodeField(text: '482913')),
    GalleryState(
      'Wrong code (glyph in down)',
      (_) => const _LiveCodeField(
        text: '482914',
        note: "That code isn't right. You have 2 more tries.",
        noteTone: AuraTone.down,
      ),
    ),
    GalleryState(
      'Checking (disabled)',
      (_) => const _LiveCodeField(text: '482913', enabled: false),
    ),
  ]),
  GallerySection('SectionHeader', [
    GalleryState('Plain', (_) => const AuraSectionHeader('Your moves')),
    GalleryState(
      'With status and link',
      (_) => const AuraSectionHeader(
        'Watchlist',
        status: AuraStatus.delayed,
        statusLabel: 'As of 9:41 pm',
        action: 'Edit',
        onAction: _tap,
      ),
    ),
  ]),
  GallerySection('StatCard', [
    GalleryState(
      'Two columns, tones, trailing',
      (_) => const AuraStatGrid(
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
    ),
    GalleryState(
      'Three columns (W01)',
      (_) => const AuraStatGrid(
        columns: 3,
        children: [
          AuraStatCard(label: 'Ruling in', value: '9:12'),
          AuraStatCard(label: 'Co-signs', value: '2'),
          AuraStatCard(label: 'Receipts', value: '1'),
        ],
      ),
    ),
  ]),
  GallerySection('RangeBar', [
    GalleryState(
      'Season range, near high',
      (_) => AuraRangeBar(
        low: _d('88.40'),
        high: _d('126.30'),
        current: _d('124.10'),
        note: 'Near high',
      ),
    ),
    GalleryState(
      'Entry to liquidation (W07)',
      (_) => AuraRangeBar(
        label: 'From your entry to liquidation',
        low: _d('97.50'),
        high: _d('117.00'),
        current: _d('112.30'),
        note: '4.2% away',
        noteTone: AuraTone.warn,
      ),
    ),
  ]),
  GallerySection('Sparkline', [
    GalleryState(
      'Up, down, flat, at previous close',
      (_) => _row(const [
        AuraSparkline(points: _anna),
        AuraSparkline(points: _jake),
        AuraSparkline(points: [10, 14, 6, 12, 8, 16, 10, 10]),
        AuraSparkline(points: _jake, previousClose: 112.4, width: 72),
      ]),
    ),
  ]),
  GallerySection('Chart', [
    GalleryState(
      '1D, up on the previous close, with a ruling',
      (_) => AuraChart(
        points: _chartPoints(_anna),
        previousClose: _d('116.31'),
        markers: [
          AuraChartMarker(
            at: _chartStart.add(const Duration(minutes: 90)),
            label: '+22 ruling',
            tone: AuraTone.up,
          ),
        ],
      ),
    ),
    GalleryState(
      'Scrubbing onto a ruling',
      (_) => AuraChart(
        points: _chartPoints(_jakeChart),
        previousClose: _d('112.40'),
        markers: [
          AuraChartMarker(
            at: _chartStart.add(const Duration(minutes: 45)),
            label: '−18 ruling',
            tone: AuraTone.down,
          ),
        ],
        scrubbing: 3,
      ),
    ),
    GalleryState(
      'No trades yet',
      (_) => const AuraChart(points: [], height: 120),
    ),
  ]),
  GallerySection('ChartTooltip', [
    GalleryState(
      'Ruling up, ruling down, rumor, plain',
      (_) => _row([
        AuraChartTooltip(
          price: _d('118.20'),
          badge: '+22 ruling',
          tone: AuraTone.up,
        ),
        AuraChartTooltip(
          price: _d('98.70'),
          badge: '−18 ruling',
          tone: AuraTone.down,
        ),
        AuraChartTooltip(price: _d('99.20'), badge: 'Rumor'),
        AuraChartTooltip(price: _d('124.10')),
      ]),
    ),
  ]),
  GallerySection('StockRow', [
    GalleryState(
      'Holding, short, SEC, halted, no chart',
      (_) => Column(
        children: [
          AuraStockRow(
            ticker: r'$ANNA',
            name: 'Anna',
            tag: 'Holding',
            price: _d('124.10'),
            abs: _d('7.79'),
            pct: _d('6.70'),
            points: _anna,
            onTap: _tap,
          ),
          AuraStockRow(
            ticker: r'$JAKE',
            name: 'Jake',
            tag: 'Short',
            price: _d('101.90'),
            abs: _d('-10.50'),
            pct: _d('-9.34'),
            points: _jake,
            onTap: _tap,
          ),
          AuraStockRow(
            ticker: r'$SAM',
            name: 'Sam',
            tag: 'SEC',
            tagTone: AuraTone.down,
            price: _d('92.05'),
            abs: _d('-4.74'),
            pct: _d('-4.90'),
            onTap: _tap,
          ),
          AuraStockRow(
            ticker: r'$MIA',
            name: 'Mia',
            tag: 'Halted',
            tagTone: AuraTone.warn,
            price: _d('96.20'),
            abs: _d('0'),
            pct: _d('0'),
            onTap: _tap,
          ),
        ],
      ),
    ),
    GalleryState(
      'Not traded yet (an invite preview)',
      (_) => const AuraStockRow(ticker: r'$ANNA', name: 'Anna'),
    ),
  ]),
  GallerySection('HeroCard', [
    GalleryState('Net worth, hideable (live)', (_) => const _LiveHero()),
    GalleryState(
      'Indicated, with a note',
      (_) => AuraHeroCard(
        label: 'Lands at the 7:00 am open',
        value: _d('98.70'),
        approx: true,
        pct: _d('-12.20'),
        note: r'From A$112.40 · indicated, not traded yet',
      ),
    ),
    GalleryState(
      'With round shortcuts',
      (_) => AuraHeroCard(
        label: 'Cash',
        value: _d('2264.50'),
        actions: const [
          AuraActionButton(
            icon: AuraIcons.trade,
            label: 'Trade',
            onPressed: _tap,
          ),
          AuraActionButton(
            icon: AuraIcons.file,
            label: 'File',
            onPressed: _tap,
          ),
          AuraActionButton(
            icon: AuraIcons.alarm,
            label: 'Alerts',
            onPressed: _tap,
          ),
          AuraActionButton(
            icon: AuraIcons.trophy,
            label: 'Leaders',
            onPressed: _tap,
          ),
        ],
      ),
    ),
  ]),
  GallerySection('NavCard', [
    GalleryState(
      'Rows with trailing notes (W02)',
      (_) => const AuraNavCard(
        children: [
          AuraNavRow(
            icon: AuraIcons.chat,
            title: 'Post a statement',
            subtitle: 'Runs on the tape next to the story',
            onTap: _tap,
          ),
          AuraNavRow(
            icon: AuraIcons.hide,
            title: 'Super-injunction',
            subtitle: 'Hides the story · the price hit stays',
            trailing: '2 of 3 left',
            onTap: _tap,
          ),
          AuraNavRow(
            icon: AuraIcons.alert,
            title: 'Deny it',
            subtitle: 'If it’s confirmed, the hit is 20% bigger',
            trailing: 'Risky',
            trailingTone: AuraTone.warn,
            onTap: _tap,
          ),
        ],
      ),
    ),
    GalleryState(
      'A single row',
      (_) => const AuraNavCard(
        children: [
          AuraNavRow(
            icon: AuraIcons.bell,
            title: 'Closing bell recap',
            subtitle: r'$ANNA led; $SAM charged by the SEC',
            onTap: _tap,
          ),
        ],
      ),
    ),
  ]),
  GallerySection('NewsRow', [
    GalleryState(
      'A ruling, with the move it caused',
      (_) => AuraNewsRow(
        source: r'$JAKE · Ruling · 2 h ago',
        headline:
            'Jake indicated sharply lower after overnight “who is this” '
            'incident',
        movePct: _d('-12.19'),
        onTap: _tap,
      ),
    ),
    GalleryState(
      'Unread, no move',
      (_) => const AuraNewsRow(
        source: r'$MIA · Rumor · 4 min ago',
        headline: 'Unconfirmed: reports of a late-night karaoke incident.',
        unread: true,
        onTap: _tap,
      ),
    ),
  ]),
  GallerySection('QuoteCard', [
    GalleryState(
      'Analyst note',
      (_) => const AuraQuoteCard(
        quote: '“We are moving to Underweight. Management reached out to a former partner at 2 a.m. without a clear strategy and received no recognition in return.”',
        source: r'The Analyst · Downgrade · target A$96.00',
      ),
    ),
  ]),
  GallerySection('Receipt', [
    GalleryState(
      'Liquidation (W08)',
      (_) => const AuraReceipt(
        rows: [
          AuraReceiptRow('Collateral held', r'A$8,775.00'),
          AuraReceiptRow(r'Bought back 60 at A$118.10', '−A\$7,086.00'),
          AuraReceiptRow('Fee (0.5%)', '−A\$35.43'),
        ],
        total: AuraReceiptRow('Returned', r'A$1,653.57'),
      ),
    ),
    GalleryState(
      'With a toned total (W03)',
      (_) => const AuraReceipt(
        rows: [
          AuraReceiptRow('Profit when it ruled', r'A$210.00'),
          AuraReceiptRow('Odds of getting caught', '27%'),
        ],
        total: AuraReceiptRow(
          'Clawed back + fine',
          r'A$315.00',
          tone: AuraTone.down,
        ),
      ),
    ),
  ]),
  GallerySection('Banner', [
    GalleryState(
      'Neutral',
      (_) => const AuraBanner(
        title: 'Closed until 7:00 am',
        body: r'A ruling on $JAKE lands at the open, so it will gap. Orders you set now fill at the opening price.',
      ),
    ),
    GalleryState(
      'Offline, with Retry',
      (_) => const AuraBanner(
        tone: AuraBannerTone.offline,
        title: 'You’re offline',
        body: 'Prices are from 9:41 pm. Trading and filing wait until you’re back.',
        action: 'Retry',
        onAction: _tap,
      ),
    ),
    GalleryState(
      'Warn',
      (_) => const AuraBanner(
        tone: AuraBannerTone.warn,
        title: r'Your $JAKE short is close to liquidation',
        body: '4.2% more and the exchange covers it for you.',
      ),
    ),
    GalleryState(
      'Down, with the fix',
      (_) => const AuraBanner(
        tone: AuraBannerTone.down,
        title: r'You’re A$229.91 short',
        body: r'You have A$2,264.50. Buy 18 instead, sell something, or wait for tomorrow’s stimulus check.',
        action: 'Buy 18',
        onAction: _tap,
      ),
    ),
    GalleryState(
      'Rumor (insider notice)',
      (_) => const AuraBanner(
        tone: AuraBannerTone.rumor,
        title: 'You’re an insider on this one',
        body: r'Trading $ELI until 1:21 pm may get the SEC’s attention.',
      ),
    ),
  ]),
  GallerySection('IconTile', [
    GalleryState(
      'Empty state, 44 pt',
      (_) => const AuraIconTile(AuraIcons.tape),
    ),
    GalleryState(
      'A screen that is the message, 52 pt, warn (W13)',
      (_) => const AuraIconTile(AuraIcons.alert, size: 52, tone: AuraTone.warn),
    ),
  ]),
  GallerySection('PhotoTile', [
    GalleryState(
      'Add a receipt',
      (_) => const AuraPhotoTile.add(label: 'Add a receipt', onTap: _tap),
    ),
    GalleryState(
      'Uploaded, with remove',
      (_) => AuraPhotoTile(
        image: fixturePhoto(0),
        label: 'Receipt 1',
        onRemove: _tap,
        removeLabel: 'Remove receipt 1',
      ),
    ),
    GalleryState(
      'Uploading, 60% sent',
      (_) => AuraPhotoTile(
        image: fixturePhoto(1),
        label: 'Receipt 2, uploading',
        status: AuraPhotoStatus.uploading,
        progress: 0.6,
        onRemove: _tap,
        removeLabel: 'Remove receipt 2',
      ),
    ),
    GalleryState(
      "Didn't upload: tap to try again",
      (_) => AuraPhotoTile(
        image: fixturePhoto(3),
        label: "Receipt 3, didn't upload",
        status: AuraPhotoStatus.failed,
        onTap: _tap,
        onRemove: _tap,
        removeLabel: 'Remove receipt 3',
      ),
    ),
    GalleryState(
      'A row, as in the filing sheet',
      (_) => _row([
        for (var i = 0; i < 3; i++)
          AuraPhotoTile(
            image: fixturePhoto(i),
            label: 'Receipt ${i + 1}',
            onRemove: _tap,
            removeLabel: 'Remove receipt ${i + 1}',
          ),
        const AuraPhotoTile.add(label: 'Add a receipt', onTap: _tap),
      ]),
    ),
  ]),
  GallerySection('Wordmark', [
    GalleryState(
      'The lockup, as on the launch and boot screens',
      (_) => const AuraWordmark(),
    ),
  ]),
  GallerySection('Skeleton', [
    GalleryState(
      'A row, a title and a paragraph (still with Reduce Motion)',
      (_) => const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          AuraSkeletonText(style: AuraType.title, width: 180),
          AuraSkeletonText(style: AuraType.body, lines: 3),
          AuraSkeleton(height: 48, radius: AuraRadius.md),
        ],
      ),
    ),
    GalleryState(
      'Inside a sheet',
      (_) => const AuraSheet(
        title: 'Loading',
        children: [AuraSkeleton(height: 48, radius: AuraRadius.md)],
      ),
    ),
  ]),
  GallerySection('EmptyState', [
    GalleryState(
      'No positions',
      (_) => const AuraEmptyState(
        icon: AuraIcons.portfolio,
        title: 'No positions yet',
        body: 'Your portfolio is all cash. Very conservative. Buy or short a friend to get started.',
        action: 'Browse the market',
        onAction: _tap,
      ),
    ),
    GalleryState(
      'Without an action',
      (_) => const AuraEmptyState(
        title: 'Nothing on the tape yet',
        body: 'It fills up as the group files events.',
      ),
    ),
  ]),
  GallerySection('ToggleRow', [
    GalleryState(
      'On and off (live)',
      (_) => const Column(
        children: [
          _LiveToggle(
            title: 'Rumors about you',
            subtitle: 'The moment one is filed',
            start: true,
          ),
          _LiveToggle(title: 'Order fills', start: false),
        ],
      ),
    ),
    GalleryState(
      'Disabled, saying why',
      (_) => const AuraToggleRow(
        title: 'Margin warnings',
        subtitle: 'Always on while you hold a short',
        value: true,
      ),
    ),
  ]),
  GallerySection('Toast', [
    GalleryState(
      'Unsend window',
      (_) => const AuraToast(
        icon: AuraIcons.file,
        message: 'Filed. The rumor goes live in 0:28.',
        action: 'Undo',
        onAction: _tap,
      ),
    ),
    GalleryState(
      'Filled, with View',
      (_) => const AuraToast(
        icon: AuraIcons.trade,
        message: r'Bought 12 $ANNA at A$124.06.',
        action: 'View',
        onAction: _tap,
      ),
    ),
    GalleryState(
      'Message only',
      (_) => const AuraToast(
        message: 'Too many requests. Try again in 30 seconds.',
      ),
    ),
  ]),
  GallerySection('Sheet', [
    GalleryState(
      'Trade ticket',
      (_) => AuraSheet(
        title: r'Buy $ANNA',
        onClose: _tap,
        children: [
          AuraStatGrid(
            children: [
              const AuraStatCard(label: 'Shares', value: '12'),
              AuraStatCard(
                label: 'Est. cost',
                valueChild: AuraMoney(_d('1496.40')),
              ),
            ],
          ),
          const AuraBanner(
            title: 'Quote holds for 0:15',
            body: r'Price impact 0.4% · fee A$7.44',
          ),
          const AuraSlideToConfirm(
            label: r'Slide to buy 12 $ANNA',
            onConfirmed: _tap,
          ),
        ],
      ),
    ),
    GalleryState(
      'Inside: search, disabled button, segments',
      (_) => const AuraSheet(
        title: 'Pick a subject',
        onClose: _tap,
        children: [
          AuraSearchField(placeholder: 'Search friends'),
          _LiveSegments(options: ['Market', 'Limit', 'Stop'], start: 'Market'),
          AuraButton(
            'File an event',
            variant: AuraButtonVariant.primary,
            block: true,
          ),
        ],
      ),
    ),
  ]),
  GallerySection('TabBar', [
    GalleryState(
      'Each tab active (live), tape badge',
      (_) => const Center(child: _LiveTabBar()),
    ),
  ]),
  GallerySection('Tape', [
    GalleryState(
      'Scrolling (still with Reduce Motion)',
      (_) => AuraTape(
        items: [
          AuraTapeItem(ticker: r'$ANNA', price: _d('124.10'), pct: _d('6.70')),
          AuraTapeItem(ticker: r'$JAKE', price: _d('98.70'), pct: _d('-12.19')),
          AuraTapeItem(ticker: r'$NATE', price: _d('100.00'), pct: _d('0')),
          AuraTapeItem(ticker: r'$ELI', price: _d('87.55'), pct: _d('-2.40')),
        ],
      ),
    ),
    GalleryState(
      'IPO day: one listing',
      (_) => AuraTape(
        items: [
          AuraTapeItem(ticker: r'$NATE', price: _d('100.00'), pct: _d('0')),
        ],
      ),
    ),
  ]),
];

class _LiveStepper extends StatefulWidget {
  const _LiveStepper({required this.start});

  final int start;

  @override
  State<_LiveStepper> createState() => _LiveStepperState();
}

class _LiveStepperState extends State<_LiveStepper> {
  late Decimal _value = Decimal.fromInt(widget.start);

  @override
  Widget build(BuildContext context) => AuraStepper(
    value: _value,
    note: r'shares at about A$124.10',
    onChanged: (v) => setState(() => _value = v),
  );
}

class _LiveSegments extends StatefulWidget {
  const _LiveSegments({required this.options, required this.start});

  final List<String> options;
  final String start;

  @override
  State<_LiveSegments> createState() => _LiveSegmentsState();
}

class _LiveSegmentsState extends State<_LiveSegments> {
  late String _value = widget.start;

  @override
  Widget build(BuildContext context) => AuraSegmentedControl(
    options: widget.options,
    value: _value,
    label: 'Choice',
    onChanged: (v) => setState(() => _value = v),
  );
}

class _LiveTabs extends StatefulWidget {
  const _LiveTabs();

  @override
  State<_LiveTabs> createState() => _LiveTabsState();
}

class _LiveTabsState extends State<_LiveTabs> {
  String _value = 'Overview';

  @override
  Widget build(BuildContext context) => AuraTabs(
    items: const ['Overview', 'Tape', 'Holders', 'Analyst'],
    value: _value,
    onChanged: (v) => setState(() => _value = v),
  );
}

class _LiveHero extends StatefulWidget {
  const _LiveHero();

  @override
  State<_LiveHero> createState() => _LiveHeroState();
}

class _LiveHeroState extends State<_LiveHero> {
  bool _hidden = false;

  @override
  Widget build(BuildContext context) => AuraHeroCard(
    label: 'Net worth · Season 1',
    value: _d('12486.20'),
    abs: _d('2486.20'),
    pct: _d('24.86'),
    period: 'this season',
    hideable: true,
    hidden: _hidden,
    onToggleHidden: () => setState(() => _hidden = !_hidden),
  );
}

class _LiveTabBar extends StatefulWidget {
  const _LiveTabBar();

  @override
  State<_LiveTabBar> createState() => _LiveTabBarState();
}

class _LiveTabBarState extends State<_LiveTabBar> {
  AuraTab _active = AuraTab.home;

  @override
  Widget build(BuildContext context) => AuraTabBar(
    active: _active,
    tapeBadge: _active != AuraTab.tape,
    onSelect: (t) => setState(() => _active = t),
  );
}

/// A text field that keeps what's typed into it, for the gallery.
class _LiveTextField extends StatefulWidget {
  const _LiveTextField({
    required this.label,
    this.text,
    this.placeholder,
    this.prefix,
    this.note,
    this.noteTone = AuraTone.neutral,
    this.enabled = true,
    this.readOnly = false,
  });

  final String label;
  final String? text;
  final String? placeholder;
  final String? prefix;
  final String? note;
  final AuraTone noteTone;
  final bool enabled;
  final bool readOnly;

  @override
  State<_LiveTextField> createState() => _LiveTextFieldState();
}

class _LiveTextFieldState extends State<_LiveTextField> {
  late final _controller = TextEditingController(text: widget.text);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AuraTextField(
    label: widget.label,
    controller: _controller,
    placeholder: widget.placeholder,
    prefix: widget.prefix,
    note: widget.note,
    noteTone: widget.noteTone,
    enabled: widget.enabled,
    readOnly: widget.readOnly,
  );
}

/// A code field that keeps what's typed into it, for the gallery.
class _LiveCodeField extends StatefulWidget {
  const _LiveCodeField({
    this.text = '',
    this.note,
    this.noteTone = AuraTone.neutral,
    this.enabled = true,
  });

  final String text;
  final String? note;
  final AuraTone noteTone;
  final bool enabled;

  @override
  State<_LiveCodeField> createState() => _LiveCodeFieldState();
}

class _LiveCodeFieldState extends State<_LiveCodeField> {
  late final _controller = TextEditingController(text: widget.text);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AuraCodeField(
    controller: _controller,
    note: widget.note,
    noteTone: widget.noteTone,
    enabled: widget.enabled,
  );
}

final _chartStart = DateTime.utc(2026, 10, 24);

List<AuraChartPoint> _chartPoints(List<double> prices) => [
  for (final (i, p) in prices.indexed)
    AuraChartPoint(
      _chartStart.add(Duration(minutes: 15 * i)),
      Decimal.parse(p.toStringAsFixed(2)),
    ),
];

const _jakeChart = [
  112.4, 112.2, 112.5, 104.0, 103.6, 103.0, //
  103.4, 104.2, 105.1, 104.6, 104.9, 101.9,
];

/// A toggle row that flips, for the gallery.
class _LiveToggle extends StatefulWidget {
  const _LiveToggle({required this.title, required this.start, this.subtitle});

  final String title;
  final String? subtitle;
  final bool start;

  @override
  State<_LiveToggle> createState() => _LiveToggleState();
}

class _LiveToggleState extends State<_LiveToggle> {
  late bool _on = widget.start;

  @override
  Widget build(BuildContext context) => AuraToggleRow(
    title: widget.title,
    subtitle: widget.subtitle,
    value: _on,
    onChanged: (v) => setState(() => _on = v),
  );
}
