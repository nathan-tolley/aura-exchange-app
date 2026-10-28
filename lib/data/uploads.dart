import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../api/errors.dart';
import '../api/generated/export.dart';
import 'api_providers.dart';

/// A photo the person chose or took, read into memory.
@immutable
class PickedPhoto {
  const PickedPhoto({required this.bytes, required this.contentType});

  final Uint8List bytes;

  /// One of the contract's `UploadRequest.contentType` values.
  final String contentType;
}

/// Why the camera couldn't be used.
class CameraDenied implements Exception {
  const CameraDenied();
}

/// Where receipts come from: the photo library and the camera. Tests and
/// the State Gallery replace it.
abstract interface class PhotoSource {
  /// Up to [limit] photos from the library; empty if none were chosen.
  Future<List<PickedPhoto>> library({required int limit});

  /// A photo from the camera; null if none was taken. Throws
  /// [CameraDenied] when the person has turned the camera off for the app.
  Future<PickedPhoto?> camera();
}

/// [PhotoSource] through `image_picker`. Photos are scaled to at most
/// 2048 px and re-encoded, which keeps them far under the contract's
/// 25 MB `byteSize` limit and strips most of what a full-size photo
/// carries.
class ImagePickerSource implements PhotoSource {
  ImagePickerSource([ImagePicker? picker]) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;
  static const _maxSide = 2048.0;
  static const _quality = 85;

  @override
  Future<List<PickedPhoto>> library({required int limit}) async {
    if (limit <= 0) return const [];
    final files = limit == 1
        ? [
            ?await _picker.pickImage(
              source: ImageSource.gallery,
              maxWidth: _maxSide,
              maxHeight: _maxSide,
              imageQuality: _quality,
            ),
          ]
        : await _picker.pickMultiImage(
            limit: limit,
            maxWidth: _maxSide,
            maxHeight: _maxSide,
            imageQuality: _quality,
          );
    return [for (final f in files.take(limit)) await _read(f)];
  }

  @override
  Future<PickedPhoto?> camera() async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: _maxSide,
        maxHeight: _maxSide,
        imageQuality: _quality,
      );
      return file == null ? null : await _read(file);
    } on PlatformException catch (e) {
      if (e.code == 'camera_access_denied') throw const CameraDenied();
      rethrow;
    }
  }

  static Future<PickedPhoto> _read(XFile file) async => PickedPhoto(
    bytes: await file.readAsBytes(),
    contentType: contentTypeOf(file.mimeType, file.name),
  );
}

/// The contract's content type for a picked file: its MIME type when the
/// platform gives one, else its extension. Re-encoded photos are JPEG.
@visibleForTesting
String contentTypeOf(String? mimeType, String name) {
  const known = {'image/jpeg', 'image/png', 'image/heic'};
  if (mimeType != null && known.contains(mimeType)) return mimeType;
  final ext = name.split('.').last.toLowerCase();
  return switch (ext) {
    'png' => 'image/png',
    'heic' || 'heif' => 'image/heic',
    _ => 'image/jpeg',
  };
}

final photoSourceProvider = Provider<PhotoSource>((ref) => ImagePickerSource());

/// Sends a receipt's bytes where `POST /uploads` said to: a signed URL on
/// object storage. Nothing of the app's own goes with it (no bearer, no
/// app headers), only the headers the upload names.
class ReceiptStorage {
  ReceiptStorage({HttpClientAdapter? adapter})
    : _dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 20),
        ),
      ) {
    if (adapter != null) _dio.httpClientAdapter = adapter;
  }

  final Dio _dio;

  /// Puts [bytes] of [contentType] at [upload]'s URL, reporting the share
  /// sent so far.
  Future<void> put(
    Upload upload,
    Uint8List bytes, {
    required String contentType,
    ValueChanged<double>? onProgress,
  }) => guardApi(
    () => _dio.request<void>(
      upload.uploadUrl,
      data: Stream.value(bytes),
      options: Options(
        method: upload.method.json ?? 'PUT',
        contentType: contentType,
        headers: {...upload.headers, Headers.contentLengthHeader: bytes.length},
      ),
      onSendProgress: onProgress == null
          ? null
          : (sent, total) => onProgress(total > 0 ? sent / total : 0),
    ),
  );

  void close() => _dio.close();
}

final receiptStorageProvider = Provider<ReceiptStorage>((ref) {
  final storage = ReceiptStorage(adapter: ref.watch(httpAdapterProvider));
  ref.onDispose(storage.close);
  return storage;
});
