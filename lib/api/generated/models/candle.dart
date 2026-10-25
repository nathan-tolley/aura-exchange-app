// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'candle.g.dart';

@JsonSerializable()
class Candle {
  const Candle({
    required this.t,
    required this.o,
    required this.h,
    required this.l,
    required this.c,
    required this.v,
  });
  
  factory Candle.fromJson(Map<String, Object?> json) => _$CandleFromJson(json);
  
  final DateTime t;

  /// Price, decimal string, 2 dp
  final String o;

  /// Price, decimal string, 2 dp
  final String h;

  /// Price, decimal string, 2 dp
  final String l;

  /// Price, decimal string, 2 dp
  final String c;

  /// Share quantity, decimal string, up to 4 dp
  final String v;

  Map<String, Object?> toJson() => _$CandleToJson(this);
}
