// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventSummary _$EventSummaryFromJson(Map<String, dynamic> json) => EventSummary(
  id: json['id'] as String,
  subject: ListingRef.fromJson(json['subject'] as Map<String, dynamic>),
  status: EventStatus.fromJson(json['status'] as String),
  teaser: json['teaser'] as String,
  headline: json['headline'] as String?,
  impactFinal: (json['impactFinal'] as num?)?.toInt(),
  category: json['category'] == null
      ? null
      : Category.fromJson(json['category'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$EventSummaryToJson(EventSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'subject': instance.subject,
      'status': instance.status,
      'teaser': instance.teaser,
      'headline': instance.headline,
      'impactFinal': instance.impactFinal,
      'category': instance.category,
      'createdAt': instance.createdAt.toIso8601String(),
    };
