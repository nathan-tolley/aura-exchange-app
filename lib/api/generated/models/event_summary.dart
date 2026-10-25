// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'category.dart';
import 'event_status.dart';
import 'listing_ref.dart';

part 'event_summary.g.dart';

@JsonSerializable()
class EventSummary {
  const EventSummary({
    required this.id,
    required this.subject,
    required this.status,
    required this.teaser,
    required this.headline,
    required this.impactFinal,
    required this.category,
    required this.createdAt,
  });
  
  factory EventSummary.fromJson(Map<String, Object?> json) => _$EventSummaryFromJson(json);
  
  final String id;
  final ListingRef subject;
  final EventStatus status;
  final String teaser;
  final String? headline;
  final int? impactFinal;
  final Category? category;
  final DateTime createdAt;

  Map<String, Object?> toJson() => _$EventSummaryToJson(this);
}
