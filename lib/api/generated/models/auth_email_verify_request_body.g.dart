// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_email_verify_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthEmailVerifyRequestBody _$AuthEmailVerifyRequestBodyFromJson(
  Map<String, dynamic> json,
) => AuthEmailVerifyRequestBody(
  email: json['email'] as String,
  code: json['code'] as String,
);

Map<String, dynamic> _$AuthEmailVerifyRequestBodyToJson(
  AuthEmailVerifyRequestBody instance,
) => <String, dynamic>{'email': instance.email, 'code': instance.code};
