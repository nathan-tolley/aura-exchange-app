// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'mine.dart';

part 'vote.g.dart';

@JsonSerializable()
class Vote {
  const Vote({
    required this.confirm,
    required this.decline,
    required this.reconsider,
    required this.eligible,
    required this.mine,
    required this.reward,
  });
  
  factory Vote.fromJson(Map<String, Object?> json) => _$VoteFromJson(json);
  
  final int confirm;
  final int decline;
  final int reconsider;
  final int eligible;
  @JsonKey(includeIfNull: true)
  final Mine? mine;

  /// Paid to each voter when it closes
  final String reward;

  Map<String, Object?> toJson() => _$VoteToJson(this);
}
