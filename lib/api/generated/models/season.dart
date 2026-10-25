// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'season.g.dart';

@JsonSerializable()
class Season {
  const Season({
    required this.id,
    required this.number,
    required this.startsAt,
    required this.endsAt,
  });
  
  factory Season.fromJson(Map<String, Object?> json) => _$SeasonFromJson(json);
  
  final String id;
  final int number;
  final DateTime startsAt;
  final DateTime endsAt;

  Map<String, Object?> toJson() => _$SeasonToJson(this);
}
