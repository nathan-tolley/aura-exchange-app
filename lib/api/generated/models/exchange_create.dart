// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'market_hours.dart';

part 'exchange_create.g.dart';

@JsonSerializable()
class ExchangeCreate {
  const ExchangeCreate({
    required this.name,
    required this.timezone,
    this.hours,
  });
  
  factory ExchangeCreate.fromJson(Map<String, Object?> json) => _$ExchangeCreateFromJson(json);
  
  final String name;
  final String timezone;
  @JsonKey(includeIfNull: false)
  final MarketHours? hours;

  Map<String, Object?> toJson() => _$ExchangeCreateToJson(this);
}
