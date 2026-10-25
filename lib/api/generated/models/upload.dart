// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'upload_method.dart';

part 'upload.g.dart';

@JsonSerializable()
class Upload {
  const Upload({
    required this.receiptId,
    required this.uploadUrl,
    required this.method,
    required this.headers,
    required this.expiresAt,
  });
  
  factory Upload.fromJson(Map<String, Object?> json) => _$UploadFromJson(json);
  
  final String receiptId;
  final String uploadUrl;
  final UploadMethod method;
  final Map<String, String> headers;
  final DateTime expiresAt;

  Map<String, Object?> toJson() => _$UploadToJson(this);
}
