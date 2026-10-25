// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'quiet_hours.dart';

part 'notification_prefs.g.dart';

@JsonSerializable()
class NotificationPrefs {
  const NotificationPrefs({
    this.holdingMovedPct,
    this.quietHours,
    this.bells,
    this.disabledTypes,
  });
  
  factory NotificationPrefs.fromJson(Map<String, Object?> json) => _$NotificationPrefsFromJson(json);
  
  /// Percent units, decimal string, 2 dp (−12.19 = −12.19%)
  final String? holdingMovedPct;
  final QuietHours? quietHours;
  final bool? bells;
  final List<String>? disabledTypes;

  Map<String, Object?> toJson() => _$NotificationPrefsToJson(this);
}
