import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../design/icons.dart';
import '../../design/tokens.dart';
import '../../design/widgets/aura_button.dart';
import '../../design/widgets/aura_nav_card.dart';
import '../../design/widgets/aura_section_header.dart';
import '../../design/widgets/aura_skeleton.dart';
import '../../design/widgets/aura_stat_card.dart';
import '../../design/widgets/aura_text_field.dart';
import '../../l10n/strings.dart';
import 'ipo_model.dart';
import 'onboarding_scaffold.dart';

/// Your IPO, step one (SCREENS.md #3): what listing means, laid out like
/// W04's terms ("If you file"), before you choose to.
class IpoConsentView extends StatelessWidget {
  const IpoConsentView({
    super.key,
    required this.exchangeName,
    this.onContinue,
  });

  /// Null while the exchange loads.
  final String? exchangeName;
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    final name = exchangeName;
    return OnboardingScaffold(
      title: ipoTitle,
      body: name == null ? null : ipoBody(name),
      actions: [
        AuraButton(
          chooseTicker,
          variant: AuraButtonVariant.primary,
          block: true,
          onPressed: onContinue,
        ),
      ],
      note: theAnalystRoastsEvents,
      children: [
        if (name == null) ...[
          const AuraSkeletonText(style: AuraType.body, lines: 2),
          const SizedBox(height: 20),
        ],
        const AuraSectionHeader(ifYouList),
        const AuraStatGrid(
          rowGap: 6,
          children: [
            AuraStatCard(label: whoTradesYou, value: everyoneButYou),
            AuraStatCard(label: whatMovesYou, value: whatTheGroupFiles),
            AuraStatCard(
              label: changingYourMind,
              value: optOutInSettings,
              wide: true,
            ),
          ],
        ),
      ],
    );
  }
}

/// Step two: the ticker, checked as you type. Listing is the consent, so the
/// button says what it does ("List me as $NATE") and the note says so.
class IpoTickerView extends StatelessWidget {
  const IpoTickerView({
    super.key,
    required this.model,
    required this.ticker,
    this.onChanged,
    this.onSuggestion,
    this.onList,
    this.onBack,
    this.placeholder = tickerPlaceholder,
    this.autofocus = false,
  });

  final IpoTickerModel model;

  /// Your name as a ticker would start it: "NATE".
  final String placeholder;
  final TextEditingController ticker;
  final ValueChanged<String>? onChanged;

  /// A suggested ticker, without `$`.
  final ValueChanged<String>? onSuggestion;

  /// Also the offline banner's Retry.
  final VoidCallback? onList;
  final VoidCallback? onBack;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final m = model;
    return OnboardingScaffold(
      onBack: onBack,
      title: pickTickerTitle,
      body: pickTickerBody,
      banner: m.banner,
      onBannerAction: onList,
      actions: [
        AuraButton(
          m.button,
          variant: AuraButtonVariant.primary,
          block: true,
          onPressed: m.canList ? onList : null,
        ),
      ],
      note: m.note,
      children: [
        AuraTextField(
          label: tickerLabel,
          controller: ticker,
          prefix: r'$',
          placeholder: placeholder,
          note: m.fieldNote,
          noteTone: m.fieldNoteTone,
          textCapitalization: TextCapitalization.characters,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp('[A-Za-z]')),
            LengthLimitingTextInputFormatter(5),
            _Upper(),
          ],
          autofocus: autofocus,
          onChanged: onChanged,
        ),
        if (m.suggestions.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final (label, value) in m.suggestions)
                AuraButton(
                  label,
                  variant: AuraButtonVariant.ghost,
                  size: AuraButtonSize.md,
                  onPressed: onSuggestion == null
                      ? null
                      : () => onSuggestion!(value),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _Upper extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) => newValue.copyWith(text: newValue.text.toUpperCase());
}

/// Step three: listed. Who else is, and the way into the exchange.
class IpoListedView extends StatelessWidget {
  const IpoListedView({
    super.key,
    required this.model,
    this.onInvite,
    this.onOpen,
  });

  final IpoListedModel model;
  final VoidCallback? onInvite;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final m = model;
    return OnboardingScaffold(
      title: m.title,
      body: m.body.isEmpty ? null : m.body,
      actions: [
        AuraButton(
          openTheExchange,
          variant: AuraButtonVariant.primary,
          block: true,
          onPressed: onOpen,
        ),
      ],
      children: [
        AuraNavCard(
          children: [
            AuraNavRow(
              icon: AuraIcons.plus,
              title: inviteSomeone,
              subtitle: inviteSomeoneNote,
              onTap: onInvite,
            ),
          ],
        ),
      ],
    );
  }
}
