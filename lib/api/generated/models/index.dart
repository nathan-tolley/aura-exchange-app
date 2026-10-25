// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'index.g.dart';

@JsonSerializable()
class Index {
  const Index({
    required this.name,
    required this.value,
    required this.changePct,
  });
  
  factory Index.fromJson(Map<String, Object?> json) => _$IndexFromJson(json);
  
  final String name;

  /// Price, decimal string, 2 dp
  final String value;

  /// Percent units, decimal string, 2 dp (−12.19 = −12.19%)
  final String changePct;

  Map<String, Object?> toJson() => _$IndexToJson(this);
}
