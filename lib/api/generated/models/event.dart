// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'appeal.dart';
import 'event_status.dart';
import 'event_subject_statement.dart';
import 'halt.dart';
import 'listing_ref.dart';
import 'reactions.dart';
import 'receipt.dart';
import 'ruling.dart';
import 'votes.dart';

part 'event.g.dart';

@JsonSerializable()
class Event {
  const Event({
    required this.id,
    required this.exchangeId,
    required this.subject,
    required this.status,
    required this.author,
    required this.isMine,
    required this.isAboutMe,
    required this.isSelfFiled,
    required this.teaser,
    required this.text,
    required this.receipts,
    required this.happenedAt,
    required this.createdAt,
    required this.unsendUntil,
    required this.rumorEndsAt,
    required this.reactions,
    required this.subjectStatement,
    required this.insiderUntil,
    required this.ruling,
    required this.halt,
    required this.votes,
    required this.appeal,
    required this.denialPenaltyPct,
  });
  
  factory Event.fromJson(Map<String, Object?> json) => _$EventFromJson(json);
  
  final String id;
  final String exchangeId;
  final ListingRef subject;
  final EventStatus status;
  @JsonKey(includeIfNull: true)
  final ListingRef? author;

  /// You filed it
  final bool isMine;
  final bool isAboutMe;
  final bool isSelfFiled;
  final String teaser;

  /// Hidden (null) from everyone but the author and moderators until RULED
  @JsonKey(includeIfNull: true)
  final String? text;
  final List<Receipt> receipts;
  @JsonKey(includeIfNull: true)
  final DateTime? happenedAt;
  final DateTime createdAt;

  /// End of the 30-second SENDING window
  @JsonKey(includeIfNull: true)
  final DateTime? unsendUntil;
  @JsonKey(includeIfNull: true)
  final DateTime? rumorEndsAt;
  final Reactions reactions;
  @JsonKey(includeIfNull: true)
  final EventSubjectStatement? subjectStatement;

  /// Set when you are an insider on this event (author or co-signer)
  @JsonKey(includeIfNull: true)
  final DateTime? insiderUntil;
  @JsonKey(includeIfNull: true)
  final Ruling? ruling;
  @JsonKey(includeIfNull: true)
  final Halt? halt;
  @JsonKey(includeIfNull: true)
  final Votes? votes;
  @JsonKey(includeIfNull: true)
  final Appeal? appeal;

  /// How much bigger a confirmed loss gets when the subject denied it (W01). Ruling.multipliers.denial is what was applied.
  final String denialPenaltyPct;

  Map<String, Object?> toJson() => _$EventToJson(this);
}
