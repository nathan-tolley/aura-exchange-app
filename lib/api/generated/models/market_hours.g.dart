// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'market_hours.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MarketHours _$MarketHoursFromJson(Map<String, dynamic> json) => MarketHours(
  preOpen: json['preOpen'] as String,
  open: json['open'] as String,
  close: json['close'] as String,
  afterClose: json['afterClose'] as String,
);

Map<String, dynamic> _$MarketHoursToJson(MarketHours instance) =>
    <String, dynamic>{
      'preOpen': instance.preOpen,
      'open': instance.open,
      'close': instance.close,
      'afterClose': instance.afterClose,
    };
