// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'me.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Me _$MeFromJson(Map<String, dynamic> json) => Me(
  user: User.fromJson(json['user'] as Map<String, dynamic>),
  memberships: (json['memberships'] as List<dynamic>)
      .map((e) => Membership.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$MeToJson(Me instance) => <String, dynamic>{
  'user': instance.user,
  'memberships': instance.memberships,
};
