// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'event_create.g.dart';

@JsonSerializable()
class EventCreate {
  const EventCreate({
    required this.exchangeId,
    required this.subjectListingId,
    required this.text,
    this.receiptIds,
    this.happenedAt,
  });
  
  factory EventCreate.fromJson(Map<String, Object?> json) => _$EventCreateFromJson(json);
  
  final String exchangeId;
  final String subjectListingId;
  final String text;
  @JsonKey(includeIfNull: false)
  final List<String>? receiptIds;
  @JsonKey(includeIfNull: false)
  final DateTime? happenedAt;

  Map<String, Object?> toJson() => _$EventCreateToJson(this);
}
