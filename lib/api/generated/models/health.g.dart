// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Health _$HealthFromJson(Map<String, dynamic> json) => Health(
  status: HealthStatus.fromJson(json['status'] as String),
  serverTime: DateTime.parse(json['serverTime'] as String),
  minBuild: (json['minBuild'] as num).toInt(),
  lastGoodUpdate: json['lastGoodUpdate'] == null
      ? null
      : DateTime.parse(json['lastGoodUpdate'] as String),
);

Map<String, dynamic> _$HealthToJson(Health instance) => <String, dynamic>{
  'status': instance.status,
  'serverTime': instance.serverTime.toIso8601String(),
  'minBuild': instance.minBuild,
  'lastGoodUpdate': instance.lastGoodUpdate?.toIso8601String(),
};
