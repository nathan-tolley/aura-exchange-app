import 'package:aura_exchange/format/time.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/timezone.dart' as tz;

/// Exchange-local and relative time (API-CONTRACT.md → Time, DESIGN.md →
/// Numbers). The exchange is in Sydney; the drawn screens' "9:41 pm" is
/// 10:41 UTC on Saturday 24 October 2026 (AEDT, UTC+11).
void main() {
  final sydney = exchangeZone('Australia/Sydney');
  DateTime utc(String s) => DateTime.parse('${s}Z');
  final now = utc('2026-10-24T10:41:00');

  group('clock', () {
    test('lowercase am/pm on the exchange clock', () {
      expect(formatClock(utc('2026-10-24T10:41:00'), sydney), '9:41 pm');
      expect(formatClock(utc('2026-10-24T20:00:00'), sydney), '7:00 am');
      expect(formatClock(utc('2026-10-25T01:05:00'), sydney), '12:05 pm');
      expect(formatClock(utc('2026-10-24T13:00:00'), sydney), '12:00 am');
    });

    test('follows daylight saving', () {
      expect(formatClock(utc('2026-06-01T00:00:00'), sydney), '10:00 am');
    });

    test('an unknown timezone falls back to UTC', () {
      final zone = exchangeZone('Mars/Olympus_Mons');
      expect(zone, tz.UTC);
      expect(formatClock(utc('2026-10-24T10:41:00'), zone), '10:41 am');
    });
  });

  group('moment', () {
    test('the time alone within 12 hours', () {
      // W09: "Closed until 7:00 am", the next morning.
      expect(
        formatMoment(utc('2026-10-24T20:00:00'), sydney, now: now),
        '7:00 am',
      );
      // W11: "as of 9:41 pm".
      expect(
        formatMoment(
          utc('2026-10-24T10:41:00'),
          sydney,
          now: utc('2026-10-24T11:20:00'),
        ),
        '9:41 pm',
      );
    });

    test('the weekday within 6 days, then the date', () {
      expect(
        formatMoment(utc('2026-10-26T20:00:00'), sydney, now: now),
        'Tue 7:00 am',
      );
      expect(
        formatMoment(utc('2026-10-21T10:41:00'), sydney, now: now),
        'Wed 9:41 pm',
      );
      expect(
        formatMoment(utc('2026-11-04T20:00:00'), sydney, now: now),
        '5 Nov, 7:00 am',
      );
    });
  });

  group('relative', () {
    test('relative under an hour, then the moment', () {
      expect(
        formatWhen(now.subtract(const Duration(seconds: 30)), sydney, now: now),
        'just now',
      );
      expect(
        formatWhen(now.subtract(const Duration(minutes: 4)), sydney, now: now),
        '4 min ago',
      );
      expect(
        formatWhen(now.add(const Duration(minutes: 6)), sydney, now: now),
        'in 6 min',
      );
      expect(
        formatWhen(now.subtract(const Duration(hours: 2)), sydney, now: now),
        '7:41 pm',
      );
    });

    test('ago at any distance', () {
      expect(
        formatAgo(now.subtract(const Duration(seconds: 5)), sydney, now: now),
        'just now',
      );
      expect(
        formatAgo(now.subtract(const Duration(minutes: 59)), sydney, now: now),
        '59 min ago',
      );
      // W12: "Invited 2 h ago".
      expect(
        formatAgo(now.subtract(const Duration(hours: 2)), sydney, now: now),
        '2 h ago',
      );
      expect(
        formatAgo(now.subtract(const Duration(days: 3)), sydney, now: now),
        '3 d ago',
      );
      expect(formatAgo(utc('2026-10-01T02:00:00'), sydney, now: now), '1 Oct');
    });
  });

  group('day', () {
    test('from the exchange calendar, not UTC', () {
      final lateSaturday = utc('2026-10-24T12:30:00'); // 11:30 pm Sat
      expect(
        formatDay(utc('2026-10-24T12:45:00'), sydney, now: lateSaturday),
        'today',
      );
      // Still the 24th in UTC, but already Sunday in Sydney.
      expect(
        formatDay(utc('2026-10-24T13:30:00'), sydney, now: lateSaturday),
        'tomorrow',
      );
      expect(
        formatDay(utc('2026-10-23T10:00:00'), sydney, now: lateSaturday),
        'yesterday',
      );
      expect(
        formatDay(utc('2026-10-25T22:00:00'), sydney, now: lateSaturday),
        'Monday',
      );
      expect(
        formatDay(utc('2026-11-04T22:00:00'), sydney, now: lateSaturday),
        '5 Nov',
      );
    });
  });
}
