// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exchange_create.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExchangeCreate _$ExchangeCreateFromJson(Map<String, dynamic> json) =>
    ExchangeCreate(
      name: json['name'] as String,
      timezone: json['timezone'] as String,
      hours: json['hours'] == null
          ? null
          : MarketHours.fromJson(json['hours'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ExchangeCreateToJson(ExchangeCreate instance) =>
    <String, dynamic>{
      'name': instance.name,
      'timezone': instance.timezone,
      'hours': ?instance.hours,
    };
