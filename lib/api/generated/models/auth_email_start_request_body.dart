// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'auth_email_start_request_body.g.dart';

@JsonSerializable()
class AuthEmailStartRequestBody {
  const AuthEmailStartRequestBody({
    required this.email,
  });
  
  factory AuthEmailStartRequestBody.fromJson(Map<String, Object?> json) => _$AuthEmailStartRequestBodyFromJson(json);
  
  final String email;

  Map<String, Object?> toJson() => _$AuthEmailStartRequestBodyToJson(this);
}
