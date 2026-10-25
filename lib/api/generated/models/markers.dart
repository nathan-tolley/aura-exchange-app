// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'category.dart';

part 'markers.g.dart';

@JsonSerializable()
class Markers {
  const Markers({
    required this.t,
    required this.eventId,
    required this.impact,
    required this.category,
  });
  
  factory Markers.fromJson(Map<String, Object?> json) => _$MarkersFromJson(json);
  
  final DateTime t;
  final String eventId;
  final int impact;
  final Category category;

  Map<String, Object?> toJson() => _$MarkersToJson(this);
}
