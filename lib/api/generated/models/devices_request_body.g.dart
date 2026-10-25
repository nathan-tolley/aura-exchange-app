// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'devices_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DevicesRequestBody _$DevicesRequestBodyFromJson(Map<String, dynamic> json) =>
    DevicesRequestBody(
      apnsToken: json['apnsToken'] as String,
      environment: Environment.fromJson(json['environment'] as String),
    );

Map<String, dynamic> _$DevicesRequestBodyToJson(DevicesRequestBody instance) =>
    <String, dynamic>{
      'apnsToken': instance.apnsToken,
      'environment': instance.environment,
    };
