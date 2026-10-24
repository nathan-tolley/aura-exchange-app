@Tags(['golden'])
library;

import 'package:aura_exchange/design/icons.dart';
import 'package:aura_exchange/design/widgets/aura_avatar.dart';
import 'package:aura_exchange/design/widgets/aura_countdown.dart';
import 'package:aura_exchange/design/widgets/aura_icon_button.dart';
import 'package:aura_exchange/design/widgets/aura_impact_disc.dart';
import 'package:aura_exchange/design/widgets/aura_money.dart';
import 'package:aura_exchange/design/widgets/aura_price_change.dart';
import 'package:aura_exchange/design/widgets/aura_status_chip.dart';
import 'package:aura_exchange/design/widgets/aura_tag.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/golden.dart';

/// One golden per component preview, drawn with the same content as
/// `design/reference/components/<Name>.png` so the two can be compared.
void main() {
  Decimal d(String s) => Decimal.parse(s);

  testWidgets('Money', (tester) async {
    await expectPreview(tester, 'components/Money', [
      AuraMoney(d('12486.20'), size: AuraMoneySize.display),
      previewRow([
        AuraMoney(d('124.10'), size: AuraMoneySize.price),
        AuraMoney(d('98.70'), size: AuraMoneySize.price, approx: true),
        AuraMoney(d('101.90')),
      ]),
    ]);
  });

  testWidgets('PriceChange', (tester) async {
    await expectPreview(tester, 'components/PriceChange', [
      previewRow([
        AuraPriceChange(abs: d('7.79'), pct: d('6.70'), period: 'today'),
        AuraPriceChange(abs: d('-10.50'), pct: d('-9.34')),
      ]),
      previewRow([
        AuraPriceChange(pct: d('3.10'), size: AuraChangeSize.sm),
        AuraPriceChange(pct: d('-2.40'), size: AuraChangeSize.sm),
        AuraPriceChange(pct: d('0'), size: AuraChangeSize.sm),
      ]),
      AuraPriceChange(
        abs: d('2486.20'),
        pct: d('24.86'),
        period: 'this season',
        size: AuraChangeSize.lg,
      ),
    ]);
  });

  testWidgets('Countdown', (tester) async {
    await expectPreview(tester, 'components/Countdown', [
      previewRow([
        const AuraCountdown(
          label: 'Ruling in',
          time: Duration(minutes: 6, seconds: 42),
        ),
        const AuraCountdown(
          label: 'Quote expires',
          time: Duration(seconds: 9),
          warn: true,
        ),
        const AuraCountdown(
          label: 'Opens in',
          time: Duration(hours: 4, minutes: 18, seconds: 2),
        ),
      ]),
    ]);
  });

  testWidgets('ImpactDisc', (tester) async {
    await expectPreview(tester, 'components/ImpactDisc', [
      previewRow(const [
        AuraImpactDisc(delta: -18, label: 'Loss'),
        AuraImpactDisc(delta: 10, label: 'Gain'),
        AuraImpactDisc(delta: 0, label: 'Lore'),
      ]),
    ]);
  });

  testWidgets('Avatar', (tester) async {
    await expectPreview(tester, 'components/Avatar', [
      previewRow(const [
        AuraAvatar('A'),
        AuraAvatar('J'),
        AuraAvatar('N'),
        AuraAvatar('M', size: 52),
      ]),
    ]);
  });

  testWidgets('Tag', (tester) async {
    await expectPreview(tester, 'components/Tag', [
      previewRow(const [
        AuraTag('Holding'),
        AuraTag('You'),
        AuraTag('Rumor'),
        AuraTag('SEC', tone: AuraTagTone.down),
        AuraTag('Halted', tone: AuraTagTone.warn),
      ]),
    ]);
  });

  testWidgets('StatusChip', (tester) async {
    await expectPreview(tester, 'components/StatusChip', [
      previewRow(const [
        AuraStatusChip(AuraStatus.open),
        AuraStatusChip(AuraStatus.pre),
        AuraStatusChip(AuraStatus.after),
        AuraStatusChip(AuraStatus.halted),
        AuraStatusChip(AuraStatus.delayed),
      ]),
      previewRow(const [
        AuraStatusChip(AuraStatus.rumor),
        AuraStatusChip(AuraStatus.ruled),
        AuraStatusChip(AuraStatus.voided),
        AuraStatusChip(AuraStatus.sending),
        AuraStatusChip(AuraStatus.filled),
        AuraStatusChip(AuraStatus.resting),
      ]),
      previewRow(const [
        AuraStatusChip(AuraStatus.liquidated),
        AuraStatusChip(AuraStatus.sec),
        AuraStatusChip(AuraStatus.beat),
        AuraStatusChip(AuraStatus.miss),
      ]),
      const AuraStatusChip(
        AuraStatus.closed,
        label: 'Closed · opens 7:00 am',
        glass: true,
      ),
    ]);
  });

  testWidgets('IconButton', (tester) async {
    await expectPreview(tester, 'components/IconButton', [
      previewRow([
        AuraIconButton(icon: AuraIcons.back, label: 'Back', onPressed: () {}),
        AuraIconButton(icon: AuraIcons.close, label: 'Close', onPressed: () {}),
        AuraIconButton(icon: AuraIcons.alarm, label: 'Alerts', onPressed: () {}),
        AuraIconButton(
          icon: AuraIcons.star,
          label: 'Remove from watchlist',
          filled: true,
          onPressed: () {},
        ),
        AuraIconButton(
          icon: AuraIcons.bell,
          label: 'Notifications, 3 unread',
          badge: true,
          onPressed: () {},
        ),
        AuraIconButton(
          icon: AuraIcons.eyeOff,
          label: 'Hide balance',
          small: true,
          onPressed: () {},
        ),
      ]),
    ]);
  });
}
