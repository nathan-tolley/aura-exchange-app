import 'package:aura_exchange/api/errors.dart';
import 'package:aura_exchange/data/api_providers.dart';
import 'package:aura_exchange/design/tone.dart';
import 'package:aura_exchange/design/widgets/aura_banner.dart';
import 'package:aura_exchange/features/onboarding/sign_in_model.dart';
import 'package:aura_exchange/features/onboarding/sign_in_screen.dart';
import 'package:aura_exchange/l10n/strings.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_http.dart';
import '../support/fake_socket.dart';
import '../support/providers.dart';

/// Sign-in (SCREENS.md #1): the controller against a fake server, and the
/// presenters' wording of each state.
void main() {
  late FakeAdapter http;
  late ProviderContainer container;

  setUp(() {
    http = FakeAdapter((_) => ResponseBody.fromString('', 204));
    container = testContainer(
      http: http,
      sockets: <FakeSocket>[],
      now: DateTime.utc(2026, 10, 24, 10, 41),
      tokens: null,
    );
    container.listen(signInProvider, (_, _) {});
  });

  tearDown(() => container.dispose());

  SignInController controller() => container.read(signInProvider.notifier);
  SignInState state() => container.read(signInProvider);
  String? keyOf(RequestOptions r) => r.headers['Idempotency-Key'] as String?;

  group('controller', () {
    test('sends the code and moves to the code step', () async {
      await controller().send(' nathan@example.com ');
      expect(state().step, SignInStep.code);
      expect(state().email, 'nathan@example.com');
      expect(http.to('/auth/email/start').single.data, {
        'email': 'nathan@example.com',
      });
    });

    test("an address that doesn't look like one isn't sent", () async {
      await controller().send('nathan@example');
      expect(state().emailInvalid, isTrue);
      expect(http.requests, isEmpty);
      final m = signInEmailModel(state(), hasEmail: true);
      expect(m.fieldNote, startsWith("That email address doesn't look right."));
      expect(m.fieldNoteTone, AuraTone.down);
    });

    test('offline, then Retry: the same address reuses its key', () async {
      http.handler = offline;
      await controller().send('nathan@example.com');
      expect(state().problem?.code, ApiError.appOffline);
      expect(state().step, SignInStep.email);

      http.handler = (_) => ResponseBody.fromString('', 204);
      await controller().send('nathan@example.com');
      final sends = http.to('/auth/email/start');
      expect(sends, hasLength(2));
      expect(keyOf(sends[0]), keyOf(sends[1]));
      expect(state().step, SignInStep.code);
    });

    test('a different address is a new action with a new key', () async {
      http.handler = offline;
      await controller().send('nathan@example.com');
      await controller().send('nate@example.com');
      final sends = http.to('/auth/email/start');
      expect(keyOf(sends[0]), isNot(keyOf(sends[1])));
    });

    test('Send a new code is a new action', () async {
      await controller().send('nathan@example.com');
      await controller().resend();
      final sends = http.to('/auth/email/start');
      expect(keyOf(sends[0]), isNot(keyOf(sends[1])));
      expect(state().resent, isTrue);
      expect(
        signInCodeModel(state(), digits: 0).body,
        newCodeSentTo('nathan@example.com'),
      );
    });

    test('a wrong code says how many tries are left', () async {
      await controller().send('nathan@example.com');
      http.handler = (_) =>
          errorBody(401, 'LOGIN_CODE_INVALID', params: {'attemptsLeft': '2'});
      await controller().verify('482914');
      final m = signInCodeModel(state(), digits: 0);
      expect(m.codeNote, "That code isn't right. You have 2 more tries.");
      expect(m.codeNoteTone, AuraTone.down);
      expect(m.codeEnabled, isTrue);
      expect(m.banner, isNull);
    });

    test('each code typed gets its own key; a retried one keeps it', () async {
      await controller().send('nathan@example.com');
      http.handler = offline;
      await controller().verify('482913');
      await controller().retry();
      http.handler = (_) => errorBody(401, 'LOGIN_CODE_INVALID');
      await controller().verify('111111');
      final checks = http.to('/auth/email/verify');
      expect(checks, hasLength(3));
      expect(keyOf(checks[0]), keyOf(checks[1]));
      expect(keyOf(checks[1]), isNot(keyOf(checks[2])));
    });

    test('the last try, or an expired code, needs a new one', () async {
      await controller().send('nathan@example.com');
      for (final error in [
        errorBody(401, 'LOGIN_CODE_INVALID', params: {'attemptsLeft': '0'}),
        errorBody(401, 'LOGIN_CODE_EXPIRED'),
      ]) {
        http.handler = (_) => error;
        await controller().verify('482913');
        final m = signInCodeModel(state(), digits: 6);
        expect(m.codeEnabled, isFalse);
        expect(m.canSignIn, isFalse);
        expect(m.note, sendNewCodeFirst);
        expect(m.banner?.tone, AuraBannerTone.warn);
        expect(m.banner?.action, isNull);
        expect(m.canResend, isTrue);
      }
    });

    test('the right code signs in', () async {
      await controller().send('nathan@example.com');
      http.handler = (_) => jsonBody(200, tokenPairJson);
      await controller().verify('482913');
      expect(container.read(authSessionProvider).signedIn.value, isTrue);
      expect(http.to('/auth/email/verify').single.data, {
        'email': 'nathan@example.com',
        'code': '482913',
      });
    });

    test('back keeps the address and clears the problem', () async {
      await controller().send('nathan@example.com');
      http.handler = (_) => errorBody(401, 'LOGIN_CODE_EXPIRED');
      await controller().verify('482913');
      controller().editEmail();
      expect(state().step, SignInStep.email);
      expect(state().email, 'nathan@example.com');
      expect(state().problem, isNull);
    });
  });

  group('wording', () {
    test('Send code says why it is off', () {
      final empty = signInEmailModel(const SignInState(), hasEmail: false);
      expect(empty.canSend, isFalse);
      expect(empty.note, enterYourEmail);
      final typed = signInEmailModel(const SignInState(), hasEmail: true);
      expect(typed.canSend, isTrue);
      expect(typed.note, playMoneyNote);
      final sending = signInEmailModel(
        const SignInState(busy: SignInBusy.sending),
        hasEmail: true,
      );
      expect(sending.button, sendingCode);
      expect(sending.canSend, isFalse);
    });

    test('offline is the offline banner with Retry', () {
      final m = signInEmailModel(
        const SignInState(problem: ApiError.offline()),
        hasEmail: true,
      );
      expect(m.banner?.tone, AuraBannerTone.offline);
      expect(m.banner?.action, 'Retry');
    });

    test('the exchange down is a down banner with its reference', () {
      final m = signInEmailModel(
        const SignInState(
          problem: ApiError(
            code: 'SERVER',
            params: {'reference': '7F2K'},
            retryable: true,
            action: ApiAction.retry,
            status: 500,
          ),
        ),
        hasEmail: true,
      );
      expect(m.banner?.tone, AuraBannerTone.down);
      expect(m.banner?.title, 'The exchange is down');
      expect(m.banner?.body, endsWith('500 · 7F2K'));
    });

    test('Sign in waits for six digits, then for the check', () {
      const sent = SignInState(step: SignInStep.code, email: 'a@b.co');
      expect(signInCodeModel(sent, digits: 3).note, enterTheCode);
      expect(signInCodeModel(sent, digits: 6).canSignIn, isTrue);
      final checking = signInCodeModel(
        sent.copyWith(busy: SignInBusy.verifying),
        digits: 6,
      );
      expect(checking.button, checkingCode);
      expect(checking.canSignIn, isFalse);
      expect(checking.codeEnabled, isFalse);
    });
  });
}
