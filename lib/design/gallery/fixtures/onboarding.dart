import 'package:flutter/widgets.dart';

import '../../../api/errors.dart';
import '../../../api/generated/export.dart';
import '../../../features/onboarding/create_exchange_model.dart';
import '../../../features/onboarding/create_exchange_view.dart';
import '../../../features/onboarding/ipo_model.dart';
import '../../../features/onboarding/ipo_view.dart';
import '../../../features/onboarding/join_model.dart';
import '../../../features/onboarding/join_view.dart';
import '../../../features/onboarding/sign_in_model.dart';
import '../../../features/onboarding/sign_in_view.dart';
import '../../../features/system/exchange_down_model.dart';
import '../../../features/system/exchange_down_view.dart';
import '../../../features/system/problem_view.dart';
import '../../../format/time.dart';
import 'frames.dart';

// Onboarding's states (SCREENS.md #1–#4) as the app reaches them: each is
// the screen's own state object run through its presenter, with errors in
// the contract's shape.

const _email = 'nathan@example.com';

ApiError _error(String code, [Map<String, String> params = const {}]) =>
    ApiError(
      code: code,
      params: params,
      retryable: false,
      action: ApiAction.none,
      status: 401,
    );

/// S01a: nothing typed yet; Send code says why it's off.
Widget signInEmail() => Controlled(
  texts: const [''],
  builder: (context, c) => SignInEmailView(
    model: signInEmailModel(const SignInState(), hasEmail: false),
    email: c[0],
    onSend: _noop,
  ),
);

/// S01b: the code went out.
Widget signInCodeSent() => _code(const SignInState(step: SignInStep.code));

/// S01c: a wrong code, two tries left.
Widget signInWrongCode() => _code(
  SignInState(
    step: SignInStep.code,
    problem: _error('LOGIN_CODE_INVALID', {'attemptsLeft': '2'}),
  ),
);

/// S01d: the code expired; only a new one helps.
Widget signInCodeExpired() => _code(
  SignInState(step: SignInStep.code, problem: _error('LOGIN_CODE_EXPIRED')),
);

/// S01e: Send code failed with no connection.
Widget signInNoNetwork() => Controlled(
  texts: const [_email],
  builder: (context, c) => SignInEmailView(
    model: signInEmailModel(
      const SignInState(problem: ApiError.offline()),
      hasEmail: true,
    ),
    email: c[0],
    onSend: _noop,
  ),
);

/// S24a: offline before anything loaded.
Widget launchOffline() =>
    ProblemView(model: problemModel(const ApiError.offline()), onAction: _noop);

/// S24b: this build is older than the exchange accepts.
Widget launchUpdateRequired() => ProblemView(
  model: problemModel(
    const ApiError(
      code: 'UPDATE_REQUIRED',
      params: {'minBuild': '12'},
      retryable: false,
      action: ApiAction.updateApp,
      status: 426,
    ),
  ),
  onAction: _noop,
);

/// S24c: a failure the app has no words for, with its reference.
Widget launchUnknown() => ProblemView(
  model: problemModel(
    const ApiError(
      code: 'TEAPOT',
      retryable: true,
      action: ApiAction.retry,
      status: 418,
    ),
  ),
  onAction: _noop,
  onSecondary: _noop,
);

/// S24e: a part of the app the exchange doesn't serve yet.
Widget launchNotLive() => ProblemView(
  model: problemModel(
    const ApiError(
      code: 'NOT_FOUND',
      params: {'resource': 'route'},
      retryable: false,
      action: ApiAction.none,
      status: 404,
    ),
  ),
  onAction: _noop,
);

/// S24d: the exchange down at launch, before any numbers were kept.
Widget launchExchangeDown() => ExchangeDownView(
  model: exchangeDownModel(
    error: const ApiError(
      code: 'SERVER',
      params: {'reference': '7F2K'},
      retryable: true,
      action: ApiAction.retry,
      status: 500,
    ),
    lastGood: null,
    zone: exchangeZone('UTC'),
    now: DateTime.utc(2026, 10, 24, 10, 41),
  ),
  onRetry: _noop,
);

Widget _code(SignInState state) => Controlled(
  texts: const [''],
  builder: (context, c) => SignInCodeView(
    model: signInCodeModel(
      SignInState(step: state.step, email: _email, problem: state.problem),
      digits: 0,
    ),
    code: c[0],
    onVerify: _noop,
    onResend: _noop,
    onRetry: _noop,
    onBack: _noop,
  ),
);

// Create an exchange (S04). "9:41 pm" in Sydney, as in the drawn screens.

final _now = DateTime.utc(2026, 10, 24, 10, 41);
const _exchangeId = '7c1d2e3f-0a1b-4c5d-8e9f-a0b1c2d3e4f5';

Exchange _exchange({int listed = 0, int members = 1}) => Exchange.fromJson({
  'id': _exchangeId,
  'name': 'The Group Chat',
  'timezone': 'Australia/Sydney',
  'hours': {
    'preOpen': '07:00',
    'open': '09:00',
    'close': '22:00',
    'afterClose': '02:00',
  },
  'feeRate': '0.50',
  'extendedFeeRate': '1.50',
  'listedCount': listed,
  'memberCount': members,
  'minListingsToOpen': 3,
  'season': {
    'id': '33333333-0000-4000-8000-000000000001',
    'number': 1,
    'startsAt': '2026-10-24T10:30:00Z',
    'endsAt': '2026-12-19T10:30:00Z',
  },
  'me': {
    'id': '22222222-0000-4000-8000-000000000001',
    'exchangeId': _exchangeId,
    'role': 'ADMIN',
    'listing': null,
    'listingConsentAt': null,
    'joinedAt': '2026-10-24T10:40:00Z',
    'badges': <String>[],
    'superInjunctionsLeft': 3,
    'superInjunctionsPerSeason': 3,
  },
});

final _invite = Invite.fromJson({
  'code': 'NATE-7F2K',
  'url': 'https://tae.app.elicit-marketing.com/i/NATE-7F2K',
  'expiresAt': '2026-10-31T10:41:00Z',
});

/// S04a: naming it, the name typed.
Widget createName() => Controlled(
  texts: const ['The Group Chat'],
  builder: (context, c) => CreateNameView(
    model: createNameModel(
      const CreateExchangeState(zone: 'Australia/Sydney'),
      hasName: true,
    ),
    name: c[0],
    onContinue: _noop,
  ),
);

const _named = CreateExchangeState(
  zone: 'Australia/Sydney',
  step: CreateStep.hours,
  name: 'The Group Chat',
);

/// S04b: the timezone, and what the hours start as.
Widget createHours() => CreateHoursView(
  model: createHoursModel(_named, now: _now),
  onBack: _noop,
  onZone: _noop,
  onCreate: _noop,
);

/// S04c: picking the timezone.
Widget createZoneSheet() => sheetOver(
  createHours(),
  ZoneSheet(
    options: zoneOptions('Australia/Sydney', now: _now),
    onPick: (_) {},
    onClose: _noop,
  ),
);

/// S04d: creating it with no connection.
Widget createNoNetwork() => CreateHoursView(
  model: createHoursModel(
    _named.copyWith(problem: () => const ApiError.offline()),
    now: _now,
  ),
  onBack: _noop,
  onZone: _noop,
  onCreate: _noop,
);

/// S04e: the invite link being made.
Widget inviteLoading() => _inviteView(null, null);

/// S04f: the invite link, ready to copy, just copied.
Widget inviteReady() => _inviteView(_invite, null, copied: true);

/// S04g: the link couldn't be made, offline.
Widget inviteOfflineState() => _inviteView(null, const ApiError.offline());

Widget _inviteView(Invite? invite, ApiError? problem, {bool copied = false}) =>
    Controlled(
      texts: [invite?.url ?? ''],
      builder: (context, c) => InviteView(
        model: inviteModel(
          exchange: _exchange(),
          invite: invite,
          problem: problem,
          now: _now,
        ),
        link: c[0],
        copied: copied,
        onBack: _noop,
        onRetry: _noop,
        onCopy: _noop,
        onContinue: _noop,
      ),
    );

/// S04h: waiting for friends, one of them joined.
Widget waiting() => WaitingView(
  model: waitingModel(_exchange(members: 2)),
  onInvite: _noop,
  onList: _noop,
);

/// S04i: waiting, while the exchange loads.
Widget waitingLoading() =>
    const WaitingView(model: null, onInvite: _noop, onList: _noop);

// Your IPO (S03).

/// S03a: what listing means.
Widget ipoConsent() =>
    const IpoConsentView(exchangeName: 'The Group Chat', onContinue: _noop);

/// S03b: the ticker free.
Widget ipoFree() => _ipoTicker(
  const IpoState(
    step: IpoStep.ticker,
    ticker: 'NATE',
    check: TickerCheckState.free,
  ),
);

/// S03c: the ticker taken, with the server's suggestions.
Widget ipoTaken() => _ipoTicker(
  const IpoState(
    step: IpoStep.ticker,
    ticker: 'JAKE',
    check: TickerCheckState.taken,
    suggestions: [r'$JAKEY', r'$JKE', r'$JAKES'],
  ),
);

/// S03d: still typing, two letters in.
Widget ipoTyping() =>
    _ipoTicker(const IpoState(step: IpoStep.ticker, ticker: 'NA'));

/// S03e: listing failed offline.
Widget ipoNoNetwork() => _ipoTicker(
  const IpoState(
    step: IpoStep.ticker,
    ticker: 'NATE',
    check: TickerCheckState.free,
    problem: ApiError.offline(),
  ),
);

/// S03f: listed, the first of three.
Widget ipoListed() => IpoListedView(
  model: ipoListedModel(
    ListingRef.fromJson({
      'id': '11111111-0000-4000-8000-000000000003',
      'ticker': r'$NATE',
      'displayName': 'Nathan',
      'avatarUrl': null,
    }),
    _exchange(listed: 1, members: 2),
  ),
  onInvite: _noop,
  onOpen: _noop,
);

Widget _ipoTicker(IpoState state) => Controlled(
  texts: [state.ticker],
  builder: (context, c) => IpoTickerView(
    model: ipoTickerModel(state),
    ticker: c[0],
    placeholder: 'NATH',
    onSuggestion: (_) {},
    onList: _noop,
    onBack: _noop,
  ),
);

// Join an exchange (S02), from aura://invite/JAKE-7F2K.

InvitePreview _preview(String status) => InvitePreview.fromJson({
  'code': 'JAKE-7F2K',
  'exchangeName': 'The Group Chat',
  'listed': [
    for (final (ticker, name) in [
      (r'$JAKE', 'Jake'),
      (r'$ANNA', 'Anna'),
      (r'$ELI', 'Eli'),
    ])
      {
        'id': '11111111-0000-4000-8000-00000000000${ticker.length}',
        'ticker': ticker,
        'displayName': name,
        'avatarUrl': null,
      },
  ],
  'memberCount': 4,
  'expiresAt': '2026-10-31T10:41:00Z',
  'status': status,
});

Widget _join({
  InvitePreview? preview,
  ApiError? previewError,
  ApiError? joinError,
  bool inAnExchange = false,
}) => JoinView(
  model: joinModel(
    code: 'JAKE-7F2K',
    preview: preview,
    previewError: previewError,
    joinError: joinError,
    joining: false,
    inAnExchange: inAnExchange,
  ),
  onAction: _noop,
  onRetry: _noop,
);

/// S02a: the invite, and who's listed.
Widget joinPreview() => _join(preview: _preview('VALID'));

/// S02b: the invite expired.
Widget joinExpired() => _join(preview: _preview('EXPIRED'));

/// S02c: the exchange is full.
Widget joinFull() => _join(preview: _preview('FULL'));

/// S02d: the link doesn't lead anywhere.
Widget joinNotFound() => _join(
  previewError: const ApiError(
    code: 'NOT_FOUND',
    params: {'resource': 'invite'},
    retryable: false,
    action: ApiAction.none,
    status: 404,
  ),
);

/// S02e: loading the invite.
Widget joinLoading() => _join();

/// S02f: loading the invite failed offline.
Widget joinNoNetwork() => _join(previewError: const ApiError.offline());

void _noop() {}
