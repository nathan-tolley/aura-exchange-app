// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'invite.g.dart';

@JsonSerializable()
class Invite {
  const Invite({
    required this.code,
    required this.url,
    required this.expiresAt,
  });
  
  factory Invite.fromJson(Map<String, Object?> json) => _$InviteFromJson(json);
  
  final String code;
  final String url;
  final DateTime expiresAt;

  Map<String, Object?> toJson() => _$InviteToJson(this);
}
