import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/generated/export.dart';
import 'lifecycle.dart';
import 'repositories.dart';

/// One stock page (`GET /listings/{id}`): its stats, events, halt and the
/// Analyst's note. Its price moves with the exchange's ticks, which the page
/// reads from the live market; this refetches on resume.
final listingProvider = FutureProvider.autoDispose
    .family<ListingDetail, String>((ref, listingId) {
      ref.watch(refetchSignalProvider);
      return ref.read(marketRepositoryProvider).listing(listingId);
    });

/// A stock's chart for one range, with its ruling markers.
final candlesProvider = FutureProvider.autoDispose
    .family<CandleSeries, (String, Range)>((ref, key) {
      ref.watch(refetchSignalProvider);
      final (listingId, range) = key;
      return ref.read(marketRepositoryProvider).candles(listingId, range);
    });

/// A stock's own tape, newest first.
final listingTapeProvider = FutureProvider.autoDispose
    .family<List<TapeItem>, (String, String)>((ref, key) async {
      ref.watch(refetchSignalProvider);
      final (exchangeId, listingId) = key;
      final page = await ref
          .read(tapeRepositoryProvider)
          .tape(exchangeId, listingId: listingId);
      return page.items;
    });
