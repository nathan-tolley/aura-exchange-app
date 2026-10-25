import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../design/widgets/aura_button.dart';
import '../../design/widgets/aura_code_field.dart';
import '../../design/widgets/aura_text_field.dart';
import '../../l10n/strings.dart';
import 'onboarding_scaffold.dart';
import 'sign_in_model.dart';

/// Sign in, step one (SCREENS.md #1): your email, and Send code.
class SignInEmailView extends StatelessWidget {
  const SignInEmailView({
    super.key,
    required this.model,
    required this.email,
    this.onChanged,
    this.onSend,
    this.autofocus = false,
  });

  final SignInEmailModel model;
  final TextEditingController email;
  final ValueChanged<String>? onChanged;

  /// Also the offline banner's Retry: it sends the same request again.
  final VoidCallback? onSend;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final m = model;
    return OnboardingScaffold(
      title: signInTitle,
      body: signInBody,
      banner: m.banner,
      onBannerAction: onSend,
      actions: [
        AuraButton(
          m.button,
          variant: AuraButtonVariant.primary,
          block: true,
          onPressed: m.canSend ? onSend : null,
        ),
      ],
      note: m.note,
      children: [
        AuraTextField(
          label: emailLabel,
          controller: email,
          placeholder: emailPlaceholder,
          note: m.fieldNote,
          noteTone: m.fieldNoteTone,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.send,
          autofillHints: const [AutofillHints.email],
          autofocus: autofocus,
          onChanged: onChanged,
          onSubmitted: m.canSend ? (_) => onSend?.call() : null,
        ),
      ],
    );
  }
}

/// Sign in, step two: the code from the email. It signs in as soon as the
/// sixth digit lands; Sign in is there for a code that was typed and then
/// corrected.
class SignInCodeView extends StatelessWidget {
  const SignInCodeView({
    super.key,
    required this.model,
    required this.code,
    this.onChanged,
    this.onVerify,
    this.onResend,
    this.onRetry,
    this.onBack,
    this.autofocus = false,
  });

  final SignInCodeModel model;
  final TextEditingController code;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onVerify;
  final VoidCallback? onResend;

  /// The offline banner's Retry: repeats whatever failed.
  final VoidCallback? onRetry;

  /// Back to the email step.
  final VoidCallback? onBack;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final m = model;
    return OnboardingScaffold(
      onBack: onBack,
      backLabel: useDifferentEmail,
      title: checkYourEmail,
      body: m.body,
      banner: m.banner,
      onBannerAction: onRetry,
      actions: [
        AuraButton(
          m.button,
          variant: AuraButtonVariant.primary,
          block: true,
          onPressed: m.canSignIn ? onVerify : null,
        ),
      ],
      note: m.note,
      children: [
        AuraCodeField(
          controller: code,
          note: m.codeNote,
          noteTone: m.codeNoteTone,
          enabled: m.codeEnabled,
          autofocus: autofocus,
          onChanged: onChanged,
          onCompleted: (_) => onVerify?.call(),
        ),
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.centerLeft,
          child: AuraButton(
            sendNewCode,
            variant: AuraButtonVariant.ghost,
            size: AuraButtonSize.md,
            onPressed: m.canResend ? onResend : null,
          ),
        ),
      ],
    );
  }
}
