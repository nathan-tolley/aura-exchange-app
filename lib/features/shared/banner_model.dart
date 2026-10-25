import 'package:flutter/widgets.dart';

import '../../design/widgets/aura_banner.dart';

/// A banner as a screen shows it: copy already built (usually by
/// `errorCopy`), tone chosen.
@immutable
class BannerModel {
  const BannerModel({
    required this.tone,
    required this.title,
    this.body,
    this.action,
  });

  final AuraBannerTone tone;
  final String title;
  final String? body;

  /// "Buy 18", "Retry".
  final String? action;
}

/// [model] drawn as an `AuraBanner`.
class ModelBanner extends StatelessWidget {
  const ModelBanner(this.model, {super.key, this.onAction});

  final BannerModel model;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => AuraBanner(
    tone: model.tone,
    title: model.title,
    body: model.body,
    action: model.action,
    onAction: model.action == null ? null : onAction,
  );
}
