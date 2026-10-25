// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Upload _$UploadFromJson(Map<String, dynamic> json) => Upload(
  receiptId: json['receiptId'] as String,
  uploadUrl: json['uploadUrl'] as String,
  method: UploadMethod.fromJson(json['method'] as String),
  headers: Map<String, String>.from(json['headers'] as Map),
  expiresAt: DateTime.parse(json['expiresAt'] as String),
);

Map<String, dynamic> _$UploadToJson(Upload instance) => <String, dynamic>{
  'receiptId': instance.receiptId,
  'uploadUrl': instance.uploadUrl,
  'method': instance.method,
  'headers': instance.headers,
  'expiresAt': instance.expiresAt.toIso8601String(),
};
