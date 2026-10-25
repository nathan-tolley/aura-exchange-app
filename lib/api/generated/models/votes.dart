// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'mine3.dart';

part 'votes.g.dart';

@JsonSerializable()
class Votes {
  const Votes({
    required this.up,
    required this.down,
    required this.mine,
    required this.closesAt,
    required this.conflicted,
  });
  
  factory Votes.fromJson(Map<String, Object?> json) => _$VotesFromJson(json);
  
  final int up;
  final int down;
  final Mine3? mine;
  final DateTime closesAt;

  /// You hold a position in this stock
  final bool conflicted;

  Map<String, Object?> toJson() => _$VotesToJson(this);
}
