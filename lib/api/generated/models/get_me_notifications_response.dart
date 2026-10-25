// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'notification.dart';
import 'page.dart';

part 'get_me_notifications_response.g.dart';

@JsonSerializable()
class GetMeNotificationsResponse {
  const GetMeNotificationsResponse({
    required this.nextCursor,
    required this.items,
  });
  
  factory GetMeNotificationsResponse.fromJson(Map<String, Object?> json) => _$GetMeNotificationsResponseFromJson(json);
  
  @JsonKey(includeIfNull: true)
  final String? nextCursor;
  final List<Notification> items;

  Map<String, Object?> toJson() => _$GetMeNotificationsResponseToJson(this);
}
