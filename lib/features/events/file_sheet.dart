import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../api/client.dart';
import '../../api/errors.dart';
import '../../api/generated/export.dart' hide Freshness;
import '../../data/freshness.dart';
import '../../data/live_market.dart';
import '../../data/me.dart';
import '../../data/repositories.dart';
import '../../design/icons.dart';
import '../../design/tokens.dart';
import '../../design/widgets/aura_banner.dart';
import '../../design/widgets/aura_button.dart';
import '../../design/widgets/aura_nav_card.dart';
import '../../design/widgets/aura_search_field.dart';
import '../../design/widgets/aura_sheet.dart';
import '../../design/widgets/aura_stock_row.dart';
import '../../design/widgets/aura_text_field.dart';
import '../../format/ticker.dart';
import '../../format/time.dart';
import '../../l10n/strings.dart';
import '../../router.dart';
import '../onboarding/create_exchange_model.dart' show problemBanner;
import '../shared/banner_model.dart';

/// Someone an event can be about: a listing in the exchange.
@immutable
class FileSubject {
  const FileSubject({
    required this.id,
    required this.ticker,
    required this.name,
    this.isMe = false,
  });

  final String id;
  final String ticker;
  final String name;
  final bool isMe;
}

/// File an event (SCREENS.md #11), worded. [subject] null is the picker.
@immutable
class FileModel {
  const FileModel({
    required this.subjects,
    required this.canFile,
    required this.button,
    this.subject,
    this.banner,
    this.note,
    this.discarding = false,
  });

  final List<FileSubject> subjects;
  final FileSubject? subject;
  final BannerModel? banner;
  final bool canFile;

  /// "File", "Filing…".
  final String button;

  /// Who'll know it was you, or why File is off.
  final String? note;

  /// Asking "Discard this filing?".
  final bool discarding;
}

FileModel fileModel({
  required List<FileSubject> subjects,
  required FileSubject? subject,
  required bool hasText,
  required bool filing,
  required ApiError? problem,
  bool discarding = false,
  ErrorContext context = const ErrorContext(),
}) {
  final limit = problem?.errorCode == ErrorCode.dailyFilingLimit;
  BannerModel? banner;
  if (limit) {
    final copy = errorCopy(problem!, context);
    banner = BannerModel(
      tone: AuraBannerTone.warn,
      title: copy.title,
      body: copy.body,
    );
  } else if (problem != null) {
    banner = problemBanner(problem, offline: fileOffline);
  } else if (subject?.isMe ?? false) {
    banner = const BannerModel(
      tone: AuraBannerTone.neutral,
      title: selfFilingTitle,
      body: selfFilingBody,
    );
  }
  return FileModel(
    subjects: subjects,
    subject: subject,
    banner: banner,
    canFile: hasText && !filing && !limit,
    button: filing ? filingLabel : fileIt,
    note: !hasText
        ? writeWhatHappened
        : subject == null || subject.isMe
        ? onlyModeratorsKnow
        : onlyTheyKnow(subject.name),
    discarding: discarding,
  );
}

/// The filing sheet's view: the subject picker, the compose step, or
/// "Discard this filing?".
class FileSheetView extends StatelessWidget {
  const FileSheetView({
    super.key,
    required this.model,
    required this.text,
    this.search,
    this.onSearch,
    this.onSubject,
    this.onChangeSubject,
    this.onText,
    this.onFile,
    this.onBannerAction,
    this.onClose,
    this.onKeepWriting,
    this.onDiscard,
  });

  final FileModel model;
  final TextEditingController text;
  final TextEditingController? search;
  final ValueChanged<String>? onSearch;
  final ValueChanged<FileSubject>? onSubject;
  final VoidCallback? onChangeSubject;
  final ValueChanged<String>? onText;
  final VoidCallback? onFile;
  final VoidCallback? onBannerAction;
  final VoidCallback? onClose;
  final VoidCallback? onKeepWriting;
  final VoidCallback? onDiscard;

  @override
  Widget build(BuildContext context) {
    final m = model;
    if (m.discarding) {
      return AuraSheet(
        title: discardTitle,
        onClose: onKeepWriting,
        children: [
          Text(
            discardBody,
            style: AuraType.body.copyWith(color: AuraColors.inkSecondary),
          ),
          AuraButton(
            keepWriting,
            variant: AuraButtonVariant.primary,
            block: true,
            onPressed: onKeepWriting,
          ),
          AuraButton(
            discard,
            variant: AuraButtonVariant.ghost,
            size: AuraButtonSize.md,
            block: true,
            onPressed: onDiscard,
          ),
        ],
      );
    }
    final subject = m.subject;
    final height = MediaQuery.sizeOf(context).height;
    if (subject == null) {
      return AuraSheet(
        title: whoIsItAbout,
        onClose: onClose,
        children: [
          AuraSearchField(
            placeholder: searchPeople,
            controller: search,
            onChanged: onSearch,
          ),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: height * 0.6),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  for (final s in m.subjects)
                    AuraStockRow(
                      ticker: s.ticker,
                      name: s.isMe ? '${s.name} · $tagYou' : s.name,
                      onTap: onSubject == null ? null : () => onSubject!(s),
                    ),
                ],
              ),
            ),
          ),
        ],
      );
    }
    final note = m.note;
    return AuraSheet(
      title: fileAnEvent,
      onClose: onClose,
      children: [
        AuraNavCard(
          children: [
            AuraNavRow(
              icon: AuraIcons.you,
              title: subject.ticker,
              subtitle: subject.name,
              trailing: change,
              onTap: onChangeSubject,
            ),
          ],
        ),
        if (m.banner case final banner?)
          ModelBanner(banner, onAction: onBannerAction),
        AuraTextField(
          label: whatHappened,
          controller: text,
          placeholder: whatHappenedPlaceholder,
          minLines: 4,
          maxLines: 8,
          textCapitalization: TextCapitalization.sentences,
          inputFormatters: [LengthLimitingTextInputFormatter(800)],
          onChanged: onText,
        ),
        AuraButton(
          m.button,
          variant: AuraButtonVariant.primary,
          block: true,
          onPressed: m.canFile ? onFile : null,
        ),
        if (note != null)
          Text(
            note,
            textAlign: TextAlign.center,
            style: AuraType.footnote.copyWith(color: AuraColors.inkTertiary),
          ),
      ],
    );
  }
}

/// The filing sheet (`/file?subject=`), large. Closing it with something
/// written asks first. Filing returns the new [Event], so the caller can
/// open its status (and the unsend window).
class FileSheet extends ConsumerStatefulWidget {
  const FileSheet({super.key, this.subjectId});

  final String? subjectId;

  @override
  ConsumerState<FileSheet> createState() => _FileSheetState();
}

class _FileSheetState extends ConsumerState<FileSheet> {
  final _text = TextEditingController();
  final _search = TextEditingController();
  late String? _subjectId = widget.subjectId;
  bool _filing = false;
  bool _discarding = false;
  ApiError? _problem;

  /// One per filing: Retry sends the same one; editing the text makes it a
  /// new filing.
  IdempotencyKey? _key;
  String? _keyFor;

  @override
  void dispose() {
    _text.dispose();
    _search.dispose();
    super.dispose();
  }

  Future<void> _file(String exchangeId) async {
    final body = _text.text.trim();
    final subject = _subjectId;
    if (subject == null || body.isEmpty) return;
    final keyFor = '$subject:$body';
    if (_keyFor != keyFor) {
      _key = IdempotencyKey();
      _keyFor = keyFor;
    }
    setState(() {
      _filing = true;
      _problem = null;
    });
    try {
      final event = await ref
          .read(eventsRepositoryProvider)
          .file(
            EventCreate(
              exchangeId: exchangeId,
              subjectListingId: subject,
              text: body,
            ),
            _key!,
          );
      if (mounted) Navigator.of(context).pop(event);
    } on ApiError catch (e) {
      if (mounted) {
        setState(() {
          _filing = false;
          _problem = e;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final exchangeId = ref.watch(currentExchangeIdProvider);
    final market = exchangeId == null
        ? null
        : ref.watch(marketProvider(exchangeId)).value;
    final q = _search.text.trim().toLowerCase();
    final subjects =
        [
          for (final l in market?.listings ?? const <LiveListing>[])
            FileSubject(
              id: l.id,
              ticker: formatTicker(l.summary.ticker),
              name: l.summary.displayName,
              isMe: l.summary.isMine,
            ),
        ].where(
          (s) => q.isEmpty || '${s.ticker} ${s.name}'.toLowerCase().contains(q),
        );
    final all = subjects.toList();
    final subject = (market?.listings ?? const <LiveListing>[])
        .where((l) => l.id == _subjectId)
        .map(
          (l) => FileSubject(
            id: l.id,
            ticker: formatTicker(l.summary.ticker),
            name: l.summary.displayName,
            isMe: l.summary.isMine,
          ),
        )
        .firstOrNull;
    final model = fileModel(
      subjects: all,
      subject: subject,
      hasText: _text.text.trim().isNotEmpty,
      filing: _filing,
      problem: _problem,
      discarding: _discarding,
      context: ErrorContext(
        zone: exchangeZone(
          exchangeId == null
              ? 'UTC'
              : ref.watch(exchangeProvider(exchangeId)).value?.timezone ??
                    'UTC',
        ),
        now: ref.watch(clockProvider),
      ),
    );
    return PopScope(
      // Half-filled: ask before it goes (COMPONENTS.md → Sheet).
      canPop: _text.text.trim().isEmpty || _filing,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _discarding = true);
      },
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: FileSheetView(
          model: model,
          text: _text,
          search: _search,
          onSearch: (_) => setState(() {}),
          onSubject: (s) => setState(() => _subjectId = s.id),
          onChangeSubject: () => setState(() => _subjectId = null),
          onText: (_) => setState(() => _problem = null),
          onFile: exchangeId == null ? null : () => _file(exchangeId),
          onBannerAction: exchangeId == null ? null : () => _file(exchangeId),
          onClose: () => Navigator.of(context).maybePop(),
          onKeepWriting: () => setState(() => _discarding = false),
          onDiscard: () {
            _text.clear();
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}

/// Opens the filing sheet and, once filed, the filing's status with its
/// unsend window.
Future<void> openFiling(BuildContext context, {String? subjectId}) async {
  final event = await context.push<Object?>(
    subjectId == null ? Routes.file : Routes.fileAbout(subjectId),
  );
  if (event is Event && context.mounted) {
    await context.push(Routes.event(event.id));
  }
}
