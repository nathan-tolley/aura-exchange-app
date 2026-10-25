// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'side.dart';

part 'quote_request.g.dart';

@JsonSerializable()
class QuoteRequest {
  const QuoteRequest({
    required this.listingId,
    required this.side,
    required this.quantity,
    this.previousQuoteId,
  });
  
  factory QuoteRequest.fromJson(Map<String, Object?> json) => _$QuoteRequestFromJson(json);
  
  final String listingId;
  final Side side;

  /// Share quantity, decimal string, up to 4 dp
  final String quantity;

  /// Set when requoting, so the response can show the difference
  final String? previousQuoteId;

  Map<String, Object?> toJson() => _$QuoteRequestToJson(this);
}
