// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'halt_reason.dart';
import 'halt_scope.dart';
import 'halt_status.dart';
import 'vote.dart';

part 'halt.g.dart';

@JsonSerializable()
class Halt {
  const Halt({
    required this.id,
    required this.scope,
    required this.listingId,
    required this.reason,
    required this.status,
    required this.startedAt,
    required this.endsAt,
    required this.eventId,
    required this.vote,
    required this.ifConfirmedMovePct,
  });
  
  factory Halt.fromJson(Map<String, Object?> json) => _$HaltFromJson(json);
  
  final String id;
  final HaltScope scope;
  @JsonKey(includeIfNull: true)
  final String? listingId;
  final HaltReason reason;
  final HaltStatus status;
  final DateTime startedAt;
  final DateTime endsAt;
  @JsonKey(includeIfNull: true)
  final String? eventId;
  @JsonKey(includeIfNull: true)
  final Vote? vote;

  /// Percent units, decimal string, 2 dp (−12.19 = −12.19%)
  @JsonKey(includeIfNull: true)
  final String? ifConfirmedMovePct;

  Map<String, Object?> toJson() => _$HaltToJson(this);
}
