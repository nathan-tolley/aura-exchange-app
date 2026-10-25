// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appeal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Appeal _$AppealFromJson(Map<String, dynamic> json) => Appeal(
  status: Status.fromJson(json['status'] as String),
  deadline: DateTime.parse(json['deadline'] as String),
);

Map<String, dynamic> _$AppealToJson(Appeal instance) => <String, dynamic>{
  'status': instance.status,
  'deadline': instance.deadline.toIso8601String(),
};
