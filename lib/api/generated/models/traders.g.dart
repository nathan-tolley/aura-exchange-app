// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'traders.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Traders _$TradersFromJson(Map<String, dynamic> json) => Traders(
  listing: json['listing'] == null
      ? null
      : ListingRef.fromJson(json['listing'] as Map<String, dynamic>),
  netWorth: json['netWorth'] as String?,
);

Map<String, dynamic> _$TradersToJson(Traders instance) => <String, dynamic>{
  'listing': instance.listing,
  'netWorth': instance.netWorth,
};
