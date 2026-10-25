// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Notification _$NotificationFromJson(Map<String, dynamic> json) => Notification(
  id: json['id'] as String,
  type: NotificationType.fromJson(json['type'] as String),
  at: DateTime.parse(json['at'] as String),
  readAt: json['readAt'] == null
      ? null
      : DateTime.parse(json['readAt'] as String),
  title: json['title'] as String,
  body: json['body'] as String,
  listingId: json['listingId'] as String?,
  deepLink: json['deepLink'] as String,
);

Map<String, dynamic> _$NotificationToJson(Notification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'at': instance.at.toIso8601String(),
      'readAt': instance.readAt?.toIso8601String(),
      'title': instance.title,
      'body': instance.body,
      'listingId': instance.listingId,
      'deepLink': instance.deepLink,
    };
