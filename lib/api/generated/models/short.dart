// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'short.g.dart';

@JsonSerializable()
class Short {
  const Short({
    required this.collateralRequired,
    required this.liquidationPrice,
  });
  
  factory Short.fromJson(Map<String, Object?> json) => _$ShortFromJson(json);
  
  /// Aura Bucks, decimal string, 2 dp
  final String collateralRequired;

  /// Price, decimal string, 2 dp
  final String liquidationPrice;

  Map<String, Object?> toJson() => _$ShortToJson(this);
}
