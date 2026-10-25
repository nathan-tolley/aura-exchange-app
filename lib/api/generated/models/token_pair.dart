// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'user.dart';

part 'token_pair.g.dart';

@JsonSerializable()
class TokenPair {
  const TokenPair({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.user,
  });
  
  factory TokenPair.fromJson(Map<String, Object?> json) => _$TokenPairFromJson(json);
  
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final User user;

  Map<String, Object?> toJson() => _$TokenPairToJson(this);
}
