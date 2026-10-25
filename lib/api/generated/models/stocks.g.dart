// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stocks.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Stocks _$StocksFromJson(Map<String, dynamic> json) => Stocks(
  listing: json['listing'] == null
      ? null
      : ListingRef.fromJson(json['listing'] as Map<String, dynamic>),
  seasonChangePct: json['seasonChangePct'] as String?,
);

Map<String, dynamic> _$StocksToJson(Stocks instance) => <String, dynamic>{
  'listing': ?instance.listing,
  'seasonChangePct': ?instance.seasonChangePct,
};
