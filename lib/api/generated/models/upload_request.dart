// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'upload_request_content_type.dart';

part 'upload_request.g.dart';

@JsonSerializable()
class UploadRequest {
  const UploadRequest({
    required this.contentType,
    required this.byteSize,
  });
  
  factory UploadRequest.fromJson(Map<String, Object?> json) => _$UploadRequestFromJson(json);
  
  final UploadRequestContentType contentType;
  final int byteSize;

  Map<String, Object?> toJson() => _$UploadRequestToJson(this);
}
