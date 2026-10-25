// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_me_notifications_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetMeNotificationsResponse _$GetMeNotificationsResponseFromJson(
  Map<String, dynamic> json,
) => GetMeNotificationsResponse(
  nextCursor: json['nextCursor'] as String?,
  items: (json['items'] as List<dynamic>)
      .map((e) => Notification.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$GetMeNotificationsResponseToJson(
  GetMeNotificationsResponse instance,
) => <String, dynamic>{
  'nextCursor': instance.nextCursor,
  'items': instance.items,
};
