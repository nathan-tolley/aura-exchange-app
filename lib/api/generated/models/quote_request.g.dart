// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quote_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuoteRequest _$QuoteRequestFromJson(Map<String, dynamic> json) => QuoteRequest(
  listingId: json['listingId'] as String,
  side: Side.fromJson(json['side'] as String),
  quantity: json['quantity'] as String,
  previousQuoteId: json['previousQuoteId'] as String?,
);

Map<String, dynamic> _$QuoteRequestToJson(QuoteRequest instance) =>
    <String, dynamic>{
      'listingId': instance.listingId,
      'side': instance.side,
      'quantity': instance.quantity,
      'previousQuoteId': instance.previousQuoteId,
    };
