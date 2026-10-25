// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'membership.dart';
import 'user.dart';

part 'me.g.dart';

@JsonSerializable()
class Me {
  const Me({
    required this.user,
    required this.memberships,
  });
  
  factory Me.fromJson(Map<String, Object?> json) => _$MeFromJson(json);
  
  final User user;
  final List<Membership> memberships;

  Map<String, Object?> toJson() => _$MeToJson(this);
}
