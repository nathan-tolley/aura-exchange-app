// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'freshness.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Freshness _$FreshnessFromJson(Map<String, dynamic> json) => Freshness(
  asOf: DateTime.parse(json['asOf'] as String),
  marketState: MarketState.fromJson(json['marketState'] as String),
  nextChangeAt: json['nextChangeAt'] == null
      ? null
      : DateTime.parse(json['nextChangeAt'] as String),
);

Map<String, dynamic> _$FreshnessToJson(Freshness instance) => <String, dynamic>{
  'asOf': instance.asOf.toIso8601String(),
  'marketState': instance.marketState,
  'nextChangeAt': instance.nextChangeAt?.toIso8601String(),
};
