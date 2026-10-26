import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../api/client.dart';
import '../../api/errors.dart';
import '../../api/generated/export.dart';
import '../../data/freshness.dart';
import '../../data/me.dart';
import '../../data/repositories.dart';
import '../../design/sheet_route.dart';
import '../../router.dart';
import 'create_exchange_model.dart';
import 'create_exchange_view.dart';

/// Creating an exchange: the name and timezone steps share one route and
/// this state.
final createExchangeProvider =
    NotifierProvider.autoDispose<CreateExchangeController, CreateExchangeState>(
      CreateExchangeController.new,
    );

/// Creates the exchange. One key per name-and-zone: Retry after a failure
/// sends the same body with the same key; a changed name or zone is a new
/// action. On success `/me` is reloaded, so the redirect knows you're in an
/// exchange now.
class CreateExchangeController extends Notifier<CreateExchangeState> {
  IdempotencyKey? _key;
  ExchangeCreate? _keyFor;

  @override
  CreateExchangeState build() =>
      CreateExchangeState(zone: guessZone(ref.read(clockProvider)));

  /// Step one's Continue: 2 to 40 characters, as the contract says.
  void toHours(String name) {
    final trimmed = name.trim();
    if (trimmed.length < 2 || trimmed.length > 40) {
      state = state.copyWith(nameInvalid: true);
      return;
    }
    state = state.copyWith(
      name: trimmed,
      step: CreateStep.hours,
      nameInvalid: false,
      problem: () => null,
    );
  }

  void back() =>
      state = state.copyWith(step: CreateStep.name, problem: () => null);

  void pickZone(String iana) => state = state.copyWith(zone: iana);

  /// Creates it; returns the new exchange, or null if it failed (the state
  /// says why).
  Future<Exchange?> create() async {
    if (state.creating) return null;
    final body = ExchangeCreate(name: state.name, timezone: state.zone);
    if (_keyFor?.name != body.name || _keyFor?.timezone != body.timezone) {
      _key = IdempotencyKey();
      _keyFor = body;
    }
    state = state.copyWith(creating: true, problem: () => null);
    try {
      final exchange = await ref
          .read(exchangesRepositoryProvider)
          .create(body, _key!);
      await ref.read(meProvider.notifier).reload();
      return exchange;
    } on ApiError catch (e) {
      if (ref.mounted) {
        final nameRejected =
            e.errorCode == ErrorCode.validation && e.params['field'] == 'name';
        state = state.copyWith(
          creating: false,
          problem: () => e,
          step: nameRejected ? CreateStep.name : null,
        );
      }
      return null;
    }
  }
}

/// Create an exchange (SCREENS.md #4), steps one and two.
class CreateExchangeScreen extends ConsumerStatefulWidget {
  const CreateExchangeScreen({super.key});

  @override
  ConsumerState<CreateExchangeScreen> createState() =>
      _CreateExchangeScreenState();
}

class _CreateExchangeScreenState extends ConsumerState<CreateExchangeScreen> {
  final _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final exchange = await ref.read(createExchangeProvider.notifier).create();
    if (exchange != null && mounted) context.go(Routes.createInvite);
  }

  void _pickZone(CreateExchangeState state) {
    final controller = ref.read(createExchangeProvider.notifier);
    Navigator.of(context).push(
      AuraSheetRoute<void>(
        builder: (sheet) => ZoneSheet(
          options: zoneOptions(state.zone, now: ref.read(clockProvider)),
          onClose: () => Navigator.of(sheet).pop(),
          onPick: (iana) {
            controller.pickZone(iana);
            Navigator.of(sheet).pop();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createExchangeProvider);
    final controller = ref.read(createExchangeProvider.notifier);
    return switch (state.step) {
      CreateStep.name => CreateNameView(
        model: createNameModel(state, hasName: _name.text.trim().isNotEmpty),
        name: _name,
        autofocus: true,
        onChanged: (_) => setState(() {}),
        onContinue: () => controller.toHours(_name.text),
      ),
      CreateStep.hours => CreateHoursView(
        model: createHoursModel(state, now: ref.watch(clockProvider)),
        onBack: controller.back,
        onZone: () => _pickZone(state),
        onCreate: _create,
      ),
    };
  }
}

/// Step three's link. Made once per visit with one key, so Retry after a
/// failure can't make a second link.
final _inviteKeyProvider = Provider.autoDispose.family<IdempotencyKey, String>(
  (ref, exchangeId) => IdempotencyKey(),
);

final inviteLinkProvider = FutureProvider.autoDispose.family<Invite, String>((
  ref,
  exchangeId,
) {
  final key = ref.watch(_inviteKeyProvider(exchangeId));
  return ref.read(exchangesRepositoryProvider).invite(exchangeId, key);
});

/// Step three (`/exchanges/new/invite`): the link for the exchange you're
/// showing, made as you arrive.
class InviteScreen extends ConsumerStatefulWidget {
  const InviteScreen({super.key});

  @override
  ConsumerState<InviteScreen> createState() => _InviteScreenState();
}

class _InviteScreenState extends ConsumerState<InviteScreen> {
  final _link = TextEditingController();
  Timer? _toast;

  @override
  void dispose() {
    _link.dispose();
    _toast?.cancel();
    super.dispose();
  }

  Future<void> _copy(String url) async {
    await Clipboard.setData(ClipboardData(text: url));
    unawaited(HapticFeedback.lightImpact());
    _toast?.cancel();
    setState(() {});
    _toast = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _toast = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final exchangeId = ref.watch(currentExchangeIdProvider);
    if (exchangeId == null) {
      return InviteView(
        model: inviteModel(
          exchange: null,
          invite: null,
          problem: null,
          now: ref.read(clockProvider),
        ),
        link: _link,
      );
    }
    final invite = ref.watch(inviteLinkProvider(exchangeId));
    final exchange = ref.watch(exchangeProvider(exchangeId)).value;
    final made = invite.value;
    if (made != null && _link.text != made.url) _link.text = made.url;
    final failure = invite.error;
    return InviteView(
      model: inviteModel(
        exchange: exchange,
        invite: made,
        problem: invite.isLoading
            ? null
            : failure is ApiError
            ? failure
            : null,
        now: ref.watch(clockProvider),
      ),
      link: _link,
      copied: _toast != null,
      onBack: context.canPop() ? context.pop : null,
      onRetry: () => ref.invalidate(inviteLinkProvider(exchangeId)),
      onCopy: made == null ? null : () => _copy(made.url),
      onContinue: () => context.go(Routes.createWaiting),
    );
  }
}

/// Step four (`/exchanges/new/waiting`): who's listed so far.
class WaitingScreen extends ConsumerWidget {
  const WaitingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exchangeId = ref.watch(currentExchangeIdProvider);
    final exchange = exchangeId == null
        ? null
        : ref.watch(exchangeProvider(exchangeId)).value;
    return WaitingView(
      model: exchange == null ? null : waitingModel(exchange),
      onInvite: () => context.push(Routes.createInvite),
      onList: () => context.go(Routes.ipo),
    );
  }
}
