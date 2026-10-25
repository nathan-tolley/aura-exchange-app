// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reports_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportsRequestBody _$ReportsRequestBodyFromJson(Map<String, dynamic> json) =>
    ReportsRequestBody(
      targetType: TargetType.fromJson(json['targetType'] as String),
      targetId: json['targetId'] as String,
      reason: json['reason'] as String,
    );

Map<String, dynamic> _$ReportsRequestBodyToJson(ReportsRequestBody instance) =>
    <String, dynamic>{
      'targetType': instance.targetType,
      'targetId': instance.targetId,
      'reason': instance.reason,
    };
