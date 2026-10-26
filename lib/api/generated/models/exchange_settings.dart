// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'market_hours.dart';

part 'exchange_settings.g.dart';

@JsonSerializable()
class ExchangeSettings {
  const ExchangeSettings({
    this.name,
    this.hours,
    this.quietDecay,
  });
  
  factory ExchangeSettings.fromJson(Map<String, Object?> json) => _$ExchangeSettingsFromJson(json);
  
  @JsonKey(includeIfNull: false)
  final String? name;
  @JsonKey(includeIfNull: false)
  final MarketHours? hours;
  @JsonKey(includeIfNull: false)
  final bool? quietDecay;

  Map<String, Object?> toJson() => _$ExchangeSettingsToJson(this);
}
