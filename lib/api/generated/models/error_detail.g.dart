// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'error_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ErrorDetail _$ErrorDetailFromJson(Map<String, dynamic> json) => ErrorDetail(
  code: json['code'] as String,
  message: json['message'] as String,
  params: Map<String, String>.from(json['params'] as Map),
  retryable: json['retryable'] as bool,
  action: Action.fromJson(json['action'] as String),
);

Map<String, dynamic> _$ErrorDetailToJson(ErrorDetail instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'params': instance.params,
      'retryable': instance.retryable,
      'action': instance.action,
    };
