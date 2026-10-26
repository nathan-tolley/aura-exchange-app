// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_prefs.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationPrefs _$NotificationPrefsFromJson(Map<String, dynamic> json) =>
    NotificationPrefs(
      holdingMovedPct: json['holdingMovedPct'] as String?,
      quietHours: json['quietHours'] == null
          ? null
          : QuietHours.fromJson(json['quietHours'] as Map<String, dynamic>),
      bells: json['bells'] as bool?,
      disabledTypes: (json['disabledTypes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$NotificationPrefsToJson(NotificationPrefs instance) =>
    <String, dynamic>{
      'holdingMovedPct': ?instance.holdingMovedPct,
      'quietHours': ?instance.quietHours,
      'bells': ?instance.bells,
      'disabledTypes': ?instance.disabledTypes,
    };
