import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/client.dart';
import '../../api/errors.dart';
import '../../api/generated/models/error_code.dart';
import '../../data/repositories.dart';
import 'sign_in_model.dart';
import 'sign_in_view.dart';

/// Sign-in's state while the screen is up.
final signInProvider =
    NotifierProvider.autoDispose<SignInController, SignInState>(
      SignInController.new,
    );

/// Sends the code and checks it. Each user action gets one idempotency key,
/// reused when the offline banner's Retry repeats that same action: a new
/// address, a new code typed or "Send a new code" is a new action with a new
/// key (the server replays a stored answer for a repeated key and body).
/// Success signs in through the session, and the router moves on by itself.
class SignInController extends Notifier<SignInState> {
  IdempotencyKey? _sendKey;
  String? _sendKeyEmail;
  IdempotencyKey? _verifyKey;
  String? _verifyCode;
  _Last _last = _Last.send;

  @override
  SignInState build() => const SignInState();

  static final _address = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  /// Step one: email a code to [email].
  Future<void> send(String email) async {
    final address = email.trim();
    if (!_address.hasMatch(address)) {
      state = state.copyWith(emailInvalid: true, problem: () => null);
      return;
    }
    if (_sendKeyEmail != address) {
      _sendKey = IdempotencyKey();
      _sendKeyEmail = address;
    }
    await _send(address, resent: false);
  }

  /// "Send a new code": a new action, so a new key.
  Future<void> resend() async {
    _sendKey = IdempotencyKey();
    _sendKeyEmail = state.email;
    await _send(state.email, resent: true);
  }

  Future<void> _send(String email, {required bool resent}) async {
    _last = _Last.send;
    state = state.copyWith(
      busy: SignInBusy.sending,
      problem: () => null,
      emailInvalid: false,
    );
    try {
      await ref.read(authRepositoryProvider).sendCode(email, _sendKey!);
      if (!ref.mounted) return;
      // The next send to this address is a new action.
      _sendKeyEmail = null;
      state = state.copyWith(
        step: SignInStep.code,
        email: email,
        busy: SignInBusy.none,
        resent: resent,
      );
    } on ApiError catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(busy: SignInBusy.none, problem: () => e);
    }
  }

  /// Step two: check [code]. Signs in on success.
  Future<void> verify(String code) async {
    if (state.busy != SignInBusy.none) return;
    if (_verifyCode != code) {
      _verifyKey = IdempotencyKey();
      _verifyCode = code;
    }
    _last = _Last.verify;
    state = state.copyWith(busy: SignInBusy.verifying, problem: () => null);
    try {
      await ref
          .read(authRepositoryProvider)
          .verifyCode(state.email, code, _verifyKey!);
      if (!ref.mounted) return;
      state = state.copyWith(busy: SignInBusy.none);
    } on ApiError catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(busy: SignInBusy.none, problem: () => e);
    }
  }

  /// The offline banner's Retry: the same action again, with the same key.
  Future<void> retry() async {
    if (_last == _Last.verify && _verifyCode != null) {
      return verify(_verifyCode!);
    }
    if (state.step == SignInStep.code) {
      return _send(state.email, resent: true);
    }
  }

  /// Back to step one, keeping the address typed.
  void editEmail() => state = SignInState(email: state.email);
}

enum _Last { send, verify }

/// Sign in (SCREENS.md #1): the email step, then the code step, on one route.
/// Back on the code step returns to the email with the address kept.
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _email = TextEditingController();
  final _code = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(signInProvider);
    final controller = ref.read(signInProvider.notifier);
    // A wrong or dead code empties the cells for the next one.
    ref.listen(signInProvider, (previous, next) {
      final code = next.problem?.errorCode;
      if (code == ErrorCode.loginCodeInvalid ||
          code == ErrorCode.loginCodeExpired) {
        _code.clear();
      }
      if (previous?.step == SignInStep.email && next.step == SignInStep.code) {
        _code.clear();
      }
    });
    return switch (state.step) {
      SignInStep.email => SignInEmailView(
        model: signInEmailModel(state, hasEmail: _email.text.isNotEmpty),
        email: _email,
        autofocus: true,
        onChanged: (_) => setState(() {}),
        // Also the offline banner's Retry: the same address reuses its key.
        onSend: () => controller.send(_email.text),
      ),
      SignInStep.code => SignInCodeView(
        model: signInCodeModel(state, digits: _code.text.length),
        code: _code,
        autofocus: true,
        onChanged: (_) => setState(() {}),
        onVerify: () => controller.verify(_code.text),
        onResend: () {
          _code.clear();
          controller.resend();
        },
        onRetry: controller.retry,
        onBack: () {
          _email.text = state.email;
          controller.editEmail();
        },
      ),
    };
  }
}
