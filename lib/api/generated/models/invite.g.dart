// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invite.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Invite _$InviteFromJson(Map<String, dynamic> json) => Invite(
  code: json['code'] as String,
  url: json['url'] as String,
  expiresAt: DateTime.parse(json['expiresAt'] as String),
);

Map<String, dynamic> _$InviteToJson(Invite instance) => <String, dynamic>{
  'code': instance.code,
  'url': instance.url,
  'expiresAt': instance.expiresAt.toIso8601String(),
};
