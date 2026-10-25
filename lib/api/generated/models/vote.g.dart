// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vote.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Vote _$VoteFromJson(Map<String, dynamic> json) => Vote(
  confirm: (json['confirm'] as num).toInt(),
  decline: (json['decline'] as num).toInt(),
  reconsider: (json['reconsider'] as num).toInt(),
  eligible: (json['eligible'] as num).toInt(),
  mine: json['mine'] == null ? null : Mine.fromJson(json['mine'] as String?),
  reward: json['reward'] as String,
);

Map<String, dynamic> _$VoteToJson(Vote instance) => <String, dynamic>{
  'confirm': instance.confirm,
  'decline': instance.decline,
  'reconsider': instance.reconsider,
  'eligible': instance.eligible,
  'mine': instance.mine,
  'reward': instance.reward,
};
