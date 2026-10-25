// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'multipliers.g.dart';

@JsonSerializable()
class Multipliers {
  const Multipliers({
    required this.cosign,
    required this.self,
    required this.pileOn,
    required this.denial,
    required this.votes,
  });
  
  factory Multipliers.fromJson(Map<String, Object?> json) => _$MultipliersFromJson(json);
  
  final String cosign;
  final String self;
  final String pileOn;
  final String denial;
  final String votes;

  Map<String, Object?> toJson() => _$MultipliersToJson(this);
}
