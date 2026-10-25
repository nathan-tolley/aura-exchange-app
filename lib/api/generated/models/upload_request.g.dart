// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UploadRequest _$UploadRequestFromJson(Map<String, dynamic> json) =>
    UploadRequest(
      contentType: UploadRequestContentType.fromJson(
        json['contentType'] as String,
      ),
      byteSize: (json['byteSize'] as num).toInt(),
    );

Map<String, dynamic> _$UploadRequestToJson(UploadRequest instance) =>
    <String, dynamic>{
      'contentType': instance.contentType,
      'byteSize': instance.byteSize,
    };
