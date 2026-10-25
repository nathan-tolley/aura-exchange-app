// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'rating.dart';

part 'analyst.g.dart';

@JsonSerializable()
class Analyst {
  const Analyst({
    required this.rating,
    required this.priceTarget,
    required this.note,
  });
  
  factory Analyst.fromJson(Map<String, Object?> json) => _$AnalystFromJson(json);
  
  final Rating rating;

  /// Price, decimal string, 2 dp
  final String priceTarget;
  final String note;

  Map<String, Object?> toJson() => _$AnalystToJson(this);
}
