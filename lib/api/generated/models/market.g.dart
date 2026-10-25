// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'market.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Market _$MarketFromJson(Map<String, dynamic> json) => Market(
  asOf: DateTime.parse(json['asOf'] as String),
  marketState: MarketState.fromJson(json['marketState'] as String),
  nextChangeAt: json['nextChangeAt'] == null
      ? null
      : DateTime.parse(json['nextChangeAt'] as String),
  exchangeId: json['exchangeId'] as String,
  index: Index.fromJson(json['index'] as Map<String, dynamic>),
  listings: (json['listings'] as List<dynamic>)
      .map((e) => ListingSummary.fromJson(e as Map<String, dynamic>))
      .toList(),
  queuedEventsCount: (json['queuedEventsCount'] as num).toInt(),
  tradingEnabled: json['tradingEnabled'] as bool,
);

Map<String, dynamic> _$MarketToJson(Market instance) => <String, dynamic>{
  'asOf': instance.asOf.toIso8601String(),
  'marketState': instance.marketState,
  'nextChangeAt': instance.nextChangeAt?.toIso8601String(),
  'exchangeId': instance.exchangeId,
  'index': instance.index,
  'listings': instance.listings,
  'queuedEventsCount': instance.queuedEventsCount,
  'tradingEnabled': instance.tradingEnabled,
};
