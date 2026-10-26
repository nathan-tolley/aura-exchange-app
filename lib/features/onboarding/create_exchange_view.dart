import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../design/icons.dart';
import '../../design/tokens.dart';
import '../../design/widgets/aura_button.dart';
import '../../design/widgets/aura_nav_card.dart';
import '../../design/widgets/aura_section_header.dart';
import '../../design/widgets/aura_sheet.dart';
import '../../design/widgets/aura_skeleton.dart';
import '../../design/widgets/aura_stat_card.dart';
import '../../design/widgets/aura_text_field.dart';
import '../../design/widgets/aura_toast.dart';
import '../../l10n/strings.dart';
import 'create_exchange_model.dart';
import 'onboarding_scaffold.dart';

/// Create an exchange, step one (SCREENS.md #4): its name. You arrive here
/// when you're in no exchange yet, so the note says how to join one instead.
class CreateNameView extends StatelessWidget {
  const CreateNameView({
    super.key,
    required this.model,
    required this.name,
    this.onChanged,
    this.onContinue,
    this.autofocus = false,
  });

  final CreateNameModel model;
  final TextEditingController name;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onContinue;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final m = model;
    return OnboardingScaffold(
      title: createTitle,
      body: createBody,
      actions: [
        AuraButton(
          continueLabel,
          variant: AuraButtonVariant.primary,
          block: true,
          onPressed: m.canContinue ? onContinue : null,
        ),
      ],
      note: m.note,
      children: [
        AuraTextField(
          label: exchangeNameLabel,
          controller: name,
          placeholder: exchangeNamePlaceholder,
          note: m.fieldNote,
          noteTone: m.fieldNoteTone,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          inputFormatters: [LengthLimitingTextInputFormatter(40)],
          autofocus: autofocus,
          onChanged: onChanged,
          onSubmitted: m.canContinue ? (_) => onContinue?.call() : null,
        ),
      ],
    );
  }
}

/// Step two: the exchange's timezone, and what its hours start as. Create
/// exchange makes it, with you as its admin.
class CreateHoursView extends StatelessWidget {
  const CreateHoursView({
    super.key,
    required this.model,
    this.onBack,
    this.onZone,
    this.onCreate,
  });

  final CreateHoursModel model;
  final VoidCallback? onBack;
  final VoidCallback? onZone;

  /// Also the offline banner's Retry.
  final VoidCallback? onCreate;

  @override
  Widget build(BuildContext context) {
    final m = model;
    return OnboardingScaffold(
      onBack: onBack,
      title: whenItTradesTitle,
      body: whenItTradesBody,
      banner: m.banner,
      onBannerAction: onCreate,
      actions: [
        AuraButton(
          m.button,
          variant: AuraButtonVariant.primary,
          block: true,
          onPressed: m.canCreate ? onCreate : null,
        ),
      ],
      note: youllBeAdmin,
      children: [
        const AuraSectionHeader(timezoneLabel),
        const SizedBox(height: 4),
        AuraNavCard(
          children: [
            AuraNavRow(
              icon: AuraIcons.clock,
              title: m.zoneTitle,
              subtitle: m.zoneSubtitle,
              trailing: change,
              onTap: onZone,
            ),
          ],
        ),
        const SizedBox(height: 24),
        const AuraSectionHeader(tradingHoursLabel),
        const SizedBox(height: 8),
        Text(
          standardHours,
          style: AuraType.body.copyWith(
            height: 22 / 15,
            color: AuraColors.inkSecondary,
            fontFeatures: const [],
          ),
        ),
      ],
    );
  }
}

/// The timezone list, as a sheet over step two.
class ZoneSheet extends StatelessWidget {
  const ZoneSheet({
    super.key,
    required this.options,
    this.onPick,
    this.onClose,
  });

  final List<ZoneOption> options;
  final ValueChanged<String>? onPick;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    return AuraSheet(
      title: timezoneLabel,
      onClose: onClose,
      children: [
        ConstrainedBox(
          // The large detent: the list scrolls under the title.
          constraints: BoxConstraints(maxHeight: height * 0.62),
          child: SingleChildScrollView(
            child: AuraNavCard(
              children: [
                for (final o in options)
                  AuraNavRow(
                    title: o.title,
                    subtitle: o.subtitle,
                    trailing: o.selected ? selected : null,
                    onTap: onPick == null ? null : () => onPick!(o.iana),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Step three: the invite link, made as you arrive. Copy it into the group
/// chat; Continue shows who's listed so far.
class InviteView extends StatelessWidget {
  const InviteView({
    super.key,
    required this.model,
    required this.link,
    this.copied = false,
    this.onBack,
    this.onRetry,
    this.onCopy,
    this.onContinue,
  });

  final InviteModel model;

  /// Holds [InviteModel.link], so it can be selected.
  final TextEditingController link;

  /// Shows the "Link copied" toast.
  final bool copied;
  final VoidCallback? onBack;
  final VoidCallback? onRetry;
  final VoidCallback? onCopy;
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    final m = model;
    final code = m.code;
    final expires = m.expires;
    return Stack(
      children: [
        OnboardingScaffold(
          onBack: onBack,
          title: inviteTitle,
          body: m.body,
          banner: m.banner,
          onBannerAction: onRetry,
          actions: [
            AuraButton(
              copyLink,
              block: true,
              onPressed: m.link == null ? null : onCopy,
            ),
            AuraButton(
              continueLabel,
              variant: AuraButtonVariant.primary,
              block: true,
              onPressed: onContinue,
            ),
          ],
          note: m.copyNote,
          children: [
            if (m.loading) ...[
              const AuraSkeletonText(style: AuraType.footnote, width: 72),
              const SizedBox(height: 8),
              const AuraSkeleton(height: 48, radius: AuraRadius.md),
            ] else if (m.link != null)
              AuraTextField(
                label: inviteLinkLabel,
                controller: link,
                readOnly: true,
              ),
            if (code != null && expires != null) ...[
              const SizedBox(height: 24),
              AuraStatGrid(
                rowGap: 6,
                children: [
                  AuraStatCard(label: inviteCodeLabel, value: code),
                  AuraStatCard(label: inviteExpiresLabel, value: expires),
                ],
              ),
            ],
          ],
        ),
        if (copied)
          const Positioned(
            left: 16,
            right: 16,
            bottom: 128,
            child: AuraToast(message: linkCopied),
          ),
      ],
    );
  }
}

/// Step four: who's listed so far against what it takes to open, and the
/// next thing to do, which is to list yourself.
class WaitingView extends StatelessWidget {
  const WaitingView({
    super.key,
    required this.model,
    this.onInvite,
    this.onList,
  });

  /// Null while the exchange loads.
  final WaitingModel? model;
  final VoidCallback? onInvite;
  final VoidCallback? onList;

  @override
  Widget build(BuildContext context) {
    final m = model;
    return OnboardingScaffold(
      title: waitingTitle,
      body: m?.body,
      actions: [
        AuraButton(
          listYourself,
          variant: AuraButtonVariant.primary,
          block: true,
          onPressed: onList,
        ),
      ],
      note: youPickTickerNext,
      children: [
        if (m == null)
          const AuraSkeleton(height: 112)
        else
          AuraStatGrid(
            rowGap: 6,
            children: [
              AuraStatCard(label: statMembers, value: m.members),
              AuraStatCard(label: statListed, value: m.listed),
              AuraStatCard(label: statOpens, value: m.opens),
              AuraStatCard(label: statCloses, value: m.closes),
              AuraStatCard(label: timezoneLabel, value: m.zone, wide: true),
            ],
          ),
        const SizedBox(height: 24),
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
