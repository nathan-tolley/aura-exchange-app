// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing_ref.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListingRef _$ListingRefFromJson(Map<String, dynamic> json) => ListingRef(
  id: json['id'] as String,
  ticker: json['ticker'] as String,
  displayName: json['displayName'] as String,
  avatarUrl: json['avatarUrl'] as String?,
);

Map<String, dynamic> _$ListingRefToJson(ListingRef instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ticker': instance.ticker,
      'displayName': instance.displayName,
      'avatarUrl': instance.avatarUrl,
    };
