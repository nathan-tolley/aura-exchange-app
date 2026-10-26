import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../api/client.dart';
import '../../api/errors.dart';
import '../../api/generated/export.dart';
import '../../data/me.dart';
import '../../data/repositories.dart';
import '../../router.dart';
import 'join_model.dart';
import 'join_view.dart';

/// What an invite leads to (`GET /invites/{code}`).
final invitePreviewProvider = FutureProvider.autoDispose
    .family<InvitePreview, String>(
      (ref, code) => ref.read(exchangesRepositoryProvider).previewInvite(code),
    );

/// Join from an invite (`/invite/:code`, from `aura://invite/CODE`). Signed
/// out, the redirect sends you through sign-in first and back here.
class JoinScreen extends ConsumerStatefulWidget {
  const JoinScreen({super.key, required this.code});

  final String code;

  @override
  ConsumerState<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends ConsumerState<JoinScreen> {
  bool _joining = false;
  ApiError? _joinError;

  /// One per visit: Retry after a failure joins with the same key.
  final _key = IdempotencyKey();

  Future<void> _join() async {
    setState(() {
      _joining = true;
      _joinError = null;
    });
    try {
      final membership = await ref
          .read(exchangesRepositoryProvider)
          .acceptInvite(widget.code, _key);
      ref.read(selectedExchangeProvider.notifier).select(membership.exchangeId);
      await ref.read(meProvider.notifier).reload();
      if (!mounted) return;
      context.go(membership.listing == null ? Routes.ipo : Routes.home);
    } on ApiError catch (e) {
      if (mounted) {
        setState(() {
          _joining = false;
          _joinError = e;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final preview = ref.watch(invitePreviewProvider(widget.code));
    final previewError = preview.isLoading ? null : preview.error;
    final model = joinModel(
      code: widget.code,
      preview: preview.value,
      previewError: previewError is ApiError ? previewError : null,
      joinError: _joinError,
      joining: _joining,
      inAnExchange: ref.watch(currentExchangeIdProvider) != null,
    );
    return JoinView(
      model: model,
      onAction: switch (model.kind) {
        JoinKind.loading => null,
        JoinKind.join => _join,
        JoinKind.startOwn => () => context.go(Routes.createExchange),
        JoinKind.openExchange => () => context.go(Routes.home),
      },
      onRetry: _joinError != null
          ? _join
          : () => ref.invalidate(invitePreviewProvider(widget.code)),
    );
  }
}
