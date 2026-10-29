import 'package:flutter/widgets.dart' hide Notification;

import '../../../api/generated/export.dart' hide Freshness;
import '../../../features/tape/tape_view.dart';
import '../../../format/time.dart';

// The Tape tab and the notifications inbox (SCREENS.md #18, #19), at 9:41
// pm in Sydney.

final _sydney = exchangeZone('Australia/Sydney');
final _now = DateTime.utc(2026, 10, 24, 10, 41);

Map<String, Object?> _ref(String ticker, String name, String n) => {
  'id': '11111111-0000-4000-8000-00000000000$n',
  'ticker': ticker,
  'displayName': name,
  'avatarUrl': null,
};

TapeItem _item(
  String n,
  String type,
  String headline, {
  required int minutesAgo,
  Map<String, Object?>? listing,
  String? move,
}) => TapeItem.fromJson({
  'id': '55555555-0000-4000-8000-00000000000$n',
  'type': type,
  'at': _now.subtract(Duration(minutes: minutesAgo)).toIso8601String(),
  'listing': listing,
  'headline': headline,
  'body': null,
  'impact': null,
  'priceMovePct': move,
  'eventId': '44444444-0000-4000-8000-00000000000$n',
  'haltId': null,
});

final _tape = [
  _item(
    '1',
    'RUMOR',
    'Unconfirmed: reports of a late-night karaoke incident involving Mia.',
    minutesAgo: 3,
    listing: _ref(r'$MIA', 'Mia', '5'),
  ),
  _item(
    '2',
    'RULING',
    'Jake indicated sharply lower after overnight “who is this” incident',
    minutesAgo: 52,
    listing: _ref(r'$JAKE', 'Jake', '2'),
    move: '-12.19',
  ),
  _item(
    '3',
    'WHALE',
    'A single buyer took 400 shares of Anna in one order. Analysts '
        'decline to speculate, then speculate.',
    minutesAgo: 95,
    listing: _ref(r'$ANNA', 'Anna', '1'),
    move: '3.40',
  ),
  _item(
    '4',
    'BELL',
    'The closing bell rings on a session best described as eventful.',
    minutesAgo: 300,
  ),
];

Widget _tapeView(
  List<TapeItem>? items, {
  String filter = 'All',
  DateTime? seen,
}) => TapeView(
  rows: items == null
      ? null
      : tapeRows(items, seen: seen, zone: _sydney, now: _now),
  filter: filter,
  onFilter: (_) {},
  onRow: (_) {},
  onFile: _noop,
  onTab: (_) {},
);

/// S18a: everything, with what's new since you last looked dotted.
Widget tapeAll() =>
    _tapeView(_tape, seen: _now.subtract(const Duration(minutes: 60)));

/// S18b: rulings only.
Widget tapeFiltered() => _tapeView([_tape[1]], filter: 'Rulings');

/// S18c: nothing on the tape yet.
Widget tapeEmpty() => _tapeView(const []);

/// S18d: a filter with nothing in it.
Widget tapeFilteredEmpty() => _tapeView(const [], filter: 'Halts');

/// S18e: loading.
Widget tapeLoading() => _tapeView(null);

/// S18f: the exchange doesn't serve the tape yet.
Widget tapeNotLive() =>
    const TapeView(rows: null, filter: 'All', notLive: true, onTab: _noTab);

void _noTab(Object _) {}

Notification _note(
  String n,
  String type,
  String title, {
  required int minutesAgo,
  String? listing,
  bool read = false,
}) => Notification.fromJson({
  'id': '88888888-0000-4000-8000-00000000000$n',
  'type': type,
  'at': _now.subtract(Duration(minutes: minutesAgo)).toIso8601String(),
  'readAt': read ? _now.toIso8601String() : null,
  'title': title,
  'body': '',
  'listingId': listing,
  'deepLink': 'aura://events/44444444-0000-4000-8000-00000000000$n',
});

const _jake = '11111111-0000-4000-8000-000000000002';
const _anna = '11111111-0000-4000-8000-000000000001';

final _inbox = [
  _note(
    '1',
    'MARGIN_WARNING',
    r'Your $JAKE short is close to liquidation',
    minutesAgo: 6,
    listing: _jake,
  ),
  _note(
    '2',
    'HOLDING_MOVED',
    r'$ANNA is up 6.70% today. You hold 12.',
    minutesAgo: 40,
    listing: _anna,
  ),
  _note(
    '3',
    'ORDER_FILLED',
    r'Your order filled: 12 $ANNA at A$118.00',
    minutesAgo: 180,
    listing: _anna,
    read: true,
  ),
  _note(
    '4',
    'BELL',
    'The closing bell: a session best described as eventful.',
    minutesAgo: 300,
    read: true,
  ),
];

const _tickers = {_jake: r'$JAKE', _anna: r'$ANNA'};

Widget _inboxView(List<Notification>? items, {QuietHours? quiet}) => InboxView(
  model: items == null
      ? null
      : inboxModel(
          items,
          tickers: _tickers,
          quiet: quiet,
          zone: _sydney,
          now: _now,
        ),
  onBack: _noop,
  onRow: (_) {},
);

/// S19a: grouped by stock, newest first, unread dotted.
Widget inboxGrouped() => _inboxView(_inbox);

/// S19b: quiet hours on.
Widget inboxQuiet() => _inboxView(
  _inbox,
  quiet: QuietHours.fromJson({'start': '21:00', 'end': '07:00'}),
);

/// S19c: nothing yet.
Widget inboxEmpty() => _inboxView(const []);

/// S19d: loading.
Widget inboxLoading() => _inboxView(null);

/// S19e: the exchange doesn't serve notifications yet.
Widget inboxNotLive() =>
    const InboxView(model: null, notLive: true, onBack: _noop);

void _noop() {}
