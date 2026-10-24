/// A countdown's digits: `m:ss` under an hour (`6:42`, `0:09`), `h:mm:ss`
/// from an hour up (`4:18:02`). Negative durations show `0:00`; screens
/// replace a finished countdown with its result instead of leaving it at zero.
String formatCountdown(Duration remaining) {
  final total = remaining.isNegative ? 0 : remaining.inSeconds;
  final hours = total ~/ 3600;
  final minutes = (total % 3600) ~/ 60;
  final seconds = (total % 60).toString().padLeft(2, '0');
  return hours > 0
      ? '$hours:${minutes.toString().padLeft(2, '0')}:$seconds'
      : '$minutes:$seconds';
}
