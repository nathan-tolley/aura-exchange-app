// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'me_notifications_read_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MeNotificationsReadRequestBody _$MeNotificationsReadRequestBodyFromJson(
  Map<String, dynamic> json,
) => MeNotificationsReadRequestBody(
  ids: (json['ids'] as List<dynamic>?)?.map((e) => e as String).toList(),
  upTo: json['upTo'] == null ? null : DateTime.parse(json['upTo'] as String),
);

Map<String, dynamic> _$MeNotificationsReadRequestBodyToJson(
  MeNotificationsReadRequestBody instance,
) => <String, dynamic>{
  'ids': ?instance.ids,
  'upTo': ?instance.upTo?.toIso8601String(),
};
