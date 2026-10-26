import 'package:flutter/foundation.dart';

import '../../api/errors.dart';
import '../../api/generated/models/error_code.dart';
import '../../design/tone.dart';
import '../../design/widgets/aura_banner.dart';
import '../../l10n/strings.dart';
import '../shared/banner_model.dart';

/// Where sign-in is (SCREENS.md #1): which step, what's in flight, and the
/// last thing that went wrong. `SignInController` moves it; the presenters
/// below turn it into what each step shows.
@immutable
class SignInState {
  const SignInState({
    this.step = SignInStep.email,
    this.email = '',
    this.busy = SignInBusy.none,
    this.problem,
    this.emailInvalid = false,
    this.resent = false,
  });

  final SignInStep step;

  /// The address the code went to.
  final String email;
  final SignInBusy busy;

  /// The last failure, until the next attempt.
  final ApiError? problem;

  /// The address didn't look like one, so nothing was sent.
  final bool emailInvalid;

  /// A new code went out on the code step.
  final bool resent;

  SignInState copyWith({
    SignInStep? step,
    String? email,
    SignInBusy? busy,
    ApiError? Function()? problem,
    bool? emailInvalid,
    bool? resent,
  }) => SignInState(
    step: step ?? this.step,
    email: email ?? this.email,
    busy: busy ?? this.busy,
    problem: problem == null ? this.problem : problem(),
    emailInvalid: emailInvalid ?? this.emailInvalid,
    resent: resent ?? this.resent,
  );
}

enum SignInStep { email, code }

enum SignInBusy { none, sending, verifying }

/// The email step, worded.
@immutable
class SignInEmailModel {
  const SignInEmailModel({
    required this.button,
    required this.canSend,
    this.banner,
    this.fieldNote,
    this.fieldNoteTone = AuraTone.neutral,
    this.note,
  });

  final BannerModel? banner;

  /// Under the field: a problem with the address.
  final String? fieldNote;
  final AuraTone fieldNoteTone;

  /// "Send code", or "Sending…" while it goes.
  final String button;
  final bool canSend;

  /// Under the button: why it's disabled, or what Aura Bucks are.
  final String? note;
}

/// The email step: [hasEmail] is whether anything is typed in the field.
SignInEmailModel signInEmailModel(SignInState s, {required bool hasEmail}) {
  final sending = s.busy == SignInBusy.sending;
  final problem = s.problem;
  final (banner, note, tone) = _place(problem, invalidEmail: s.emailInvalid);
  return SignInEmailModel(
    banner: banner,
    fieldNote: note,
    fieldNoteTone: tone,
    button: sending ? sendingCode : sendCode,
    canSend: hasEmail && !sending,
    note: hasEmail || sending ? playMoneyNote : enterYourEmail,
  );
}

/// The code step, worded.
@immutable
class SignInCodeModel {
  const SignInCodeModel({
    required this.body,
    required this.codeEnabled,
    required this.canResend,
    required this.button,
    required this.canSignIn,
    this.banner,
    this.codeNote,
    this.codeNoteTone = AuraTone.neutral,
    this.note,
  });

  /// "We sent a 6-digit code to nathan@example.com."
  final String body;
  final BannerModel? banner;

  /// Under the cells: the wrong-code note.
  final String? codeNote;
  final AuraTone codeNoteTone;

  /// False while checking, and once the code can't be used any more.
  final bool codeEnabled;
  final bool canResend;

  /// "Sign in", or "Checking…".
  final String button;
  final bool canSignIn;

  /// Why Sign in is disabled.
  final String? note;
}

/// The code step: [digits] is how many are typed.
SignInCodeModel signInCodeModel(SignInState s, {required int digits}) {
  final verifying = s.busy == SignInBusy.verifying;
  final sending = s.busy == SignInBusy.sending;
  final problem = s.problem;
  final dead = _codeIsDead(problem);
  final (banner, note, tone) = _place(problem);
  final complete = digits == 6;
  return SignInCodeModel(
    body: s.resent ? newCodeSentTo(s.email) : codeSentTo(s.email),
    banner: banner,
    codeNote: note,
    codeNoteTone: tone,
    codeEnabled: !verifying && !dead,
    canResend: !sending && !verifying,
    button: verifying ? checkingCode : signIn,
    canSignIn: complete && !verifying && !dead,
    note: verifying
        ? null
        : dead
        ? sendNewCodeFirst
        : complete
        ? null
        : enterTheCode,
  );
}

/// The code can't be used any more: it expired, or that was the last try.
bool _codeIsDead(ApiError? problem) => switch (problem?.errorCode) {
  ErrorCode.loginCodeExpired => true,
  ErrorCode.loginCodeInvalid => problem!.params['attemptsLeft'] == '0',
  _ => false,
};

/// Where a problem shows: a banner (offline, the code is dead, anything the
/// field can't fix) or a note under the field (the address or the code was
/// wrong, too many tries too fast). The fix for a dead code is the Send a new
/// code button already on screen, so its banner has no action.
(BannerModel?, String?, AuraTone) _place(
  ApiError? problem, {
  bool invalidEmail = false,
}) {
  if (invalidEmail) {
    // Worded exactly as the server's VALIDATION on `email` would be.
    const local = ApiError(
      code: 'VALIDATION',
      params: {'field': 'email'},
      retryable: false,
      action: ApiAction.none,
    );
    return (null, noteFrom(errorCopy(local)), AuraTone.down);
  }
  if (problem == null) return (null, null, AuraTone.neutral);
  if (problem.code == ApiError.appOffline) {
    return (
      BannerModel(
        tone: AuraBannerTone.offline,
        title: signInOffline.title,
        body: signInOffline.body,
        action: signInOffline.action,
      ),
      null,
      AuraTone.neutral,
    );
  }
  final copy = errorCopy(problem);
  if (_codeIsDead(problem)) {
    return (
      BannerModel(
        tone: AuraBannerTone.warn,
        title: copy.title,
        body: copy.body,
      ),
      null,
      AuraTone.neutral,
    );
  }
  return switch (problem.errorCode) {
    ErrorCode.loginCodeInvalid ||
    ErrorCode.validation => (null, noteFrom(copy), AuraTone.down),
    ErrorCode.rateLimited => (null, noteFrom(copy), AuraTone.warn),
    _ => (
      BannerModel(
        tone: AuraBannerTone.down,
        title: copy.title,
        body: [?copy.body, ?copy.reference].join(' '),
        action: copy.action,
      ),
      null,
      AuraTone.neutral,
    ),
  };
}
