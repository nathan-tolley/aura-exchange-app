// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'me_request_body.g.dart';

@JsonSerializable()
class MeRequestBody {
  const MeRequestBody({
    this.displayName,
  });
  
  factory MeRequestBody.fromJson(Map<String, Object?> json) => _$MeRequestBodyFromJson(json);
  
  final String? displayName;

  Map<String, Object?> toJson() => _$MeRequestBodyToJson(this);
}
