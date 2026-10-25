// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'votes.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Votes _$VotesFromJson(Map<String, dynamic> json) => Votes(
  up: (json['up'] as num).toInt(),
  down: (json['down'] as num).toInt(),
  mine: json['mine'] == null ? null : Mine3.fromJson(json['mine'] as String?),
  closesAt: DateTime.parse(json['closesAt'] as String),
  conflicted: json['conflicted'] as bool,
);

Map<String, dynamic> _$VotesToJson(Votes instance) => <String, dynamic>{
  'up': instance.up,
  'down': instance.down,
  'mine': instance.mine,
  'closesAt': instance.closesAt.toIso8601String(),
  'conflicted': instance.conflicted,
};
