// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'me_notifications_read_request_body.g.dart';

@JsonSerializable()
class MeNotificationsReadRequestBody {
  const MeNotificationsReadRequestBody({
    this.ids,
    this.upTo,
  });
  
  factory MeNotificationsReadRequestBody.fromJson(Map<String, Object?> json) => _$MeNotificationsReadRequestBodyFromJson(json);
  
  final List<String>? ids;
  final DateTime? upTo;

  Map<String, Object?> toJson() => _$MeNotificationsReadRequestBodyToJson(this);
}
