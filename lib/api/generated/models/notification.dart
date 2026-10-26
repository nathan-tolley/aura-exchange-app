// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'notification_type.dart';

part 'notification.g.dart';

@JsonSerializable()
class Notification {
  const Notification({
    required this.id,
    required this.type,
    required this.at,
    required this.readAt,
    required this.title,
    required this.body,
    required this.listingId,
    required this.deepLink,
  });
  
  factory Notification.fromJson(Map<String, Object?> json) => _$NotificationFromJson(json);
  
  final String id;
  final NotificationType type;
  final DateTime at;
  @JsonKey(includeIfNull: true)
  final DateTime? readAt;
  final String title;
  final String body;
  @JsonKey(includeIfNull: true)
  final String? listingId;

  /// aura:// route the app opens
  final String deepLink;

  Map<String, Object?> toJson() => _$NotificationToJson(this);
}
