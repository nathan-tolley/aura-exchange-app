// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'ipo_request.g.dart';

@JsonSerializable()
class IpoRequest {
  const IpoRequest({
    required this.ticker,
    required this.consent,
  });
  
  factory IpoRequest.fromJson(Map<String, Object?> json) => _$IpoRequestFromJson(json);
  
  /// 3–5 letters, without $
  final String ticker;

  /// Explicit consent to be listed
  final bool consent;

  Map<String, Object?> toJson() => _$IpoRequestToJson(this);
}
