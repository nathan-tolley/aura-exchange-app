// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exchange_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExchangeSettings _$ExchangeSettingsFromJson(Map<String, dynamic> json) =>
    ExchangeSettings(
      name: json['name'] as String?,
      hours: json['hours'] == null
          ? null
          : MarketHours.fromJson(json['hours'] as Map<String, dynamic>),
      quietDecay: json['quietDecay'] as bool?,
    );

Map<String, dynamic> _$ExchangeSettingsToJson(ExchangeSettings instance) =>
    <String, dynamic>{
      'name': ?instance.name,
      'hours': ?instance.hours,
      'quietDecay': ?instance.quietDecay,
    };
