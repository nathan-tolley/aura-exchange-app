// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'auth_apple_request_body.g.dart';

@JsonSerializable()
class AuthAppleRequestBody {
  const AuthAppleRequestBody({
    required this.identityToken,
    this.displayName,
  });
  
  factory AuthAppleRequestBody.fromJson(Map<String, Object?> json) => _$AuthAppleRequestBodyFromJson(json);
  
  final String identityToken;
  final String? displayName;

  Map<String, Object?> toJson() => _$AuthAppleRequestBodyToJson(this);
}
