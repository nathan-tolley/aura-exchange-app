// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'auth_email_verify_request_body.g.dart';

@JsonSerializable()
class AuthEmailVerifyRequestBody {
  const AuthEmailVerifyRequestBody({
    required this.email,
    required this.code,
  });
  
  factory AuthEmailVerifyRequestBody.fromJson(Map<String, Object?> json) => _$AuthEmailVerifyRequestBodyFromJson(json);
  
  final String email;
  final String code;

  Map<String, Object?> toJson() => _$AuthEmailVerifyRequestBodyToJson(this);
}
