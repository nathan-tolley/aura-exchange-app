import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Times are shown in the exchange's timezone, never the phone's
/// (API-CONTRACT.md → Time), with lowercase am/pm (DESIGN.md → Numbers).

bool _loaded = false;

/// The exchange's IANA timezone (`Australia/Sydney`). Loads the timezone
/// database on first use. An unknown name falls back to UTC rather than
/// failing the screen.
tz.Location exchangeZone(String iana) {
  if (!_loaded) {
    tz_data.initializeTimeZones();
    _loaded = true;
  }
  try {
    return tz.getLocation(iana);
  } on tz.LocationNotFoundException {
    return tz.UTC;
  }
}

/// [at] on the exchange's clock.
tz.TZDateTime exchangeTime(DateTime at, tz.Location zone) =>
    tz.TZDateTime.from(at, zone);

/// `9:41 pm`, `7:00 am`, `12:05 pm`.
String formatClock(DateTime at, tz.Location zone) {
  final t = exchangeTime(at, zone);
  final hour = t.hour % 12 == 0 ? 12 : t.hour % 12;
  final minute = t.minute.toString().padLeft(2, '0');
  return '$hour:$minute ${t.hour < 12 ? 'am' : 'pm'}';
}

const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _weekdayNames = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];
const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// A moment on the exchange's clock, as short as it can be without being
/// ambiguous: the time alone within 12 hours either way (`as of 9:41 pm`,
/// `Closed until 7:00 am`), the weekday within 6 days (`Mon 7:00 am`), and
/// the date beyond that (`24 Oct, 7:00 am`).
String formatMoment(DateTime at, tz.Location zone, {required DateTime now}) {
  final clock = formatClock(at, zone);
  final distance = at.difference(now).abs();
  if (distance < const Duration(hours: 12)) return clock;
  final t = exchangeTime(at, zone);
  if (distance < const Duration(days: 6)) {
    return '${_weekdays[t.weekday - 1]} $clock';
  }
  return '${t.day} ${_months[t.month - 1]}, $clock';
}

/// The contract's rule for timestamps: relative under an hour (`just now`,
/// `4 min ago`, `in 6 min`), then [formatMoment].
String formatWhen(DateTime at, tz.Location zone, {required DateTime now}) {
  final delta = at.difference(now);
  final minutes = delta.abs().inMinutes;
  if (delta.abs() >= const Duration(hours: 1)) {
    return formatMoment(at, zone, now: now);
  }
  if (minutes < 1) return 'just now';
  return delta.isNegative ? '$minutes min ago' : 'in $minutes min';
}

/// How long ago, at any distance (`Invited 2 h ago`, W12): `just now`,
/// `4 min ago`, `2 h ago`, `3 d ago`, then the date (`24 Oct`).
String formatAgo(DateTime at, tz.Location zone, {required DateTime now}) {
  final ago = now.difference(at);
  if (ago < const Duration(minutes: 1)) return 'just now';
  if (ago < const Duration(hours: 1)) return '${ago.inMinutes} min ago';
  if (ago < const Duration(days: 1)) return '${ago.inHours} h ago';
  if (ago < const Duration(days: 7)) return '${ago.inDays} d ago';
  final t = exchangeTime(at, zone);
  return '${t.day} ${_months[t.month - 1]}';
}

/// The day [at] falls on, from the exchange's calendar: `today`, `tomorrow`,
/// `yesterday`, a weekday within the week (`Monday`), or the date (`24 Oct`).
/// For copy like "tomorrow's stimulus check".
String formatDay(DateTime at, tz.Location zone, {required DateTime now}) {
  final day = exchangeTime(at, zone);
  final today = exchangeTime(now, zone);
  final days = DateTime.utc(
    day.year,
    day.month,
    day.day,
  ).difference(DateTime.utc(today.year, today.month, today.day)).inDays;
  return switch (days) {
    0 => 'today',
    1 => 'tomorrow',
    -1 => 'yesterday',
    > 1 && < 7 => _weekdayNames[day.weekday - 1],
    _ => '${day.day} ${_months[day.month - 1]}',
  };
}

/// A local wall-clock time from the API (`MarketHours`: `"09:00"`, `"22:00"`)
/// as `9:00 am`, `10:00 pm`. Anything that isn't `HH:mm` is shown as sent.
String formatWallClock(String hhmm) {
  final match = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(hhmm);
  if (match == null) return hhmm;
  final h = int.parse(match[1]!);
  final hour = h % 12 == 0 ? 12 : h % 12;
  return '$hour:${match[2]} ${h < 12 || h == 24 ? 'am' : 'pm'}';
}

/// The place an IANA zone is named after: `Australia/Sydney` → `Sydney`,
/// `America/Los_Angeles` → `Los Angeles`.
String zoneCity(String iana) => iana.split('/').last.replaceAll('_', ' ');
