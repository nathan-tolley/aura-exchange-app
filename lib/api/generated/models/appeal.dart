// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'status.dart';

part 'appeal.g.dart';

@JsonSerializable()
class Appeal {
  const Appeal({
    required this.status,
    required this.deadline,
  });
  
  factory Appeal.fromJson(Map<String, Object?> json) => _$AppealFromJson(json);
  
  final Status status;
  final DateTime deadline;

  Map<String, Object?> toJson() => _$AppealToJson(this);
}
