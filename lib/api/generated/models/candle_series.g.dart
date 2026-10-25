// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'candle_series.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CandleSeries _$CandleSeriesFromJson(Map<String, dynamic> json) => CandleSeries(
  asOf: DateTime.parse(json['asOf'] as String),
  marketState: MarketState.fromJson(json['marketState'] as String),
  nextChangeAt: json['nextChangeAt'] == null
      ? null
      : DateTime.parse(json['nextChangeAt'] as String),
  interval: CandleSeriesInterval.fromJson(json['interval'] as String),
  candles: (json['candles'] as List<dynamic>)
      .map((e) => Candle.fromJson(e as Map<String, dynamic>))
      .toList(),
  markers: (json['markers'] as List<dynamic>)
      .map((e) => Markers.fromJson(e as Map<String, dynamic>))
      .toList(),
  prevClose: json['prevClose'] as String,
);

Map<String, dynamic> _$CandleSeriesToJson(CandleSeries instance) =>
    <String, dynamic>{
      'asOf': instance.asOf.toIso8601String(),
      'marketState': instance.marketState,
      'nextChangeAt': instance.nextChangeAt?.toIso8601String(),
      'interval': instance.interval,
      'candles': instance.candles,
      'markers': instance.markers,
      'prevClose': instance.prevClose,
    };
