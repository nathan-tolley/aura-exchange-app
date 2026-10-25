// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'market_hours.g.dart';

/// Local times in the exchange's timezone
@JsonSerializable()
class MarketHours {
  const MarketHours({
    required this.preOpen,
    required this.open,
    required this.close,
    required this.afterClose,
  });
  
  factory MarketHours.fromJson(Map<String, Object?> json) => _$MarketHoursFromJson(json);
  
  final String preOpen;
  final String open;
  final String close;
  final String afterClose;

  Map<String, Object?> toJson() => _$MarketHoursToJson(this);
}
