import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';
import 'package:timezone/timezone.dart' as tz;

import '../api/errors.dart';
import '../api/generated/models/error_code.dart';
import '../api/generated/models/side.dart';
import '../format/change.dart';
import '../format/money.dart';
import '../format/ticker.dart';
import '../format/time.dart';

// Every user-facing string the app writes itself (DESIGN.md → Voice): plain,
// exact, second person, a verb on every button, no exclamation marks or
// emoji. Analyst text comes from the server and is never written here.

// ---------------------------------------------------------------------------
// Errors
// ---------------------------------------------------------------------------

/// What the app says about one error. The server's `message` is never shown;
/// copy is built from `code` and `params` (API-CONTRACT.md → One error shape).
/// Screens choose how to show it: a banner (W05, W06), a full screen (W13),
/// a toast, or a line under a field.
@immutable
class ErrorCopy {
  const ErrorCopy({
    required this.title,
    this.body,
    this.action,
    this.reference,
  });

  /// What happened: "You're A$229.91 short".
  final String title;

  /// The detail and the fix.
  final String? body;

  /// The button that fixes it, a verb ("Buy 18", "Try again"). Null when the
  /// screen's own controls are the fix, or when there's nothing to do but wait.
  final String? action;

  /// Shown small, so a failure can be found in the server's log: `503 · 7F2K`.
  final String? reference;

  @override
  String toString() =>
      [title, ?body, if (action != null) '[$action]', ?reference].join(' / ');
}

/// What the copy needs that the error itself doesn't carry.
@immutable
class ErrorContext {
  const ErrorContext({this.side, this.zone, this.now});

  /// The trade being answered, for the verbs: "Buy 18", "Cover 12".
  final Side? side;

  /// The exchange's timezone, for times in params. UTC when not given.
  final tz.Location? zone;

  /// The current time, for "tomorrow's". `DateTime.now()` when not given.
  final DateTime? now;
}

/// The copy for [error]. Every code in the contract's `ErrorCode` has its
/// own (the switch is exhaustive, so a sync that adds a code doesn't compile
/// until it has copy); a code added after this build gets the generic
/// "Something went wrong" with the code as its reference.
ErrorCopy errorCopy(
  ApiError error, [
  ErrorContext context = const ErrorContext(),
]) {
  if (error.isLocal) return _localCopy(error);
  final p = _Params(error.params, context);
  final verb = _verb(context.side);

  return switch (error.errorCode) {
    ErrorCode.validation => _validationCopy(error.params['field']),
    ErrorCode.authExpired => const ErrorCopy(
      title: 'Sign in again',
      body: 'Your session ended. Your cash and positions are as you left them.',
      action: 'Sign in',
    ),
    ErrorCode.loginCodeInvalid => switch (p.integer('attemptsLeft')) {
      0 => const ErrorCopy(
        title: "That code isn't right",
        body: 'That was the last try. Send yourself a new code.',
        action: 'Send a new code',
      ),
      final int left => ErrorCopy(
        title: "That code isn't right",
        body: 'You have $left more ${_plural(left, 'try', 'tries')}.',
      ),
      null => const ErrorCopy(
        title: "That code isn't right",
        body: 'Check the latest email and try again.',
      ),
    },
    ErrorCode.loginCodeExpired => const ErrorCopy(
      title: 'That code has expired',
      body: 'Send yourself a new one and use the latest email.',
      action: 'Send a new code',
    ),
    ErrorCode.forbidden => const ErrorCopy(
      title: "You can't do that",
      body: "It needs permissions you don't have on this exchange.",
    ),
    ErrorCode.notAMember => const ErrorCopy(
      title: "You're not on this exchange",
      body: 'Ask someone on it for an invite link.',
    ),
    ErrorCode.selfTrade => ErrorCopy(
      title: "You can't trade yourself",
      body: p.has('ticker') ? '${p.ticker('ticker')} is your own stock.' : null,
    ),
    ErrorCode.notFound => const ErrorCopy(
      title: "This isn't here anymore",
      body: 'It may have been removed. Go back and refresh.',
    ),
    ErrorCode.conflict => const ErrorCopy(
      title: 'This changed while you were looking',
      body: 'Refresh to see the latest.',
      action: 'Refresh',
    ),
    // W06. The requote sheet is the fix, so there's no button here.
    ErrorCode.quoteStale => _quoteStaleCopy(p),
    ErrorCode.idempotencyMismatch => const ErrorCopy(
      title: "That didn't go through",
      body: 'Nothing changed. Start it again.',
    ),
    ErrorCode.idempotencyInProgress => const ErrorCopy(
      title: 'Still going through',
      body:
          "Your last request hasn't finished. Trying again won't do it twice.",
      action: 'Try again',
    ),
    ErrorCode.inviteExpired => const ErrorCopy(
      title: 'This invite has expired',
      body: 'Ask whoever sent it for a new link.',
    ),
    ErrorCode.exchangeFull => ErrorCopy(
      title: 'This exchange is full',
      body: switch (p.integer('maxMembers')) {
        final int max =>
          'It has $max people, the most an exchange can hold. '
              'You can start your own instead.',
        null => 'You can start your own instead.',
      },
      action: 'Create an exchange',
    ),
    ErrorCode.tickerTaken => ErrorCopy(
      title: p.has('ticker')
          ? '${p.ticker('ticker')} is taken'
          : 'That ticker is taken',
      body: 'Pick another one.',
    ),
    // W12: "The market opens at 3 listings."
    ErrorCode.tradingNotOpen => ErrorCopy(
      title: "The market isn't open yet",
      body: switch ((
        p.integer('listedCount'),
        p.integer('minListingsToOpen'),
      )) {
        (final int listed, final int needed) =>
          '$listed of $needed listed. The market opens at $needed listings.',
        (_, final int needed) => 'The market opens at $needed listings.',
        _ => 'It opens once enough friends are listed.',
      },
      action: 'Invite someone',
    ),
    // W10: "Trading resumes when the vote closes."
    ErrorCode.listingHalted => ErrorCopy(
      title: 'Trading is halted',
      body: p.has('resumesAt')
          ? 'Trading resumes at ${p.moment('resumesAt')}.'
          : 'Trading resumes when the vote closes.',
    ),
    // W09: "Closed until 7:00 am".
    ErrorCode.marketClosed => ErrorCopy(
      title: p.has('opensAt')
          ? 'Closed until ${p.moment('opensAt')}'
          : 'The market is closed',
      body: switch (p.integer('queuedEvents')) {
        null || 0 => 'Orders you set now fill at the opening price.',
        1 =>
          'A ruling lands at the open, so prices will gap. '
              'Orders you set now fill at the opening price.',
        final int n =>
          '$n rulings land at the open, so prices will gap. '
              'Orders you set now fill at the opening price.',
      },
      action: 'Set an order',
    ),
    ErrorCode.orderTypeNotAllowed => ErrorCopy(
      title: switch (error.params['marketState']) {
        'PRE' => 'Only limit orders before the open',
        'AFTER' => 'Only limit orders after the close',
        _ => "That order type isn't available right now",
      },
      body: 'Set a limit price, and the order fills when the price gets there.',
      action: 'Set a limit',
    ),
    // W05.
    ErrorCode.insufficientCash => _insufficientCashCopy(p, verb),
    ErrorCode.insufficientShares => _insufficientSharesCopy(p, context.side),
    ErrorCode.orderTooLarge => ErrorCopy(
      title: 'That order is too big',
      body: p.positive('maxQuantity')
          ? 'The most you can ${verb.toLowerCase()} in one order is '
                '${p.quantity('maxQuantity')}.'
          : "That's more than one order can move.",
      action: p.positive('maxQuantity')
          ? '$verb ${p.quantity('maxQuantity')}'
          : null,
    ),
    ErrorCode.shortCap => ErrorCopy(
      title: "That's over the short limit",
      body: [
        if (p.has('capPct'))
          'Your shorts are capped at ${p.percent('capPct')} of your equity.',
        p.positive('maxQuantity')
            ? 'You can short ${p.quantity('maxQuantity')} more.'
            : "You're at the cap on this stock.",
      ].join(' '),
      action: p.positive('maxQuantity')
          ? 'Short ${p.quantity('maxQuantity')}'
          : null,
    ),
    ErrorCode.oppositePosition => switch (context.side) {
      Side.buy => const ErrorCopy(
        title: 'Close your short first',
        body:
            "You can't be long and short the same stock. "
            'Cover your short, then buy.',
        action: 'Cover',
      ),
      Side.short => const ErrorCopy(
        title: 'Sell your shares first',
        body:
            "You can't be long and short the same stock. "
            'Sell your shares, then short.',
        action: 'Sell',
      ),
      _ => const ErrorCopy(
        title: 'Close your other position first',
        body: "You can't be long and short the same stock.",
      ),
    },
    // W04. The screen's slider and "Keep going" are the choices.
    ErrorCode.equityTooLow => ErrorCopy(
      title: p.has('minimum')
          ? "You're under ${p.money('minimum')}"
          : "You're too low to trade",
      body:
          "That's not enough to open a position. "
          'Keep what you have, or start over with Chapter 7.',
    ),
    ErrorCode.dailyFilingLimit => ErrorCopy(
      title: switch (p.integer('limit')) {
        final int n => "You've filed $n ${_plural(n, 'event', 'events')} today",
        null => "You've filed today's events",
      },
      body: p.has('resetsAt')
          ? "That's the daily limit. You can file again at "
                '${p.moment('resetsAt')}.'
          : "That's the daily limit. You can file again tomorrow.",
    ),
    ErrorCode.unsendExpired => const ErrorCopy(
      title: 'Too late to unsend',
      body: "The unsend window has closed, so it's with the Analyst now.",
    ),
    ErrorCode.updateRequired => ErrorCopy(
      title: 'Update to keep trading',
      body: [
        'This build is older than the exchange accepts.',
        if (p.has('minBuild'))
          'Install build ${error.params['minBuild']} or newer.',
        'Your cash and positions are safe.',
      ].join(' '),
      action: 'Update',
    ),
    ErrorCode.rateLimited => ErrorCopy(
      title: 'Give it a second',
      body: switch (p.integer('retryAfterSeconds')) {
        final int s when s > 0 =>
          'Try again in $s ${_plural(s, 'second', 'seconds')}.',
        _ => 'Try again in a moment.',
      },
    ),
    // W13.
    ErrorCode.server => _exchangeDown(error),
    ErrorCode.maintenance => ErrorCopy(
      title: 'The exchange is down for maintenance',
      body: [
        if (p.has('until')) "It's back at ${p.moment('until')}.",
        'Your cash and positions are safe, and nothing trades while '
            "it's down.",
      ].join(' '),
      action: 'Try again',
      reference: _reference(error),
    ),
    ErrorCode.$unknown => _somethingWentWrong(error),
  };
}

/// The label for an action that has no copy of its own, e.g. a button on the
/// generic error screen.
String? actionLabel(ApiAction action) => switch (action) {
  ApiAction.retry => 'Try again',
  ApiAction.requote => 'Get a new price',
  ApiAction.reduceQuantity => 'Change the amount',
  ApiAction.sellSomething => 'Sell something',
  ApiAction.signIn => 'Sign in',
  ApiAction.updateApp => 'Update',
  ApiAction.contactAdmin => 'Contact the admin',
  ApiAction.wait || ApiAction.none || ApiAction.unknown => null,
};

ErrorCopy _localCopy(ApiError error) => switch (error.code) {
  // W11.
  ApiError.appOffline => const ErrorCopy(
    title: "You're offline",
    body: "Trading and filing wait until you're back.",
    action: 'Retry',
  ),
  ApiError.appTimeout => const ErrorCopy(
    title: "The exchange isn't answering",
    body:
        "Check your connection and try again. Trying again won't do "
        'anything twice.',
    action: 'Try again',
  ),
  // A proxy's error page: the exchange is down even though it couldn't say so.
  _ when (error.status ?? 0) >= 500 => _exchangeDown(error),
  _ => _somethingWentWrong(error),
};

/// W13: "The exchange is down", for `SERVER` and any 5xx without the shape.
ErrorCopy _exchangeDown(ApiError error) => ErrorCopy(
  title: 'The exchange is down',
  body:
      'Something broke on our side. Your cash and positions are safe, and '
      'nothing traded while it was down.',
  action: 'Try again',
  reference: _reference(error),
);

/// The contract's fallback: "Something went wrong · reference".
ErrorCopy _somethingWentWrong(ApiError error) => ErrorCopy(
  title: 'Something went wrong',
  body: error.retryable ? 'Try again in a moment.' : null,
  action: actionLabel(error.action),
  reference: [
    error.code,
    ?error.status?.toString(),
    ?error.reference,
  ].join(' · '),
);

/// `503 · 7F2K`: the status and the server's reference, whichever exist.
String? _reference(ApiError error) {
  final parts = [?error.status?.toString(), ?error.reference];
  return parts.isEmpty ? null : parts.join(' · ');
}

ErrorCopy _validationCopy(String? field) => switch (field) {
  'email' => const ErrorCopy(
    title: "That email address doesn't look right",
    body: 'Check it and try again.',
  ),
  'code' => const ErrorCopy(
    title: 'Enter the 6-digit code',
    body: "It's in the email we just sent.",
  ),
  'ticker' => const ErrorCopy(
    title: "That ticker won't work",
    body: 'Use 3 to 5 letters.',
  ),
  'quantity' => const ErrorCopy(
    title: "That amount won't work",
    body: 'Use a number above zero, with up to 4 decimals.',
  ),
  _ => const ErrorCopy(
    title: 'Check what you entered',
    body: "Something in it isn't valid yet.",
  ),
};

/// W06: "The price moved while you were deciding / Someone bought first.
/// A$124.10 is now A$125.36, up 1.02%."
ErrorCopy _quoteStaleCopy(_Params p) {
  final change = p.decimal('changePct');
  final up = (change ?? Decimal.zero) >= Decimal.zero;
  return ErrorCopy(
    title: 'The price moved while you were deciding',
    body: [
      up ? 'Someone bought first.' : 'Someone sold first.',
      if (p.has('oldPrice') && p.has('newPrice'))
        '${p.money('oldPrice')} is now ${p.money('newPrice')}'
            '${change == null ? '' : ', ${up ? 'up' : 'down'} '
                      '${formatPercent(change.abs(), signed: false)}'}.',
    ].join(' '),
  );
}

/// W05: "You're A$229.91 short / You have A$2,264.50. Buy 18 instead, sell
/// something, or wait for tomorrow's stimulus check. [Buy 18]"
ErrorCopy _insufficientCashCopy(_Params p, String verb) {
  final canReduce = p.positive('maxQuantity');
  final stimulus = p.stimulus();
  return ErrorCopy(
    title: p.has('shortBy')
        ? "You're ${p.money('shortBy')} short"
        : "You don't have enough cash",
    body: [
      if (p.has('available')) 'You have ${p.money('available')}.',
      canReduce
          ? '$verb ${p.quantity('maxQuantity')} instead, sell something, '
                'or wait for $stimulus.'
          : 'Sell something, or wait for $stimulus.',
    ].join(' '),
    action: canReduce ? '$verb ${p.quantity('maxQuantity')}' : null,
  );
}

ErrorCopy _insufficientSharesCopy(_Params p, Side? side) {
  final covering = side == Side.cover;
  final verb = covering ? 'Cover' : 'Sell';
  if (!p.positive('available')) {
    return ErrorCopy(
      title: covering ? 'You have no short to cover' : "You don't hold any",
    );
  }
  final n = p.quantity('available');
  final shares = p.integer('available') == 1 ? 'share' : 'shares';
  return ErrorCopy(
    title: covering
        ? "You're only short $n $shares"
        : 'You only have $n $shares',
    body: '$verb all $n instead.',
    action: '$verb $n',
  );
}

String _verb(Side? side) => switch (side) {
  Side.sell => 'Sell',
  Side.short => 'Short',
  Side.cover => 'Cover',
  _ => 'Buy',
};

String _plural(int n, String one, String many) => n == 1 ? one : many;

/// Reads params, which are strings by contract, and formats them the app's
/// way. A param that is missing or malformed reads as absent, so the copy
/// drops that clause instead of showing "null".
class _Params {
  _Params(this._raw, this._context);

  final Map<String, String> _raw;
  final ErrorContext _context;

  tz.Location get _zone => _context.zone ?? tz.UTC;
  DateTime get _now => _context.now ?? DateTime.now();

  bool has(String key) => switch (key) {
    _ when _raw[key] == null || _raw[key]!.isEmpty => false,
    'opensAt' || 'resumesAt' || 'resetsAt' || 'until' => time(key) != null,
    'ticker' => true,
    _ => decimal(key) != null,
  };

  Decimal? decimal(String key) => Decimal.tryParse(_raw[key] ?? '');

  int? integer(String key) {
    final value = decimal(key);
    return value != null && value.isInteger ? value.toBigInt().toInt() : null;
  }

  bool positive(String key) => (decimal(key) ?? Decimal.zero) > Decimal.zero;

  DateTime? time(String key) => DateTime.tryParse(_raw[key] ?? '');

  String money(String key) => formatMoney(decimal(key)!);
  String quantity(String key) => formatQuantity(decimal(key)!);
  String percent(String key) =>
      formatPercent(decimal(key)!, signed: false).replaceFirst('.00%', '%');
  String ticker(String key) => formatTicker(_raw[key]!);
  String moment(String key) => formatMoment(time(key)!, _zone, now: _now);

  /// "tomorrow's stimulus check", from `nextStimulusAt` when the server sends
  /// it (contract request #2); otherwise "the next stimulus check". The app
  /// doesn't know the schedule, which is a game rule.
  String stimulus() {
    final at = time('nextStimulusAt');
    if (at == null || at.isBefore(_now)) return 'the next stimulus check';
    if (at.difference(_now) >= const Duration(days: 6)) {
      return 'the next stimulus check';
    }
    return "${formatDay(at, _zone, now: _now)}'s stimulus check";
  }
}

// ---------------------------------------------------------------------------
// Freshness (W11, DESIGN.md → Numbers)
// ---------------------------------------------------------------------------

/// "as of 9:41 pm", next to a price that isn't live.
String asOfLabel(DateTime asOf, tz.Location zone, {required DateTime now}) =>
    'as of ${formatMoment(asOf, zone, now: now)}';

/// "Delayed · as of 9:41 pm": a price older than 60 s with the socket up.
String delayedLabel(DateTime asOf, tz.Location zone, {required DateTime now}) =>
    'Delayed · ${asOfLabel(asOf, zone, now: now)}';

/// The offline banner (W11).
ErrorCopy offlineBanner(
  DateTime asOf,
  tz.Location zone, {
  required DateTime now,
}) => ErrorCopy(
  title: "You're offline",
  body:
      'Prices are from ${formatMoment(asOf, zone, now: now)}. '
      "Trading and filing wait until you're back.",
  action: 'Retry',
);

// ---------------------------------------------------------------------------
// Home (W09, W11, W12)
// ---------------------------------------------------------------------------

const fileAnEvent = 'File an event';
const trade = 'Trade';

/// Trading while the market is closed means setting orders (W09).
const setAnOrder = 'Set an order';
const watchlistTitle = 'Watchlist';
const searchFriends = 'Search friends or tickers…';

/// IPO day (W12): nobody else is listed yet.
const nobodyToSearch = 'Nobody to search yet';

/// The tag after a name in a row: a ruling waiting for the open, then your
/// own position.
const tagRuled = 'Ruled';
const tagHolding = 'Holding';
const tagShort = 'Short';

/// "Net worth · Season 1", "Net worth · at the close",
/// "Net worth · as of 9:41 pm".
String netWorthLabel({
  required bool closed,
  required bool delayed,
  required int season,
  required DateTime asOf,
  required tz.Location zone,
  required DateTime now,
}) {
  if (delayed) return 'Net worth · ${asOfLabel(asOf, zone, now: now)}';
  if (closed) return 'Net worth · at the close';
  return 'Net worth · Season $season';
}

/// "As of 9:41 pm", next to a list whose prices aren't live (W11).
String asOfStatus(DateTime asOf, tz.Location zone, {required DateTime now}) =>
    'As of ${formatMoment(asOf, zone, now: now)}';

/// The closed banner (W09): when it opens, what lands then, and what orders
/// do meanwhile. [queued] are the tickers with a ruling waiting for the open.
ErrorCopy closedBanner({
  required DateTime? opensAt,
  required List<String> queued,
  required tz.Location zone,
  required DateTime now,
}) {
  const orders = 'Orders you set now fill at the opening price.';
  return ErrorCopy(
    title: opensAt == null
        ? 'The market is closed'
        : 'Closed until ${formatMoment(opensAt, zone, now: now)}',
    body: switch (queued) {
      [] => orders,
      [final one] =>
        'A ruling on $one lands at the open, so it will gap. $orders',
      [...final some, final last] =>
        'Rulings on ${some.join(', ')} and $last land at the open, so they '
            'will gap. $orders',
    },
  );
}

/// IPO day (W12).
String ipoHeroNote(int minListings) =>
    'Your starting cash. The market opens at $minListings listings.';
String listedOf(int listed, int minListings) =>
    '$listed of $minListings listed';
const cantTradeYourself = "You can't trade yourself";
const memberPickingTicker = 'Joined · picking a ticker';
String invitedNotOpened(String ago) => "Invited $ago · hasn't opened it";
const almost = 'Almost';
const nudge = 'Nudge';
const inviteSomeone = 'Invite someone';
const inviteSomeoneNote = 'Anyone with the link can list';
const firstOnTheTape = 'First thing on the tape';
const analystAtTheOpen = 'The Analyst · when the market opens';
