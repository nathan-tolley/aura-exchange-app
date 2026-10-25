import 'package:flutter/widgets.dart';

import '../tokens.dart';

/// The Analyst speaking: notes, Fed statements and company profiles, in the
/// serif at `quote` size in `inkSecondary`, with its source under it. No box,
/// no quote bar, no italics. The text comes from the server as-is (curly
/// quotes included); nothing else in the app uses the serif.
class AuraQuoteCard extends StatelessWidget {
  const AuraQuoteCard({super.key, required this.quote, this.source});

  final String quote;

  /// "The Analyst · Downgrade · target A$96.00".
  final String? source;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Text(
          quote,
          style: AuraType.quote.copyWith(color: AuraColors.inkSecondary),
        ),
        if (source != null)
          Text(
            source!,
            style: AuraType.footnote.copyWith(color: AuraColors.inkTertiary),
          ),
      ],
    );
  }
}
