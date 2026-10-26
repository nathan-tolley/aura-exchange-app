import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/errors.dart';
import '../../data/freshness.dart';
import '../../format/time.dart';
import 'exchange_down_model.dart';
import 'exchange_down_view.dart';
import 'problem_view.dart';

/// A screen whose first load failed, so there's nothing older to show: W13
/// when the exchange is down, otherwise the problem screen (offline, update
/// required, anything else). A refetch that fails after numbers were shown
/// doesn't come here; the screen keeps them and stamps them (W11).
class LoadFailureView extends ConsumerWidget {
  const LoadFailureView({super.key, required this.error, this.onRetry});

  /// Anything a provider threw; not an `ApiError` reads as unexpected.
  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final e = error is ApiError
        ? error as ApiError
        : const ApiError.unexpected();
    if (isExchangeDown(e)) {
      return ExchangeDownView(
        model: exchangeDownModel(
          error: e,
          lastGood: null,
          zone: exchangeZone('UTC'),
          now: ref.read(clockProvider),
        ),
        onRetry: onRetry,
      );
    }
    return ProblemView(model: problemModel(e), onAction: onRetry);
  }
}

/// The first failure among [values] that have no value yet, or null.
Object? firstFailure(Iterable<AsyncValue<Object?>> values) => values
    .where((v) => !v.hasValue && !v.isLoading)
    .map((v) => v.error)
    .nonNulls
    .firstOrNull;
