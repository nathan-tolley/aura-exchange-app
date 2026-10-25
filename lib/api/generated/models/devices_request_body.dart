// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'environment.dart';

part 'devices_request_body.g.dart';

@JsonSerializable()
class DevicesRequestBody {
  const DevicesRequestBody({
    required this.apnsToken,
    required this.environment,
  });
  
  factory DevicesRequestBody.fromJson(Map<String, Object?> json) => _$DevicesRequestBodyFromJson(json);
  
  final String apnsToken;
  final Environment environment;

  Map<String, Object?> toJson() => _$DevicesRequestBodyToJson(this);
}
