import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../api/client.dart';
import '../../api/errors.dart';
import '../../api/generated/export.dart';
import '../../data/me.dart';
import '../../data/repositories.dart';
import '../../router.dart';
import '../../l10n/strings.dart';
import 'ipo_model.dart';
import 'ipo_view.dart';

/// Your IPO's state while the screen is up.
final ipoProvider = NotifierProvider.autoDispose<IpoController, IpoState>(
  IpoController.new,
);

/// Checks tickers as they're typed (after a short pause, and only the
/// latest), and lists you. One key per ticker: Retry after a failure sends
/// the same ticker with the same key; another ticker is a new action.
class IpoController extends Notifier<IpoState> {
  Timer? _debounce;
  IdempotencyKey? _key;
  String? _keyFor;

  static const _pause = Duration(milliseconds: 350);

  @override
  IpoState build() {
    ref.onDispose(() => _debounce?.cancel());
    return const IpoState();
  }

  String? get _exchangeId => ref.read(currentExchangeIdProvider);

  void toTicker() => state = state.copyWith(step: IpoStep.ticker);

  void back() =>
      state = state.copyWith(step: IpoStep.consent, problem: () => null);

  /// [ticker] as typed: letters, uppercase, no `$`.
  void type(String ticker) {
    _debounce?.cancel();
    final t = ticker.toUpperCase();
    if (t.length < 3) {
      state = state.copyWith(
        ticker: t,
        check: TickerCheckState.none,
        problem: () => null,
      );
      return;
    }
    state = state.copyWith(
      ticker: t,
      check: TickerCheckState.checking,
      problem: () => null,
    );
    _debounce = Timer(_pause, () => _check(t));
  }

  Future<void> _check(String ticker) async {
    final exchangeId = _exchangeId;
    if (exchangeId == null) return;
    try {
      final result = await ref
          .read(exchangesRepositoryProvider)
          .checkTicker(exchangeId, ticker);
      if (!ref.mounted || state.ticker != ticker) return;
      state = state.copyWith(
        check: result.available
            ? TickerCheckState.free
            : TickerCheckState.taken,
        suggestions: result.suggestions,
      );
    } on ApiError catch (e) {
      if (!ref.mounted || state.ticker != ticker) return;
      state = state.copyWith(
        check: e.code == ApiError.appOffline
            ? TickerCheckState.offline
            : TickerCheckState.none,
      );
    }
  }

  /// Lists you under the ticker, with your consent.
  Future<void> list() async {
    final exchangeId = _exchangeId;
    if (exchangeId == null || state.listing) return;
    final ticker = state.ticker;
    if (_keyFor != ticker) {
      _key = IdempotencyKey();
      _keyFor = ticker;
    }
    state = state.copyWith(listing: true, problem: () => null);
    try {
      final listed = await ref
          .read(exchangesRepositoryProvider)
          .list(exchangeId, ticker, _key!);
      if (!ref.mounted) return;
      state = state.copyWith(
        listing: false,
        listed: listed,
        step: IpoStep.listed,
      );
      ref.invalidate(exchangeProvider(exchangeId));
      await ref.read(meProvider.notifier).reload();
    } on ApiError catch (e) {
      if (!ref.mounted) return;
      final taken = e.errorCode == ErrorCode.tickerTaken;
      state = state.copyWith(
        listing: false,
        problem: () => e,
        check: taken ? TickerCheckState.taken : null,
        suggestions: taken ? const [] : null,
      );
    }
  }
}

/// Your IPO (SCREENS.md #3): consent, the ticker, listed. One route; back on
/// the ticker step returns to what listing means.
class IpoScreen extends ConsumerStatefulWidget {
  const IpoScreen({super.key});

  @override
  ConsumerState<IpoScreen> createState() => _IpoScreenState();
}

class _IpoScreenState extends ConsumerState<IpoScreen> {
  final _ticker = TextEditingController();

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ipoProvider);
    final controller = ref.read(ipoProvider.notifier);
    final exchangeId = ref.watch(currentExchangeIdProvider);
    final exchangeState = exchangeId == null
        ? null
        : ref.watch(exchangeProvider(exchangeId));
    final exchange = exchangeState?.value;
    final name = ref.watch(meProvider).value?.user.displayName ?? '';
    return switch (state.step) {
      IpoStep.consent => IpoConsentView(
        exchangeName: exchange?.name,
        loading: exchangeState?.isLoading ?? false,
        onContinue: controller.toTicker,
      ),
      IpoStep.ticker => IpoTickerView(
        model: ipoTickerModel(state),
        ticker: _ticker,
        placeholder: _placeholder(name),
        autofocus: true,
        onChanged: controller.type,
        onSuggestion: (t) {
          _ticker.text = t;
          controller.type(t);
        },
        onList: controller.list,
        onBack: controller.back,
      ),
      IpoStep.listed => IpoListedView(
        model: ipoListedModel(state.listed!, exchange),
        onInvite: () => context.push(Routes.createInvite),
        onOpen: () => context.go(Routes.home),
      ),
    };
  }
}

/// Your name's first four letters, as a ticker might start: "NATH".
String _placeholder(String name) {
  final letters = name.replaceAll(RegExp('[^A-Za-z]'), '').toUpperCase();
  return letters.length < 3
      ? tickerPlaceholder
      : letters.substring(0, letters.length.clamp(3, 4));
}
