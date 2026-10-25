import 'package:flutter/foundation.dart';

import '../../api/errors.dart';
import '../../api/generated/export.dart';
import '../../design/tone.dart';
import '../../format/ticker.dart';
import '../../l10n/strings.dart';
import '../shared/banner_model.dart';
import 'create_exchange_model.dart';

/// Where your IPO is (SCREENS.md #3): what listing means, the ticker and
/// whether it's free, and the listing itself.
@immutable
class IpoState {
  const IpoState({
    this.step = IpoStep.consent,
    this.ticker = '',
    this.check = TickerCheckState.none,
    this.suggestions = const [],
    this.listing = false,
    this.problem,
    this.listed,
  });

  final IpoStep step;

  /// Letters only, uppercase, without `$`.
  final String ticker;
  final TickerCheckState check;

  /// From the server when [ticker] is taken: `$NTE`.
  final List<String> suggestions;
  final bool listing;

  /// Why listing failed.
  final ApiError? problem;

  /// You, once listed.
  final ListingRef? listed;

  IpoState copyWith({
    IpoStep? step,
    String? ticker,
    TickerCheckState? check,
    List<String>? suggestions,
    bool? listing,
    ApiError? Function()? problem,
    ListingRef? listed,
  }) => IpoState(
    step: step ?? this.step,
    ticker: ticker ?? this.ticker,
    check: check ?? this.check,
    suggestions: suggestions ?? this.suggestions,
    listing: listing ?? this.listing,
    problem: problem == null ? this.problem : problem(),
    listed: listed ?? this.listed,
  );
}

enum IpoStep { consent, ticker, listed }

enum TickerCheckState {
  /// Too short to check.
  none,
  checking,
  free,
  taken,

  /// The check couldn't reach the server.
  offline,
}

/// The ticker step, worded.
@immutable
class IpoTickerModel {
  const IpoTickerModel({
    required this.fieldNote,
    required this.button,
    required this.canList,
    this.fieldNoteTone = AuraTone.neutral,
    this.suggestions = const [],
    this.banner,
    this.note,
  });

  final String fieldNote;
  final AuraTone fieldNoteTone;

  /// "Use $NTE" buttons when it's taken: (label, ticker without `$`).
  final List<(String, String)> suggestions;
  final BannerModel? banner;

  /// "List me as $NATE", or "Listing…".
  final String button;
  final bool canList;

  /// Why the button is off, or what pressing it means.
  final String? note;
}

IpoTickerModel ipoTickerModel(IpoState s) {
  final shown = s.ticker.isEmpty ? '' : formatTicker(s.ticker);
  final (note, tone) = switch (s.check) {
    TickerCheckState.none => (tickerLength, AuraTone.neutral),
    TickerCheckState.checking => (tickerChecking(shown), AuraTone.neutral),
    TickerCheckState.free => (tickerFree(shown), AuraTone.neutral),
    TickerCheckState.taken => (tickerTaken(shown), AuraTone.down),
    TickerCheckState.offline => (tickerCantCheck, AuraTone.warn),
  };
  final free = s.check == TickerCheckState.free;
  return IpoTickerModel(
    fieldNote: note,
    fieldNoteTone: tone,
    suggestions: s.check == TickerCheckState.taken
        ? [
            for (final t in s.suggestions.take(3))
              (useTicker(formatTicker(t)), t.replaceAll(r'$', '')),
          ]
        : const [],
    banner: problemBanner(
      // Taken is shown at the field, not as a banner.
      s.problem?.errorCode == ErrorCode.tickerTaken ? null : s.problem,
      offline: ipoOffline,
    ),
    button: s.listing
        ? listing
        : free
        ? listMeAs(shown)
        : listMe,
    canList: free && !s.listing,
    note: free || s.listing ? yourConsent : pickFreeTicker,
  );
}

/// The listed step, worded, once the exchange has been refetched.
@immutable
class IpoListedModel {
  const IpoListedModel({required this.title, required this.body});

  final String title;
  final String body;
}

IpoListedModel ipoListedModel(ListingRef listing, Exchange? exchange) =>
    IpoListedModel(
      title: listedTitle(formatTicker(listing.ticker)),
      body: exchange == null
          ? ''
          : listedBody(exchange.listedCount, exchange.minListingsToOpen),
    );
