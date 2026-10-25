// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_apple_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthAppleRequestBody _$AuthAppleRequestBodyFromJson(
  Map<String, dynamic> json,
) => AuthAppleRequestBody(
  identityToken: json['identityToken'] as String,
  displayName: json['displayName'] as String?,
);

Map<String, dynamic> _$AuthAppleRequestBodyToJson(
  AuthAppleRequestBody instance,
) => <String, dynamic>{
  'identityToken': instance.identityToken,
  'displayName': instance.displayName,
};
