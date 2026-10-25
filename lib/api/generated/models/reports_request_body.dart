// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'target_type.dart';

part 'reports_request_body.g.dart';

@JsonSerializable()
class ReportsRequestBody {
  const ReportsRequestBody({
    required this.targetType,
    required this.targetId,
    required this.reason,
  });
  
  factory ReportsRequestBody.fromJson(Map<String, Object?> json) => _$ReportsRequestBodyFromJson(json);
  
  final TargetType targetType;
  final String targetId;
  final String reason;

  Map<String, Object?> toJson() => _$ReportsRequestBodyToJson(this);
}
