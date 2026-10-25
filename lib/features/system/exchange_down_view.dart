import 'package:flutter/widgets.dart';

import '../../design/icons.dart';
import '../../design/text.dart';
import '../../design/tokens.dart';
import '../../design/tone.dart';
import '../../design/widgets/aura_button.dart';
import '../../design/widgets/aura_icon_tile.dart';
import '../../design/widgets/aura_quote_card.dart';
import '../../design/widgets/aura_receipt.dart';
import '../shared/action_bar.dart';

/// The exchange is down (W13, SCREENS.md #24): a calm explanation, what's
/// safe, the last good state as a receipt, the tape line for when it's
/// back, and Try again with the reference under it.
@immutable
class ExchangeDownModel {
  const ExchangeDownModel({
    required this.title,
    required this.body,
    required this.rows,
    required this.tapeLabel,
    required this.tape,
    required this.retry,
    required this.footnote,
  });

  final String title;
  final String body;
  final List<AuraReceiptRow> rows;
  final String tapeLabel;
  final String tape;
  final String retry;
  final String footnote;
}

class ExchangeDownView extends StatelessWidget {
  const ExchangeDownView({super.key, required this.model, this.onRetry});

  final ExchangeDownModel model;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final m = model;
    final top = MediaQuery.paddingOf(context).top;
    return ColoredBox(
      color: AuraColors.bg,
      child: Stack(
        children: [
          ListView(
            padding: EdgeInsets.fromLTRB(16, top + 92, 16, 160),
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: AuraIconTile(
                  AuraIcons.alert,
                  size: 52,
                  tone: AuraTone.warn,
                ),
              ),
              const SizedBox(height: 20.5),
              Text(m.title, style: auraDisplayTitle(AuraType.alertTitle)),
              const SizedBox(height: 10),
              Text(
                m.body,
                style: AuraType.body.copyWith(
                  height: 22 / 15,
                  color: AuraColors.inkSecondary,
                ),
              ),
              const SizedBox(height: 28),
              AuraReceipt(rows: m.rows),
              const SizedBox(height: 28),
              auraLiftFootnote(
                Text(
                  m.tapeLabel,
                  style: AuraType.footnote.copyWith(
                    color: AuraColors.inkTertiary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              AuraQuoteCard(quote: m.tape),
            ],
          ),
          ActionBar(
            bottom: 35,
            actions: [
              AuraButton(
                m.retry,
                variant: AuraButtonVariant.primary,
                block: true,
                onPressed: onRetry,
              ),
            ],
            note: m.footnote,
          ),
        ],
      ),
    );
  }
}
