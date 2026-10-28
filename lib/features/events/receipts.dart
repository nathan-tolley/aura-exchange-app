import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/client.dart';
import '../../api/errors.dart';
import '../../api/generated/export.dart' hide Freshness;
import '../../data/freshness.dart';
import '../../data/repositories.dart';
import '../../data/uploads.dart';
import '../../design/tone.dart';
import '../../design/widgets/aura_photo_tile.dart';
import '../../l10n/strings.dart';

/// The most receipts a filing can carry: `EventCreate.receiptIds` has
/// `maxItems: 4` in the contract.
const maxReceipts = 4;

/// A photo on its way to becoming one of a filing's receipts.
@immutable
class ReceiptDraft {
  const ReceiptDraft({
    required this.id,
    required this.photo,
    required this.key,
    this.status = AuraPhotoStatus.uploading,
    this.progress = 0,
    this.upload,
    this.problem,
  });

  /// Local, for the sheet: the order it was added in.
  final int id;
  final PickedPhoto photo;

  /// `POST /uploads`'s key: made when the photo is added, reused when it's
  /// tried again, new only when the signed URL it got has expired.
  final IdempotencyKey key;
  final AuraPhotoStatus status;

  /// The share of the bytes sent, 0 to 1.
  final double progress;

  /// Where `POST /uploads` said to send it, once it has.
  final Upload? upload;
  final ApiError? problem;

  /// What the filing sends, once the bytes are there.
  String? get receiptId =>
      status == AuraPhotoStatus.ready ? upload?.receiptId : null;

  ReceiptDraft copyWith({
    IdempotencyKey? key,
    AuraPhotoStatus? status,
    double? progress,
    Upload? upload,
    ApiError? Function()? problem,
  }) => ReceiptDraft(
    id: id,
    photo: photo,
    key: key ?? this.key,
    status: status ?? this.status,
    progress: progress ?? this.progress,
    upload: upload ?? this.upload,
    problem: problem == null ? this.problem : problem(),
  );
}

/// What adding photos came to.
enum AddOutcome { added, nothing, cameraOff }

/// The receipts of the filing being written, each uploading on its own as
/// soon as it's added. Lives as long as the filing sheet.
final receiptsProvider =
    NotifierProvider.autoDispose<Receipts, List<ReceiptDraft>>(Receipts.new);

class Receipts extends Notifier<List<ReceiptDraft>> {
  int _next = 0;

  @override
  List<ReceiptDraft> build() => const [];

  /// How many more the filing can take.
  int get room => maxReceipts - state.length;

  /// The ids to file with: the receipts that finished uploading, in order.
  List<String> get receiptIds => [for (final d in state) ?d.receiptId];

  Future<AddOutcome> fromLibrary() async {
    if (room <= 0) return AddOutcome.nothing;
    final photos = await ref.read(photoSourceProvider).library(limit: room);
    if (!ref.mounted || photos.isEmpty) return AddOutcome.nothing;
    photos.take(room).forEach(_add);
    return AddOutcome.added;
  }

  Future<AddOutcome> fromCamera() async {
    if (room <= 0) return AddOutcome.nothing;
    try {
      final photo = await ref.read(photoSourceProvider).camera();
      if (!ref.mounted || photo == null) return AddOutcome.nothing;
      _add(photo);
      return AddOutcome.added;
    } on CameraDenied {
      return AddOutcome.cameraOff;
    }
  }

  /// Tries a receipt that didn't upload again, with the same key.
  void retry(int id) {
    _update(
      id,
      (d) => d.copyWith(
        status: AuraPhotoStatus.uploading,
        progress: 0,
        problem: () => null,
      ),
    );
    _upload(id);
  }

  /// Takes a receipt off the filing. One still uploading finishes on its
  /// own and is never sent with the filing.
  void remove(int id) => state = [
    for (final d in state)
      if (d.id != id) d,
  ];

  void _add(PickedPhoto photo) {
    final draft = ReceiptDraft(
      id: _next++,
      photo: photo,
      key: IdempotencyKey(),
    );
    state = [...state, draft];
    _upload(draft.id);
  }

  Future<void> _upload(int id) async {
    final events = ref.read(eventsRepositoryProvider);
    final storage = ref.read(receiptStorageProvider);
    try {
      var draft = _find(id);
      if (draft == null) return;
      var upload = draft.upload;
      if (upload == null ||
          !upload.expiresAt.isAfter(ref.read(clockProvider))) {
        // An expired URL needs a new one, which needs a new key: the old
        // key would replay the old URL.
        final key = upload == null ? draft.key : IdempotencyKey();
        final photo = draft.photo;
        upload = await events.upload(
          UploadRequest(
            contentType: UploadRequestContentType.fromJson(photo.contentType),
            byteSize: photo.bytes.length,
          ),
          key,
        );
        draft = _update(id, (d) => d.copyWith(key: key, upload: upload));
        if (draft == null) return;
      }
      await storage.put(
        upload,
        draft.photo.bytes,
        contentType: draft.photo.contentType,
        onProgress: (p) => _update(id, (d) => d.copyWith(progress: p)),
      );
      _update(
        id,
        (d) => d.copyWith(status: AuraPhotoStatus.ready, progress: 1),
      );
    } on ApiError catch (e) {
      _update(
        id,
        (d) => d.copyWith(status: AuraPhotoStatus.failed, problem: () => e),
      );
    }
  }

  ReceiptDraft? _find(int id) => state.where((d) => d.id == id).firstOrNull;

  /// Changes one receipt if it's still on the filing; returns it as changed.
  ReceiptDraft? _update(int id, ReceiptDraft Function(ReceiptDraft) change) {
    if (!ref.mounted) return null;
    ReceiptDraft? changed;
    state = [
      for (final d in state)
        if (d.id == id) changed = change(d) else d,
    ];
    return changed;
  }
}

/// One receipt as the sheet shows it.
@immutable
class ReceiptTile {
  const ReceiptTile({
    required this.id,
    required this.bytes,
    required this.status,
    required this.progress,
    required this.label,
    required this.removeLabel,
  });

  final int id;

  /// The photo. The State Gallery draws a stand-in instead.
  final Uint8List bytes;
  final AuraPhotoStatus status;
  final double progress;

  /// "Receipt 1, uploading".
  final String label;
  final String removeLabel;
}

/// The receipts part of the compose step, worded.
@immutable
class ReceiptsModel {
  const ReceiptsModel({
    required this.tiles,
    required this.canAdd,
    required this.note,
    this.noteTone = AuraTone.neutral,
    this.blocksFiling,
  });

  final List<ReceiptTile> tiles;

  /// Whether the add slot shows.
  final bool canAdd;

  /// Help, how the uploads are going, or what went wrong.
  final String note;
  final AuraTone noteTone;

  /// Why File is off because of the receipts, if it is.
  final String? blocksFiling;
}

ReceiptsModel receiptsModel(List<ReceiptDraft> drafts, {bool filing = false}) {
  final uploading = drafts
      .where((d) => d.status == AuraPhotoStatus.uploading)
      .length;
  final failed = drafts.where((d) => d.status == AuraPhotoStatus.failed);
  final offline = failed.any((d) => d.problem?.code == ApiError.appOffline);
  final full = drafts.length >= maxReceipts;
  return ReceiptsModel(
    tiles: [
      for (final (i, d) in drafts.indexed)
        ReceiptTile(
          id: d.id,
          bytes: d.photo.bytes,
          status: d.status,
          progress: d.progress,
          label: receiptLabel(
            i + 1,
            uploading: d.status == AuraPhotoStatus.uploading,
            failed: d.status == AuraPhotoStatus.failed,
          ),
          removeLabel: removeReceipt(i + 1),
        ),
    ],
    canAdd: !full && !filing,
    note: failed.isNotEmpty
        ? (offline ? receiptOffline : receiptDidntUpload)
        : uploading > 0
        ? uploadingPhotos(uploading)
        : full
        ? receiptsFull(maxReceipts)
        : receiptsHelp(maxReceipts),
    noteTone: failed.isNotEmpty ? AuraTone.down : AuraTone.neutral,
    blocksFiling: failed.isNotEmpty
        ? fixReceiptsToFile
        : uploading > 0
        ? waitForReceipts
        : null,
  );
}
