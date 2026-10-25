// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'previous.g.dart';

@JsonSerializable()
class Previous {
  const Previous({
    required this.quoteId,
    required this.price,
    required this.total,
    required this.changePct,
  });
  
  factory Previous.fromJson(Map<String, Object?> json) => _$PreviousFromJson(json);
  
  final String quoteId;

  /// Price, decimal string, 2 dp
  final String price;

  /// Aura Bucks, decimal string, 2 dp
  final String total;

  /// Percent units, decimal string, 2 dp (−12.19 = −12.19%)
  final String changePct;

  Map<String, Object?> toJson() => _$PreviousToJson(this);
}
