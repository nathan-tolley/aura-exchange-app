// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'candle.dart';
import 'candle_series_interval.dart';
import 'markers.dart';
import 'market_state.dart';

part 'candle_series.g.dart';

@JsonSerializable()
class CandleSeries {
  const CandleSeries({
    required this.asOf,
    required this.marketState,
    required this.nextChangeAt,
    required this.interval,
    required this.candles,
    required this.markers,
    required this.prevClose,
  });
  
  factory CandleSeries.fromJson(Map<String, Object?> json) => _$CandleSeriesFromJson(json);
  
  /// When these numbers were true
  final DateTime asOf;
  final MarketState marketState;

  /// When marketState next changes
  final DateTime? nextChangeAt;
  final CandleSeriesInterval interval;
  final List<Candle> candles;
  final List<Markers> markers;

  /// Price, decimal string, 2 dp
  final String prevClose;

  Map<String, Object?> toJson() => _$CandleSeriesToJson(this);
}
