import 'package:flutter/widgets.dart';

import '../../../api/errors.dart';
import '../../../features/onboarding/sign_in_model.dart';
import '../../../features/onboarding/sign_in_view.dart';

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

/// Text controllers for a fixture, made and disposed with it.
class Controlled extends StatefulWidget {
  const Controlled({super.key, required this.texts, required this.builder});

  final List<String> texts;
  final Widget Function(BuildContext, List<TextEditingController>) builder;

  @override
  State<Controlled> createState() => _ControlledState();
}

class _ControlledState extends State<Controlled> {
  late final _controllers = [
    for (final t in widget.texts) TextEditingController(text: t),
  ];

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _controllers);
}

void _noop() {}
