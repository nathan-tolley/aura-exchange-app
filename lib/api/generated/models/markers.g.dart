// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'markers.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Markers _$MarkersFromJson(Map<String, dynamic> json) => Markers(
  t: DateTime.parse(json['t'] as String),
  eventId: json['eventId'] as String,
  impact: (json['impact'] as num).toInt(),
  category: Category.fromJson(json['category'] as String),
);

Map<String, dynamic> _$MarkersToJson(Markers instance) => <String, dynamic>{
  't': instance.t.toIso8601String(),
  'eventId': instance.eventId,
  'impact': instance.impact,
  'category': instance.category,
};
