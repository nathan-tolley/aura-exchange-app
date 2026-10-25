// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'choice.dart';

part 'halts_halt_id_votes_request_body.g.dart';

@JsonSerializable()
class HaltsHaltIdVotesRequestBody {
  const HaltsHaltIdVotesRequestBody({
    required this.choice,
  });
  
  factory HaltsHaltIdVotesRequestBody.fromJson(Map<String, Object?> json) => _$HaltsHaltIdVotesRequestBodyFromJson(json);
  
  final Choice choice;

  Map<String, Object?> toJson() => _$HaltsHaltIdVotesRequestBodyToJson(this);
}
