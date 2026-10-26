import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/client.dart';
import '../../api/errors.dart';
import '../../data/freshness.dart';
import '../../data/me.dart';
import '../../data/repositories.dart';
import '../../design/tokens.dart';
import '../../format/time.dart';
import 'exchange_down_model.dart';
import 'exchange_down_view.dart';
import 'problem_view.dart';

/// What shows while the app finds out who you are (`/boot`): the plain
/// background while the Keychain and `/me` answer, as a launch screen would,
/// and a designed screen if `/me` fails: W13 when the exchange is down, the
/// problem screen otherwise (offline, update required, anything else).
class BootScreen extends ConsumerWidget {
  const BootScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(meProvider);
    final failure = me.error;
    if (failure == null) {
      return const ColoredBox(color: AuraColors.bg, child: SizedBox.expand());
    }
    final error = failure is ApiError ? failure : const ApiError.unexpected();
    void retry() => ref.invalidate(meProvider);
    if (isExchangeDown(error)) {
      return ExchangeDownView(
        model: exchangeDownModel(
          error: error,
          lastGood: null,
          zone: exchangeZone('UTC'),
          now: ref.read(clockProvider),
        ),
        onRetry: retry,
      );
    }
    return ProblemView(
      model: problemModel(error),
      onAction: retry,
      onSecondary: () =>
          ref.read(authRepositoryProvider).signOut(IdempotencyKey()),
    );
  }
}
