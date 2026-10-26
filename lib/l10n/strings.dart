import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';
import 'package:timezone/timezone.dart' as tz;

import '../api/errors.dart';
import '../api/generated/models/badge.dart';
import '../api/generated/models/error_code.dart';
import '../api/generated/models/event_status.dart';
import '../api/generated/models/tape_item_type.dart';
import '../api/generated/models/halt_reason.dart';
import '../api/generated/models/order_type.dart';
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
          : tradingResumesAfterVote,
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
    ErrorCode.equityTooLow => underMinimumCopy(p.decimal('minimum')),
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
// Sign in (SCREENS.md #1)
// ---------------------------------------------------------------------------

const signInTitle = 'Sign in to Aura Exchange';
const signInBody =
    "Enter your email and we'll send you a 6-digit code. There's no password.";
const emailLabel = 'Email';
const emailPlaceholder = 'you@example.com';
const sendCode = 'Send code';
const sendingCode = 'Sending…';
const enterYourEmail = 'Enter your email to get a code.';

/// Under the first button: what Aura Bucks are (PLAN.md → Consent and
/// safety), before anyone signs up.
const playMoneyNote = 'Aura Bucks are play money, never bought or cashed out.';
const checkYourEmail = 'Check your email';
String codeSentTo(String email) => 'We sent a 6-digit code to $email.';
String newCodeSentTo(String email) =>
    'We sent a new code to $email. Use the latest email.';
const sendNewCode = 'Send a new code';
const signIn = 'Sign in';
const checkingCode = 'Checking…';
const enterTheCode = 'Enter the 6 digits from the email.';
const sendNewCodeFirst = 'Send a new code first.';
const useDifferentEmail = 'Use a different email';

/// Signing in while offline: the W11 banner, worded for sign-in.
const signInOffline = ErrorCopy(
  title: "You're offline",
  body: 'Signing in needs a connection. Retry when you have one.',
  action: 'Retry',
);

/// A field note from an error's copy: "That code isn't right. You have 2
/// more tries."
String noteFrom(ErrorCopy copy) => ['${copy.title}.', ?copy.body].join(' ');

// ---------------------------------------------------------------------------
// Create an exchange (SCREENS.md #4)
// ---------------------------------------------------------------------------

const createTitle = 'Start an exchange';
const createBody =
    "An exchange is one friend group's market. Everyone in it can be "
    'listed, and nothing in it leaves it.';
const exchangeNameLabel = 'Name';
const exchangeNamePlaceholder = 'The Group Chat';
const exchangeNameHelp = 'Everyone in it sees this name.';
const exchangeNameLength = 'Use 2 to 40 characters.';
const continueLabel = 'Continue';
const nameItFirst = 'Name it to continue.';
const gotAnInvite = 'Got an invite? Open the link your friend sent.';
const whenItTradesTitle = 'When it trades';
const whenItTradesBody =
    'Every time on the exchange is on its clock, so everyone sees the same '
    'open and close.';
const timezoneLabel = 'Timezone';

/// "Australia/Sydney · 9:41 pm there".
String zoneSubtitle(String iana, String clock) => '$iana · $clock there';
const change = 'Change';
const selected = 'Selected';
const tradingHoursLabel = 'Trading hours';
const standardHours =
    'Pre-market, regular and after-hours sessions start at the standard '
    'times. The admin can change them later.';
const createExchange = 'Create exchange';
const creatingExchange = 'Creating…';
const youllBeAdmin = "You'll be its admin.";

/// Creating while offline: the W11 banner, worded for this step.
const createOffline = ErrorCopy(
  title: "You're offline",
  body: 'Creating an exchange needs a connection. Retry when you have one.',
  action: 'Retry',
);
const inviteTitle = 'Invite your friends';

/// The market opens at the server's `minListingsToOpen`.
String inviteBody(int minListings) =>
    'The market opens when $minListings people are listed. Anyone with this '
    'link can join and list.';
const inviteLinkLabel = 'Invite link';
const inviteCodeLabel = 'Code';
const inviteExpiresLabel = 'Expires';
const copyLink = 'Copy link';
const linkCopied = 'Link copied';
const makingTheLink = 'The link is still being made.';
const noLinkYet = 'No link yet. Retry above.';

/// Making a link while offline.
const inviteOffline = ErrorCopy(
  title: "You're offline",
  body: 'The invite link needs a connection. Retry when you have one.',
  action: 'Retry',
);
const waitingTitle = 'Waiting for friends';

/// "The Group Chat opens when 3 people are listed. 0 of 3 so far."
String waitingBody(String name, int listed, int minListings) =>
    '$name opens when $minListings people are listed. '
    '$listed of $minListings so far.';
const statMembers = 'Members';
const statListed = 'Listed';
const statOpens = 'Opens';
const statCloses = 'Closes';
const listYourself = 'List yourself';
const youPickTickerNext = 'You pick your ticker next.';

// ---------------------------------------------------------------------------
// Join an exchange (SCREENS.md #2)
// ---------------------------------------------------------------------------

const yourInvite = 'Your invite';
String joinTitle(String exchange) => 'Join $exchange';

/// "7 people are in it, 6 listed. You'll pick your ticker after you join."
String joinBody(int members, int listed) =>
    '$members ${members == 1 ? 'person is' : 'people are'} in it, '
    '$listed listed. You pick your ticker after you join.';
const listedHeading = 'Listed';
const nobodyListedYet = "Nobody's listed yet. You could be first.";
const joinTheExchange = 'Join the exchange';
const joiningLabel = 'Joining…';
String inviteCode(String code) => 'Invite $code';
const inviteDoesntWork = "This invite link doesn't work";
const inviteDoesntWorkBody =
    'Check the link, or ask whoever sent it for a new one.';
String exchangeIsFull(String exchange) => '$exchange is full';
const startAnExchange = 'Start an exchange';

/// Joining while offline.
const joinOffline = ErrorCopy(
  title: "You're offline",
  body: 'Joining needs a connection. Retry when you have one.',
  action: 'Retry',
);

// ---------------------------------------------------------------------------
// Your IPO (SCREENS.md #3)
// ---------------------------------------------------------------------------

const ipoTitle = 'Your IPO';

/// "Listing makes you a stock on The Group Chat. ..."; "this exchange" when
/// its name couldn't be loaded.
String ipoBody(String? exchange) =>
    'Listing makes you a stock on ${exchange ?? 'this exchange'}. Your '
    'friends can buy you, short you and file events about you.';
const ifYouList = 'If you list';
const whoTradesYou = 'Who trades you';
const everyoneButYou = 'Everyone but you';
const whatMovesYou = 'What moves you';
const whatTheGroupFiles = 'What the group files';
const changingYourMind = 'Changing your mind';
const optOutInSettings = 'Opt out any time in Settings';
const theAnalystRoastsEvents =
    'The Analyst roasts what happened, never who you are.';
const chooseTicker = 'Choose a ticker';
const pickTickerTitle = 'Pick your ticker';
const pickTickerBody = "3 to 5 letters. It's how the tape will name you.";
const tickerLabel = 'Ticker';
const tickerPlaceholder = 'NAME';
const tickerLength = '3 to 5 letters.';
String tickerChecking(String ticker) => 'Checking $ticker…';
String tickerFree(String ticker) => '$ticker is free.';
String tickerTaken(String ticker) => '$ticker is taken.';
String useTicker(String ticker) => 'Use $ticker';
const tickerCantCheck = "Can't check it while you're offline.";
String listMeAs(String ticker) => 'List me as $ticker';
const listMe = 'List me';
const listing = 'Listing…';
const pickFreeTicker = 'Pick a free ticker first.';
const yourConsent =
    'This is your consent to be listed. You can opt out in Settings.';

/// Listing while offline.
const ipoOffline = ErrorCopy(
  title: "You're offline",
  body: 'Listing needs a connection. Retry when you have one.',
  action: 'Retry',
);
String listedTitle(String ticker) => "You're listed as $ticker";

/// "The market opens at 3 listings. 1 of 3 so far."
String listedBody(int listed, int minListings) => listed >= minListings
    ? '$listed listed, so trading has started.'
    : 'The market opens at $minListings listings. $listed of $minListings '
          'so far.';
const openTheExchange = 'Open the exchange';

// ---------------------------------------------------------------------------
// Launch problems (SCREENS.md #24)
// ---------------------------------------------------------------------------

/// Offline before anything loaded: there are no old numbers to stamp.
const offlineAtLaunchTitle = "You're offline";
const offlineAtLaunchBody =
    'Aura Exchange needs a connection to load your exchange. Your cash and '
    'positions are safe.';

/// The app is sideloaded, so there's no store to send you to.
const checkAgain = 'Check again';
const updateFootnote = 'Install the new build, then open the app again';
const somethingWentWrongBody = 'Try again in a moment.';
const signOut = 'Sign out';

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
const tagHalted = 'Halted';
const tagDelisted = 'Delisted';
const tagRumor = 'Rumor';
const tagYou = 'You';
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

/// An IPO-day row for someone already listed: "Listed as $MIA".
String listedAs(String ticker) => 'Listed as $ticker';
const firstOnTheTape = 'First thing on the tape';
const analystAtTheOpen = 'The Analyst · when the market opens';

// ---------------------------------------------------------------------------
// Market list (SCREENS.md #6)
// ---------------------------------------------------------------------------

const allStocks = 'All stocks';
String resultsCount(int n) => '$n ${n == 1 ? 'result' : 'results'}';
String nobodyMatches(String query) => 'Nobody matches “$query”';
const searchByNameOrTicker = 'Search by name or ticker.';
const haltedExchangeWide = 'Halted · exchange-wide';

/// The whole exchange halted (`marketState: HALTED`).
ErrorCopy exchangeHaltedBanner(
  DateTime? resumesAt,
  tz.Location zone, {
  required DateTime now,
}) => ErrorCopy(
  title: 'Trading is halted exchange-wide',
  body: resumesAt == null
      ? 'Prices hold where they are until it resumes.'
      : 'Prices hold where they are until '
            '${formatMoment(resumesAt, zone, now: now)}.',
);

// ---------------------------------------------------------------------------
// Trade sheet and outcomes, beyond W05 and W06 (SCREENS.md #9, #10)
// ---------------------------------------------------------------------------

/// "Slide to buy 12 $ANNA", "Slide to short 12 $JAKE".
String slideToTrade(Side side, Decimal quantity, String ticker) =>
    'Slide to ${_verb(side).toLowerCase()} ${formatQuantity(quantity)} '
    '${formatTicker(ticker)}';
const gettingNewPrice = 'Getting a new price…';
const gettingPrice = 'Getting a price…';
const liquidationPriceLabel = 'Liquidation price';
const collateralHeldLabel = 'Collateral held';
const limitPriceLabel = 'Limit price';
const stopPriceLabel = 'Stop price';

/// What a limit or stop does, under its price field.
String limitNote(Side side, String ticker) => side == Side.buy
    ? 'Buys when ${formatTicker(ticker)} trades at this price or lower.'
    : 'Sells when ${formatTicker(ticker)} trades at this price or higher.';
String stopNote(String ticker) =>
    'Sells your ${formatTicker(ticker)} if it falls to this price.';
const enterAPrice = 'Enter a price to place the order.';
const slideToPlaceOrder = 'Slide to place the order';
const placingOrder = 'Placing…';

/// The filled receipt's title: "Bought 12 $ANNA".
String filledTitle(Side side, Decimal quantity, String ticker) =>
    '${switch (side) {
      Side.buy => 'Bought',
      Side.sell => 'Sold',
      Side.short => 'Shorted',
      Side.cover => 'Covered',
      Side.$unknown => 'Traded',
    }} ${formatQuantity(quantity)} ${formatTicker(ticker)}';
const filledPrice = 'Price';
const filledShares = 'Shares';
const filledFee = 'Fee';
String filledTotal(Side side) =>
    side == Side.sell || side == Side.short ? 'Received' : 'Paid';
const cashAfterLabel = 'Your cash now';
const done = 'Done';
const setStopLoss = 'Set a stop-loss';
const orderPlacedTitle = 'Order placed';

/// "Resting at A$95.00. It fills when $ANNA trades there."
String restingBody(Decimal price, String ticker) =>
    'Resting at ${formatMoney(price)}. It fills when ${formatTicker(ticker)} '
    'trades there.';
const orderTypeLabel = 'Type';
String orderTypeWord(OrderType type) => switch (type) {
  OrderType.limitBuy => 'Limit buy',
  OrderType.limitSell => 'Limit sell',
  OrderType.stopLoss => 'Stop-loss',
  OrderType.takeProfit => 'Take-profit',
  OrderType.$unknown => 'Order',
};
const triggerLabel = 'Fills at';
const reservedLabel = 'Held from your cash';
const cancelOrder = 'Cancel the order';
const orderCanceled = 'Order canceled';

/// Trading while offline.
const tradeOffline = ErrorCopy(
  title: "You're offline",
  body: "Nothing was traded. Retry when you're back; it won't trade twice.",
  action: 'Retry',
);

// ---------------------------------------------------------------------------
// File an event and its status (SCREENS.md #11, #12)
// ---------------------------------------------------------------------------

const whoIsItAbout = "Who's it about?";
const searchPeople = 'Search friends';
const whatHappened = 'What happened';
const whatHappenedPlaceholder =
    'Stick to what you saw. The Analyst writes the headline.';

/// Who can see who filed (API-CONTRACT.md → Privacy).
String onlyTheyKnow(String name) =>
    'Only moderators and $name will know it was you.';
const onlyModeratorsKnow = 'Only moderators will know it was you.';
const fileIt = 'File';
const filingLabel = 'Filing…';
const writeWhatHappened = 'Write what happened to file it.';
const selfFilingTitle = "You're filing about yourself";
const selfFilingBody =
    'The Analyst treats company-issued news with some skepticism.';
const discardTitle = 'Discard this filing?';
const discardBody = "What you wrote won't be kept.";
const keepWriting = 'Keep writing';
const discard = 'Discard';

/// Filing while offline.
const fileOffline = ErrorCopy(
  title: "You're offline",
  body: "It wasn't filed. Retry when you're back; it won't file twice.",
  action: 'Retry',
);
String yourFilingAbout(String ticker) => 'Your filing about $ticker';
const filedLabel = 'Filed';
const rumorLabel = 'Rumor';
const rulingLabel = 'Ruling';
const waiting = 'Waiting';
String liveUntil(String at) => 'until $at';
String ruledAt(String at) => 'Ruled $at';

/// The unsend toast: "Filed · goes live in 0:24" (PLAN.md → Quality bar).
String filedGoesLive(String countdown) => 'Filed · goes live in $countdown';
const undo = 'Undo';
const unsentTitle = 'Unsent';
const unsentBody = "Nobody saw it, and it won't move anything.";
const haltedForVoteTitle = 'Halted for a group vote';
String haltedForVoteBody(String at) =>
    'The group has until $at to confirm, decline or reconsider it.';
const voidedTitle = 'Voided';
const voidedBody = "It didn't move the price.";
const inReviewTitle = 'With the moderators';
const inReviewBody = 'They check it before anyone else sees it.';

// ---------------------------------------------------------------------------
// Rumor, ruling and the news-halt vote (SCREENS.md #13, #15, #17)
// ---------------------------------------------------------------------------

/// "Unconfirmed report · 9:37 pm".
String unconfirmedReport(String at) => 'Unconfirmed report · $at';
const rumorPublicExplainer =
    'The Analyst rules when the rumor closes. Until then, anyone can back '
    'it or call it.';
const caps = 'Caps';
const didItHappen = 'Did it happen?';
const iSawIt = 'I saw it';
const iSawItNote =
    "Co-sign it. You'll be an insider on it until after it rules.";
const didntHappen = "Didn't happen";
const didntHappenNote = 'Cap it. It counts for less if it rules.';
const takeItBack = 'Take it back';
const takeItBackNote = 'Withdraw your call while the rumor is open';
const yourCall = 'Your call';

/// The insider notice (PLAN.md → Rumor phase).
String insiderTitle(String at) => "You're an insider on this until $at";
String insiderBody(String ticker) =>
    "Don't trade $ticker until then. It's on record that you knew.";

/// "Ruled · 9:52 pm".
String ruledLine(String at) => 'Ruled · $at';
const correctionTitle = 'Correction';
const storyHiddenTitle = 'Story hidden';
const storyHiddenBody =
    'A super-injunction hid the story. The price hit stays.';
const theAnalyst = 'The Analyst';
const groupVoteHeading = 'Was it worth it?';
const voteUp = 'Vote it up';
const voteUpNote = 'It deserved a bigger move';
const voteDown = 'Vote it down';
const voteDownNote = 'It deserved a smaller one';
const yourVoteLabel = 'Your vote';
String votingClosesAt(String at) => 'Voting closes $at';
const votingClosed = 'Voting has closed';
String conflictedNote(String ticker) =>
    'You hold $ticker, so your vote shows as conflicted.';
const confirmedTitle = 'The group confirmed it';
const declinedTitle = 'The group declined it';
const reconsideredTitle = 'The group sent it back';
const reconsideredBody = "The Analyst ruled once more, and that's final.";

// ---------------------------------------------------------------------------
// Tape and notifications (SCREENS.md #18, #19)
// ---------------------------------------------------------------------------

const tapeFilterLabel = 'Show';
const tapeFilterAll = 'All';

/// The Tape tab's filters and the item types each one shows.
const tapeFilters = {
  tapeFilterAll: null,
  'Rulings': 'RULING,CORRECTION',
  'Rumors': 'RUMOR',
  'Halts': 'HALT,HALT_RESULT',
  'Trades': 'WHALE,LIQUIDATION',
};
const tapeEmptyBody = 'It fills up as the group files events.';
const tapeFilteredEmptyTitle = 'Nothing like that yet';
const tapeFilteredEmptyBody = 'The rest of the tape is under All.';
const showOlder = 'Show older';
const notificationsTitle = 'Notifications';
const noNotifications = 'No notifications';
const noNotificationsBody =
    'Rulings about you, your fills and margin warnings land here.';
const theExchange = 'The exchange';

/// Quiet hours on: "Quiet hours until 7:00 am".
String quietHoursUntil(String end) => 'Quiet hours until $end';
const quietHoursBody = 'Nothing buzzes until then. It all waits in here.';

// ---------------------------------------------------------------------------
// Stock page (SCREENS.md #7, #8)
// ---------------------------------------------------------------------------

const chartRange = 'Chart range';
const chartRanges = ['1D', '1W', '1M', 'SZN'];
const tabOverview = 'Overview';
const tabTape = 'Tape';
const tabAnalyst = 'Analyst';
const stockTabs = [tabOverview, tabTape, tabAnalyst];
const statOpen = 'Open';
const statPrevClose = 'Prev close';
const statDayRange = 'Day range';
const statVolume = 'Volume';
const statShortInterest = 'Short interest';
const notYet = 'Not yet';
const eventsHeading = 'Events';
const noEventsYet = 'No events yet';
String noEventsYetBody(String name) =>
    "Nothing's been filed about $name. When something happens, file it.";
const nothingOnTapeYet = 'Nothing on the tape yet';
String nothingOnTapeBody(String ticker) =>
    'Rulings and big trades in $ticker show up here.';
const noAnalystNote = 'No coverage yet';
const noAnalystNoteBody = 'The Analyst writes a note after the first ruling.';
const indicated = 'indicated';
const short = 'Short';
const shortMore = 'Short more';
const coverLabel = 'Cover';
const youCantTradeYourself = "This is you. You can't trade your own stock.";
const delistedNoTrading = "Delisted stocks don't trade.";
const offlineNoTrading = "Trading waits until you're back online.";
const closedOrdersNote = 'Orders you set now fill at the opening price.';

/// "A rumor about $MIA is pending".
String rumorPendingTitle(String ticker) => 'A rumor about $ticker is pending';
const rumorPendingBody =
    'The Analyst rules on it soon. Read it before you trade.';
const readIt = 'Read it';

/// "$SAM is delisted".
String delistedTitle(String ticker) => '$ticker is delisted';
String delistedBody(String name, Decimal price) =>
    '$name opted out. Holders were cashed out at the last price, '
    '${formatMoney(price)}.';

/// The status word for an event on the stock page (API-CONTRACT.md → One
/// status vocabulary).
String eventStatusWord(EventStatus status) => switch (status) {
  EventStatus.sending => 'Sending',
  EventStatus.rumor => 'Unconfirmed',
  EventStatus.ruling => 'Ruling',
  EventStatus.ruled => 'Ruled',
  EventStatus.halted => 'Halted',
  EventStatus.review => 'In review',
  EventStatus.voided => 'Voided',
  EventStatus.canceled => 'Unsent',
  EventStatus.hidden => 'Story hidden',
  EventStatus.$unknown => 'Updated',
};

/// What a tape item is, in its source line: "$JAKE · Ruling · 2 h ago".
String tapeTypeWord(TapeItemType type) => switch (type) {
  TapeItemType.ipo => 'IPO',
  TapeItemType.rumor => 'Rumor',
  TapeItemType.ruling => 'Ruling',
  TapeItemType.halt => 'Halt',
  TapeItemType.haltResult => 'Halt result',
  TapeItemType.whale => 'Big trade',
  TapeItemType.liquidation => 'Liquidation',
  TapeItemType.correction => 'Correction',
  TapeItemType.bell => 'Bell',
  TapeItemType.sec => 'SEC',
  TapeItemType.earnings => 'Earnings',
  TapeItemType.rating => 'Rating',
  TapeItemType.fed => 'The Fed',
  TapeItemType.split => 'Split',
  TapeItemType.chapter11 => 'Chapter 11',
  TapeItemType.bankruptcy => 'Chapter 7',
  TapeItemType.delisting => 'Delisting',
  _ => 'News',
};

/// "Buy · target A$130.00", under the Analyst's note.
String analystRatingSource(String rating, Decimal target) =>
    'The Analyst · $rating · target ${formatMoney(target)}';

// ---------------------------------------------------------------------------
// Trade sheet (W05, W06)
// ---------------------------------------------------------------------------

/// "Buy $ANNA"; with a quantity once it's settled, "Buy 12 $ANNA".
String tradeTitle(Side side, String ticker, {Decimal? quantity}) =>
    quantity == null
    ? '${_verb(side)} $ticker'
    : '${_verb(side)} ${formatQuantity(quantity)} $ticker';

const orderMarket = 'Market';
const orderLimit = 'Limit';
const orderStop = 'Stop';
const orderType = 'Order type';

/// Under the stepper: "shares at about A$124.10".
String sharesAtAbout(Decimal price) => 'shares at about ${formatMoney(price)}';

/// "20 × A$124.10".
String quantityAt(Decimal quantity, Decimal price) =>
    '${formatQuantity(quantity)} × ${formatMoney(price)}';

/// "Fee (0.5%)": the rate as the server sends it, without trailing zeros.
String feeLabel(Decimal ratePct) => 'Fee (${ratePct.toString()}%)';

const estimatedTotal = 'Estimated total';
const youSaw = 'You saw';
const newTotal = 'New total';

/// "A$1,511.84 (+15.19)": the new total and how far it moved.
String totalWithChange(Decimal total, Decimal change) =>
    '${formatMoney(total)} (${formatSigned(change)})';

/// The ticket's button: "Buy 20 $ANNA".
String tradeButton(Side side, Decimal quantity, String ticker) =>
    '${_verb(side)} ${formatQuantity(quantity)} $ticker';

/// The requote's slider: "Slide to buy at A$125.36".
String slideToTradeAt(Side side, Decimal price) =>
    'Slide to ${_verb(side).toLowerCase()} at ${formatMoney(price)}';

/// The requote's way out: "Don't buy".
String dontTrade(Side side) => "Don't ${_verb(side).toLowerCase()}";

const priceHoldsFor = 'This price holds for';

// ---------------------------------------------------------------------------
// Stock page (W10, and behind the trade sheet)
// ---------------------------------------------------------------------------

/// "$ANNA · Anna", or with the last trade while halted:
/// "$MIA · Mia · last trade 4:51 pm".
String stockLine(
  String ticker,
  String name, {
  String? lastTrade,
  List<Badge> badges = const [],
}) => [
  formatTicker(ticker),
  name,
  for (final badge in badges) ?badgeLabel(badge),
  if (lastTrade != null) 'last trade $lastTrade',
].join(' · ');

/// A listing's badge, as it reads after the name: "Hard to borrow" (W07).
/// Badges added to the contract later aren't shown until they have words.
String? badgeLabel(Badge badge) => switch (badge) {
  Badge.hardToBorrow => 'Hard to borrow',
  Badge.otcPink => 'OTC Pink',
  Badge.meme => 'Meme stock',
  Badge.rumorPending => 'Rumor pending',
  Badge.queuedForOpen => 'Ruling at the open',
  Badge.$unknown => null,
};

/// The status chip on a halted stock page (W10).
String haltStatus(HaltReason reason) => switch (reason) {
  HaltReason.newsPending => 'Halted · news pending',
  HaltReason.volatility => 'Halted · big move',
  HaltReason.circuitBreaker => 'Halted · circuit breaker',
  HaltReason.$unknown => 'Halted',
};

const voteClosesIn = 'Vote closes in';

/// "4 of 6 voted".
String votedOf(int voted, int eligible) => '$voted of $eligible voted';

/// The word under an impact score.
String impactWord(int impact) => switch (impact.sign) {
  > 0 => 'Gain',
  < 0 => 'Loss',
  _ => 'Lore',
};

/// Why a news halt needs a vote, and what confirming it does (W10).
String haltExplainer(String ticker, Decimal movePct) {
  final size = movePct.abs().toString();
  final way = movePct.sign < 0 ? 'lower' : 'higher';
  return "A ruling this big needs the group's vote. If it's confirmed, "
      '${formatTicker(ticker)} reopens about $size% $way.';
}

const yourVote = 'Your vote';
const voteConfirm = 'Confirm';
String voteConfirmNote(int impact) =>
    'The ruling stands at ${formatImpact(impact)}';
const voteDecline = 'Decline';
const voteDeclineNote = 'The ruling is voided';
const voteReconsider = 'Reconsider';
const voteReconsiderNote = "The Analyst rules once more, and that's final";

/// "Voting pays A$100.00. Nobody sees how you voted."
String votingPays(Decimal reward) =>
    'Voting pays ${formatMoney(reward)}. Nobody sees how you voted.';

const sell = 'Sell';
const buy = 'Buy';

/// Under disabled Sell and Buy while a news vote runs (W10).
const tradingResumesAfterVote = 'Trading resumes when the vote closes.';

// ---------------------------------------------------------------------------
// Your short, near liquidation (W07) and liquidated (W08)
// ---------------------------------------------------------------------------

const today = 'today';

/// A percentage to one decimal, without a sign: "4.2%".
String _pct1(Decimal pct) => '${pct.abs().round(scale: 1)}%';

/// A percentage as the server sends it, without trailing zeros: "31%".
String _pct(Decimal pct) => '${pct.abs()}%';

String nearLiquidationTitle(String ticker) =>
    'Your ${formatTicker(ticker)} short is close to liquidation';

/// "4.2% more and the exchange covers it for you. Short interest is 31%, so
/// a squeeze can get there fast."
String nearLiquidationBody(Decimal awayPct, Decimal shortInterestPct) =>
    '${_pct1(awayPct)} more and the exchange covers it for you. Short '
    'interest is ${_pct(shortInterestPct)}, so a squeeze can get there fast.';

const yourShort = 'Your short';
const entryToLiquidation = 'From your entry to liquidation';

/// "4.2% away".
String awayFromLiquidation(Decimal awayPct) => '${_pct1(awayPct)} away';

const statPosition = 'Position';
const statReturn = 'Return';
const statCollateral = 'Collateral';
const statBorrowFee = 'Borrow fee';

/// "Short 60".
String shortQuantity(Decimal quantity) => 'Short ${formatQuantity(quantity)}';

/// "130%".
String ratio(Decimal pct) => _pct(pct);

/// "min 125%".
String minimumRatio(Decimal pct) => 'min ${_pct(pct)}';

/// "0.6% a day".
String perDay(Decimal pct) => '${_pct(pct)} a day';

/// What liquidation does, in the position's own numbers (W07).
String liquidationExplainer(Decimal liquidationPrice, Decimal quantity) =>
    'Above ${formatMoney(liquidationPrice)} the exchange buys back all '
    "${formatQuantity(quantity)} shares at market and returns what's left of "
    'your collateral. Covering yourself nudges the price up too.';

/// "Cover 30", "Cover all 60".
String cover(Decimal quantity) => 'Cover ${formatQuantity(quantity)}';
String coverAll(Decimal quantity) => 'Cover all ${formatQuantity(quantity)}';

String liquidatedTitle(String ticker) =>
    'Your ${formatTicker(ticker)} short was liquidated';

/// "3:12 pm · $JAKE crossed A$117.00 and your collateral fell under 125%".
String liquidatedWhy({
  required String at,
  required String ticker,
  required Decimal triggerPrice,
  required Decimal maintenancePct,
}) =>
    '$at · ${formatTicker(ticker)} crossed ${formatMoney(triggerPrice)} and '
    'your collateral fell under ${_pct(maintenancePct)}';

const returnedToCash = 'Returned to your cash';
const onTheTrade = 'on the trade';
const collateralHeld = 'Collateral held';

/// "Bought back 60 at A$118.10".
String boughtBack(Decimal quantity, Decimal price) =>
    'Bought back ${formatQuantity(quantity)} at ${formatMoney(price)}';
const returned = 'Returned';
const onTheTape = 'On the tape';

/// A tape headline quoted on a screen: “…”. Headlines come from the server
/// bare; the screen that quotes them adds the marks.
String quoted(String text) => '“$text”';

/// Liquidations never name the trader (API-CONTRACT.md → Privacy), and the
/// screen says so: "3:12 pm · your name isn't in it".
String nameNotInIt(String at) => "$at · your name isn't in it";
const seePortfolio = 'Portfolio';

/// "See $JAKE".
String seeStock(String ticker) => 'See ${formatTicker(ticker)}';

// ---------------------------------------------------------------------------
// Chapter 7 (W04)
// ---------------------------------------------------------------------------

/// Under the minimum to trade (`EQUITY_TOO_LOW`, and the W04 offer). The
/// screen's slider and "Keep going" are the choices, so no button here.
ErrorCopy underMinimumCopy(Decimal? minimum) => ErrorCopy(
  title: minimum == null
      ? "You're too low to trade"
      : "You're under ${formatMoney(minimum)}",
  body:
      "That's not enough to open a position. "
      'Keep what you have, or start over with Chapter 7.',
);

const ifYouFile = 'If you file';
const youGet = 'You get';
const youGiveUp = 'You give up';

/// "A$64.12 + 1 position".
String netWorthAndPositions(Decimal netWorth, int positions) => positions == 0
    ? formatMoney(netWorth)
    : '${formatMoney(netWorth)} + $positions '
          '${_plural(positions, 'position', 'positions')}';
const badgeUntilSeasonEnds = 'Your badge, until the season ends';
const whatTheTapeWillSay = 'What the tape will say';
const tapeTheMomentYouFile = 'The tape · the moment you file';
const slideToDeclareBankruptcy = 'Slide to declare bankruptcy';

/// "Keep going with A$64.12".
String keepGoingWith(Decimal netWorth) =>
    'Keep going with ${formatMoney(netWorth)}';

// ---------------------------------------------------------------------------
// About you: a rumor (W01), a ruling (W02), an SEC charge (W03)
// ---------------------------------------------------------------------------

/// The status chip while closed: "Closed · opens 7:00 am".
String closedOpens(
  DateTime opensAt,
  tz.Location zone, {
  required DateTime now,
}) => 'Closed · opens ${formatMoment(opensAt, zone, now: now)}';

/// "An unconfirmed report about you · 2:14 am".
String rumorAboutYou(String at) => 'An unconfirmed report about you · $at';

/// "A ruling about you · 2:24 am".
String rulingAboutYou(String at) => 'A ruling about you · $at';

const rumorExplainer =
    'This is all anyone can see right now. The details come with the ruling.';
const rulingIn = 'Ruling in';
const coSigns = 'Co-signs';
const receiptsLabel = 'Receipts';
const howDoYouRespond = 'How do you respond?';
const respondNoComment = 'No comment';
const respondNoCommentNote = 'Shows on the tape. Changes nothing.';
const respondDeny = 'Deny it';

/// "If it's confirmed, the hit is 20% bigger".
/// The deny row's risk. The size comes from the server (contract request
/// #9); without it the note says so without a number.
String denyNote(Decimal? penaltyPct) => penaltyPct == null
    ? "If it's confirmed, the hit is bigger"
    : "If it's confirmed, the hit is ${penaltyPct.abs()}% bigger";
const risky = 'Risky';
const respondNothing = 'Say nothing';

/// "The ruling lands in 9 minutes either way".
String rulingLandsIn(Duration left) {
  final minutes = left.inMinutes;
  return minutes < 1
      ? 'The ruling lands in under a minute either way'
      : 'The ruling lands in $minutes ${_plural(minutes, 'minute', 'minutes')} '
            'either way';
}

/// Under a rumor about you (W01).
String rumorFooter(String ticker) =>
    "You can't trade ${formatTicker(ticker)}. Once it's ruled you'll see who "
    'filed it; nobody else will.';

/// "Lands at the 7:00 am open".
String landsAtOpen(DateTime at, tz.Location zone, {required DateTime now}) =>
    'Lands at the ${formatMoment(at, zone, now: now)} open';

/// "From A$112.40 · indicated, not traded yet".
String indicatedFrom(Decimal previousClose) =>
    'From ${formatMoney(previousClose)} · indicated, not traded yet';

/// "The Analyst · Downgrade · target A$96.00".
String analystSource(String? ratingChange, Decimal target) =>
    ['The Analyst', ?ratingChange, 'target ${formatMoney(target)}'].join(' · ');
const statAnalyst = 'Analyst';

/// "3 co-signs".
String coSignCount(int n) => '$n ${_plural(n, 'co-sign', 'co-signs')}';

/// "×1.30".
String multiplier(Decimal factor) => '×${factor.toStringAsFixed(2)}';
const groupVote = 'Group vote';

/// "4–1".
String voteScore(int up, int down) => '$up–$down';
const postStatement = 'Post a statement';
const postStatementNote = 'Runs on the tape next to the story';
const superInjunction = 'Super-injunction';
const superInjunctionNote = 'Hides the story · the price hit stays';

/// "2 of 3 left", or "2 left" when the season's allowance isn't known
/// (contract request #9).
String leftOf(int left, int? of) =>
    of == null ? '$left left' : '$left of $of left';
const appealRuling = 'Appeal';
const appealNote = 'The admin reviews it';

/// "6 days left", from the deadline.
String daysLeft(DateTime deadline, {required DateTime now}) {
  final hours = deadline.difference(now).inHours;
  final days = (hours / 24).ceil();
  return days <= 1 ? 'Last day' : '$days days left';
}

/// "Social Exchange Commission · Case 0007 · 1:21 pm".
String secCaseLine(String caseNumber, String at) =>
    'Social Exchange Commission · Case $caseNumber · $at';
const takenFromCash = 'Taken from your cash';

/// "Your profit, clawed back, plus a 50% fine".
String clawbackNote(Decimal finePct) =>
    'Your profit, clawed back, plus a ${finePct.abs()}% fine';

/// "You filed the gym rumor".
String youFiled(String what) => 'You filed $what';

/// "You bought 30 $JAKE".
String youBought(Decimal quantity, String ticker) =>
    'You bought ${formatQuantity(quantity)} ${formatTicker(ticker)}';

/// "12:43 pm at A$97.00".
String atPrice(String at, Decimal price) => '$at at ${formatMoney(price)}';
const profitWhenRuled = 'Profit when it ruled';
const oddsOfGettingCaught = 'Odds of getting caught';

/// "27%".
String percentWhole(Decimal pct) => '${pct.abs()}%';
const clawedBackPlusFine = 'Clawed back + fine';

/// "Scandal filed against $SAM".
String scandalAgainst(String ticker) =>
    'Scandal filed against ${formatTicker(ticker)}';

/// "−8 impact · on the tape now".
String impactOnTape(int impact) =>
    '${formatImpact(impact)} impact · on the tape now';
const appealCharge = 'Appeal the charge';

/// How to stay clean, in the case's own window (W03).
String stayClean(int windowMinutes) =>
    "To stay clean: don't trade a stock from the moment you file or co-sign "
    "on it until $windowMinutes minutes after it's ruled.";

// ---------------------------------------------------------------------------
// The exchange is down (W13)
// ---------------------------------------------------------------------------

const lastGoodUpdate = 'Last good update';
const ordersAndRulingsQueued = 'Orders and rulings queued';
const keptForLater = 'Kept for later';
const marketClock = 'Market clock';
const paused = 'Paused';
const onTheTapeOnceBack = "On the tape, once it's back";

/// The one Analyst line the app writes itself: the server can't send one
/// while it's down.
const exchangeDownTape =
    'Trading halted exchange-wide pending a technical review. The Analyst was '
    'unavailable for comment.';

/// The lead-in to W13's reference line, as drawn. There's no push yet, so
/// the promise isn't true: Nathan decides the wording (see PROGRESS.md →
/// Waiting on Nathan).
const exchangeDownLeadIn = "You'll get a notification when it's back";

/// "You'll get a notification when it's back · 503 · 7F2K".
String exchangeDownFootnote(String? reference) =>
    [exchangeDownLeadIn, ?reference].join(' · ');
