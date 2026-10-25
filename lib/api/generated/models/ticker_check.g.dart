// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticker_check.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TickerCheck _$TickerCheckFromJson(Map<String, dynamic> json) => TickerCheck(
  ticker: json['ticker'] as String,
  available: json['available'] as bool,
  suggestions: (json['suggestions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$TickerCheckToJson(TickerCheck instance) =>
    <String, dynamic>{
      'ticker': instance.ticker,
      'available': instance.available,
      'suggestions': instance.suggestions,
    };
