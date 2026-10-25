// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'trade_request.g.dart';

@JsonSerializable()
class TradeRequest {
  const TradeRequest({
    required this.quoteId,
  });
  
  factory TradeRequest.fromJson(Map<String, Object?> json) => _$TradeRequestFromJson(json);
  
  final String quoteId;

  Map<String, Object?> toJson() => _$TradeRequestToJson(this);
}
