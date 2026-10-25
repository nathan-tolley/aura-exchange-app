// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'auth_logout_request_body.g.dart';

@JsonSerializable()
class AuthLogoutRequestBody {
  const AuthLogoutRequestBody({
    required this.refreshToken,
  });
  
  factory AuthLogoutRequestBody.fromJson(Map<String, Object?> json) => _$AuthLogoutRequestBodyFromJson(json);
  
  final String refreshToken;

  Map<String, Object?> toJson() => _$AuthLogoutRequestBodyToJson(this);
}
