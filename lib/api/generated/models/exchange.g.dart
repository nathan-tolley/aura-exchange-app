// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exchange.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Exchange _$ExchangeFromJson(Map<String, dynamic> json) => Exchange(
  id: json['id'] as String,
  name: json['name'] as String,
  timezone: json['timezone'] as String,
  hours: MarketHours.fromJson(json['hours'] as Map<String, dynamic>),
  feeRate: json['feeRate'] as String,
  extendedFeeRate: json['extendedFeeRate'] as String,
  listedCount: (json['listedCount'] as num).toInt(),
  memberCount: (json['memberCount'] as num).toInt(),
  minListingsToOpen: (json['minListingsToOpen'] as num).toInt(),
  season: Season.fromJson(json['season'] as Map<String, dynamic>),
  me: Membership.fromJson(json['me'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ExchangeToJson(Exchange instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'timezone': instance.timezone,
  'hours': instance.hours,
  'feeRate': instance.feeRate,
  'extendedFeeRate': instance.extendedFeeRate,
  'listedCount': instance.listedCount,
  'memberCount': instance.memberCount,
  'minListingsToOpen': instance.minListingsToOpen,
  'season': instance.season,
  'me': instance.me,
};
