// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_create.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventCreate _$EventCreateFromJson(Map<String, dynamic> json) => EventCreate(
  exchangeId: json['exchangeId'] as String,
  subjectListingId: json['subjectListingId'] as String,
  text: json['text'] as String,
  receiptIds: (json['receiptIds'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  happenedAt: json['happenedAt'] == null
      ? null
      : DateTime.parse(json['happenedAt'] as String),
);

Map<String, dynamic> _$EventCreateToJson(EventCreate instance) =>
    <String, dynamic>{
      'exchangeId': instance.exchangeId,
      'subjectListingId': instance.subjectListingId,
      'text': instance.text,
      'receiptIds': instance.receiptIds,
      'happenedAt': instance.happenedAt?.toIso8601String(),
    };
