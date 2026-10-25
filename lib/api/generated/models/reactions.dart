// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'mine2.dart';

part 'reactions.g.dart';

@JsonSerializable()
class Reactions {
  const Reactions({
    required this.cosigns,
    required this.caps,
    required this.mine,
  });
  
  factory Reactions.fromJson(Map<String, Object?> json) => _$ReactionsFromJson(json);
  
  final int cosigns;
  final int caps;
  final Mine2? mine;

  Map<String, Object?> toJson() => _$ReactionsToJson(this);
}
