// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'action.dart';

part 'error_detail.g.dart';

@JsonSerializable()
class ErrorDetail {
  const ErrorDetail({
    required this.code,
    required this.message,
    required this.params,
    required this.retryable,
    required this.action,
  });
  
  factory ErrorDetail.fromJson(Map<String, Object?> json) => _$ErrorDetailFromJson(json);
  
  /// See ErrorCode; open-ended so new codes don't break old apps
  final String code;

  /// English, for logs and the web console. The app never displays it.
  final String message;
  final Map<String, String> params;
  final bool retryable;
  final Action action;

  Map<String, Object?> toJson() => _$ErrorDetailToJson(this);
}
