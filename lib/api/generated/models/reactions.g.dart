// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reactions.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Reactions _$ReactionsFromJson(Map<String, dynamic> json) => Reactions(
  cosigns: (json['cosigns'] as num).toInt(),
  caps: (json['caps'] as num).toInt(),
  mine: json['mine'] == null ? null : Mine2.fromJson(json['mine'] as String?),
);

Map<String, dynamic> _$ReactionsToJson(Reactions instance) => <String, dynamic>{
  'cosigns': instance.cosigns,
  'caps': instance.caps,
  'mine': instance.mine,
};
