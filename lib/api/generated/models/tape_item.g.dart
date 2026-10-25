// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tape_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TapeItem _$TapeItemFromJson(Map<String, dynamic> json) => TapeItem(
  id: json['id'] as String,
  type: TapeItemType.fromJson(json['type'] as String),
  at: DateTime.parse(json['at'] as String),
  listing: json['listing'] == null
      ? null
      : ListingRef.fromJson(json['listing'] as Map<String, dynamic>),
  headline: json['headline'] as String,
  body: json['body'] as String?,
  impact: (json['impact'] as num?)?.toInt(),
  priceMovePct: json['priceMovePct'] as String?,
  eventId: json['eventId'] as String?,
  haltId: json['haltId'] as String?,
);

Map<String, dynamic> _$TapeItemToJson(TapeItem instance) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'at': instance.at.toIso8601String(),
  'listing': instance.listing,
  'headline': instance.headline,
  'body': instance.body,
  'impact': instance.impact,
  'priceMovePct': instance.priceMovePct,
  'eventId': instance.eventId,
  'haltId': instance.haltId,
};
