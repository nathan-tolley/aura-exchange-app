// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'quiet_hours.g.dart';

@JsonSerializable()
class QuietHours {
  const QuietHours({
    required this.start,
    required this.end,
  });
  
  factory QuietHours.fromJson(Map<String, Object?> json) => _$QuietHoursFromJson(json);
  
  final String start;
  final String end;

  Map<String, Object?> toJson() => _$QuietHoursToJson(this);
}
