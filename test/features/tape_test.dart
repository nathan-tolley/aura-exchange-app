import 'package:aura_exchange/api/generated/export.dart' hide Freshness;
import 'package:aura_exchange/features/tape/tape_screen.dart';
import 'package:aura_exchange/features/tape/tape_view.dart';
import 'package:aura_exchange/format/time.dart';
import 'package:aura_exchange/l10n/strings.dart';
import 'package:flutter_test/flutter_test.dart';

/// The Tape tab and the inbox (SCREENS.md #18, #19).
void main() {
  final zone = exchangeZone('Australia/Sydney');
  final now = DateTime.utc(2026, 10, 24, 10, 41); // 9:41 pm in Sydney

  Notification note(String id, {String? listing, bool read = false}) =>
      Notification.fromJson({
        'id': id,
        'type': 'HOLDING_MOVED',
        'at': now.toIso8601String(),
        'readAt': read ? now.toIso8601String() : null,
        'title': 'Title $id',
        'body': '',
        'listingId': listing,
        'deepLink': 'aura://events/$id',
      });

  test('the inbox groups by stock, in the order they arrived', () {
    final m = inboxModel(
      [note('1', listing: 'j'), note('2', listing: 'a'), note('3')],
      tickers: {'j': r'$JAKE', 'a': r'$ANNA'},
      quiet: null,
      zone: zone,
      now: now,
    );
    expect(m.groups.map((g) => g.$1), [r'$JAKE', r'$ANNA', theExchange]);
    expect(m.groups.first.$2.single.unread, isTrue);
    expect(m.banner, isNull);
  });

  test('quiet hours that run past midnight', () {
    InboxModel at(String start, String end) => inboxModel(
      const [],
      tickers: const {},
      quiet: QuietHours.fromJson({'start': start, 'end': end}),
      zone: zone,
      now: now,
    );
    expect(at('21:00', '07:00').banner?.title, quietHoursUntil('7:00 am'));
    expect(at('22:00', '07:00').banner, isNull);
    expect(at('09:00', '22:00').banner, isNotNull);
  });

  test('tape items newer than your last look are unread', () {
    TapeItem item(String id, int minutesAgo) => TapeItem.fromJson({
      'id': id,
      'type': 'RULING',
      'at': now.subtract(Duration(minutes: minutesAgo)).toIso8601String(),
      'listing': null,
      'headline': 'h',
      'body': null,
      'impact': null,
      'priceMovePct': '-1.00',
      'eventId': 'e$id',
      'haltId': null,
    });
    final rows = tapeRows(
      [item('1', 5), item('2', 90)],
      seen: now.subtract(const Duration(minutes: 30)),
      zone: zone,
      now: now,
    );
    expect(rows.map((r) => r.unread), [true, false]);
    expect(rows.first.link, '/events/e1');
    expect(rows.first.source, 'Ruling · 5 min ago');
  });

  test('aura:// links become routes', () {
    expect(routeFor('aura://events/123'), '/events/123');
    expect(routeFor('aura://stock/9?tab=tape'), '/stock/9?tab=tape');
    expect(routeFor('/home'), '/home');
  });
}
