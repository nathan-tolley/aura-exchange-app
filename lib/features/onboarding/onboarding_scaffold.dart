import 'package:flutter/widgets.dart';

import '../../design/icons.dart';
import '../../design/text.dart';
import '../../design/tokens.dart';
import '../../design/widgets/aura_status_chip.dart';
import '../shared/action_bar.dart';
import '../shared/banner_model.dart';
import '../shared/top_bar.dart';

/// The layout every onboarding screen shares (sign-in, create an exchange,
/// join, your IPO), taken from the drawn full screens (W08, W13): the top
/// row, a large title that says what this step is, a line of body under it,
/// the banner when something's wrong, the step's own content, and its one
/// decision at the bottom where the tab bar would float.
class OnboardingScaffold extends StatelessWidget {
  const OnboardingScaffold({
    super.key,
    required this.title,
    required this.actions,
    this.body,
    this.banner,
    this.onBannerAction,
    this.children = const [],
    this.note,
    this.onBack,
    this.backIcon = AuraIcons.back,
    this.backLabel = 'Back',
    this.status,
    this.statusLabel,
  });

  /// "Sign in to Aura Exchange", "Check your email".
  final String title;
  final String? body;

  /// What's wrong right now (offline, expired, the exchange down).
  final BannerModel? banner;
  final VoidCallback? onBannerAction;
  final List<Widget> children;

  /// The bottom bar's buttons, usually one primary.
  final List<Widget> actions;

  /// Under the buttons: why one is disabled, or a footnote.
  final String? note;

  /// Back (or close); no glyph when null, as on the first screen.
  final VoidCallback? onBack;
  final AuraIcons backIcon;
  final String backLabel;
  final AuraStatus? status;
  final String? statusLabel;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final banner = this.banner;
    final body = this.body;
    return ColoredBox(
      color: AuraColors.bg,
      child: Stack(
        children: [
          ListView(
            padding: EdgeInsets.only(
              top: media.padding.top,
              // Clear the bottom bar, and the keyboard when it's up.
              bottom: 160 + media.viewInsets.bottom,
            ),
            children: [
              SizedBox(
                height: AuraSize.hit,
                child: onBack == null && status == null
                    ? null
                    : TopBar(
                        icon: backIcon,
                        label: backLabel,
                        onPressed: onBack,
                        status: status,
                        statusLabel: statusLabel,
                      ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(title, style: auraLargeTitle()),
                    ),
                    if (body != null) ...[
                      const SizedBox(height: 10),
                      // Prose: proportional figures, so Inter's tabular
                      // hyphen doesn't space out "6-digit".
                      Text(
                        body,
                        style: AuraType.body.copyWith(
                          height: 22 / 15,
                          color: AuraColors.inkSecondary,
                          fontFeatures: const [],
                        ),
                      ),
                    ],
                    if (banner != null) ...[
                      const SizedBox(height: 20),
                      ModelBanner(banner, onAction: onBannerAction),
                    ],
                    if (children.isNotEmpty) const SizedBox(height: 28),
                    ...children,
                  ],
                ),
              ),
            ],
          ),
          ActionBar(actions: actions, note: note),
        ],
      ),
    );
  }
}
