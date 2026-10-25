import 'package:timezone/timezone.dart' as tz;

import '../../api/errors.dart';
import '../../design/widgets/aura_receipt.dart';
import '../../format/time.dart';
import '../../l10n/strings.dart';
import 'exchange_down_view.dart';

/// The exchange-down screen (W13) for [error] (`SERVER`, `MAINTENANCE`, or a
/// 5xx without the error shape), with the last good update the app kept
/// (the freshness of the last payload it had).
ExchangeDownModel exchangeDownModel({
  required ApiError error,
  required DateTime lastGood,
  required tz.Location zone,
  required DateTime now,
}) {
  final copy = errorCopy(error, ErrorContext(zone: zone, now: now));
  return ExchangeDownModel(
    title: copy.title,
    body: copy.body ?? '',
    rows: [
      AuraReceiptRow(lastGoodUpdate, formatMoment(lastGood, zone, now: now)),
      const AuraReceiptRow(ordersAndRulingsQueued, keptForLater),
      const AuraReceiptRow(marketClock, paused),
    ],
    tapeLabel: onTheTapeOnceBack,
    tape: quoted(exchangeDownTape),
    retry: copy.action ?? 'Try again',
    footnote: exchangeDownFootnote(copy.reference),
  );
}
