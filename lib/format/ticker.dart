/// A ticker as the app shows it: `$` plus the uppercase name, `$ANNA`.
/// Accepts the API's `$ANNA` or a bare `anna`.
String formatTicker(String ticker) {
  final name = ticker.trim().replaceFirst(RegExp(r'^\$'), '').toUpperCase();
  return '\$$name';
}
