import 'package:flutter/widgets.dart';

import '../../api/errors.dart';
import '../../api/generated/models/error_code.dart';
import '../../design/icons.dart';
import '../../design/text.dart';
import '../../design/tokens.dart';
import '../../design/tone.dart';
import '../../design/widgets/aura_button.dart';
import '../../design/widgets/aura_icon_tile.dart';
import '../../l10n/strings.dart';
import '../shared/action_bar.dart';

/// A screen that is itself the message, when nothing else can be shown:
/// offline before anything loaded, a build the exchange no longer accepts,
/// or a failure the app has no words for. W13's pattern without its receipt
/// and tape line (SCREENS.md #24): the glyph, the title, what it means, and
/// the one thing to do, with the reference under it.
@immutable
class ProblemModel {
  const ProblemModel({
    required this.icon,
    required this.title,
    required this.body,
    required this.action,
    this.tone = AuraTone.warn,
    this.secondary,
    this.footnote,
  });

  final AuraIcons icon;
  final AuraTone tone;
  final String title;
  final String body;

  /// "Try again", "Check again".
  final String action;

  /// "Sign out", for a failure that might be this account's.
  final String? secondary;

  /// The reference, or what to do outside the app.
  final String? footnote;
}

/// The problem screen for [error] (anything but the exchange being down,
/// which is W13).
ProblemModel problemModel(ApiError error) {
  if (error.code == ApiError.appOffline) {
    return const ProblemModel(
      icon: AuraIcons.wifiOff,
      title: offlineAtLaunchTitle,
      body: offlineAtLaunchBody,
      action: 'Try again',
    );
  }
  if (error.isNotServed) {
    return const ProblemModel(
      icon: AuraIcons.clock,
      tone: AuraTone.neutral,
      title: notLiveTitle,
      body: notLiveBody,
      action: 'Try again',
    );
  }
  final copy = errorCopy(error);
  if (error.errorCode == ErrorCode.updateRequired) {
    return ProblemModel(
      icon: AuraIcons.alert,
      title: copy.title,
      body: copy.body ?? '',
      action: checkAgain,
      footnote: updateFootnote,
    );
  }
  return ProblemModel(
    icon: AuraIcons.alert,
    title: copy.title,
    body: copy.body ?? somethingWentWrongBody,
    action: copy.action ?? 'Try again',
    secondary: signOut,
    footnote: copy.reference,
  );
}

class ProblemView extends StatelessWidget {
  const ProblemView({
    super.key,
    required this.model,
    this.onAction,
    this.onSecondary,
  });

  final ProblemModel model;
  final VoidCallback? onAction;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    final m = model;
    final top = MediaQuery.paddingOf(context).top;
    final secondary = m.secondary;
    return ColoredBox(
      color: AuraColors.bg,
      child: Stack(
        children: [
          // Set where W13 sets its message.
          ListView(
            padding: EdgeInsets.fromLTRB(16, top + 92, 16, 160),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: AuraIconTile(m.icon, size: 52, tone: m.tone),
              ),
              const SizedBox(height: 20.5),
              Semantics(
                header: true,
                child: Text(
                  m.title,
                  style: auraDisplayTitle(AuraType.alertTitle),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                m.body,
                style: AuraType.body.copyWith(
                  height: 22 / 15,
                  color: AuraColors.inkSecondary,
                  fontFeatures: const [],
                ),
              ),
            ],
          ),
          ActionBar(
            bottom: 35,
            actions: [
              if (secondary != null)
                AuraButton(secondary, block: true, onPressed: onSecondary),
              AuraButton(
                m.action,
                variant: AuraButtonVariant.primary,
                block: true,
                onPressed: onAction,
              ),
            ],
            note: m.footnote,
          ),
        ],
      ),
    );
  }
}
