// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'halt.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Halt _$HaltFromJson(Map<String, dynamic> json) => Halt(
  id: json['id'] as String,
  scope: HaltScope.fromJson(json['scope'] as String),
  listingId: json['listingId'] as String?,
  reason: HaltReason.fromJson(json['reason'] as String),
  status: HaltStatus.fromJson(json['status'] as String),
  startedAt: DateTime.parse(json['startedAt'] as String),
  endsAt: DateTime.parse(json['endsAt'] as String),
  eventId: json['eventId'] as String?,
  vote: json['vote'] == null
      ? null
      : Vote.fromJson(json['vote'] as Map<String, dynamic>),
  ifConfirmedMovePct: json['ifConfirmedMovePct'] as String?,
);

Map<String, dynamic> _$HaltToJson(Halt instance) => <String, dynamic>{
  'id': instance.id,
  'scope': instance.scope,
  'listingId': instance.listingId,
  'reason': instance.reason,
  'status': instance.status,
  'startedAt': instance.startedAt.toIso8601String(),
  'endsAt': instance.endsAt.toIso8601String(),
  'eventId': instance.eventId,
  'vote': instance.vote,
  'ifConfirmedMovePct': instance.ifConfirmedMovePct,
};
