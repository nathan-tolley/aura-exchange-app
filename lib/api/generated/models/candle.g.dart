// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'candle.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Candle _$CandleFromJson(Map<String, dynamic> json) => Candle(
  t: DateTime.parse(json['t'] as String),
  o: json['o'] as String,
  h: json['h'] as String,
  l: json['l'] as String,
  c: json['c'] as String,
  v: json['v'] as String,
);

Map<String, dynamic> _$CandleToJson(Candle instance) => <String, dynamic>{
  't': instance.t.toIso8601String(),
  'o': instance.o,
  'h': instance.h,
  'l': instance.l,
  'c': instance.c,
  'v': instance.v,
};
