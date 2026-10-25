// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trade.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Trade _$TradeFromJson(Map<String, dynamic> json) => Trade(
  id: json['id'] as String,
  quoteId: json['quoteId'] as String,
  listing: ListingRef.fromJson(json['listing'] as Map<String, dynamic>),
  side: Side.fromJson(json['side'] as String),
  quantity: json['quantity'] as String,
  price: json['price'] as String,
  fee: json['fee'] as String,
  total: json['total'] as String,
  cashAfter: json['cashAfter'] as String,
  position: json['position'] == null
      ? null
      : Position.fromJson(json['position'] as Map<String, dynamic>),
  executedAt: DateTime.parse(json['executedAt'] as String),
);

Map<String, dynamic> _$TradeToJson(Trade instance) => <String, dynamic>{
  'id': instance.id,
  'quoteId': instance.quoteId,
  'listing': instance.listing,
  'side': instance.side,
  'quantity': instance.quantity,
  'price': instance.price,
  'fee': instance.fee,
  'total': instance.total,
  'cashAfter': instance.cashAfter,
  'position': instance.position,
  'executedAt': instance.executedAt.toIso8601String(),
};
