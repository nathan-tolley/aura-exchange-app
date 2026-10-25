// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quote.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Quote _$QuoteFromJson(Map<String, dynamic> json) => Quote(
  asOf: DateTime.parse(json['asOf'] as String),
  marketState: MarketState.fromJson(json['marketState'] as String),
  nextChangeAt: json['nextChangeAt'] == null
      ? null
      : DateTime.parse(json['nextChangeAt'] as String),
  id: json['id'] as String,
  listingId: json['listingId'] as String,
  side: Side.fromJson(json['side'] as String),
  quantity: json['quantity'] as String,
  price: json['price'] as String,
  gross: json['gross'] as String,
  feeRate: json['feeRate'] as String,
  fee: json['fee'] as String,
  total: json['total'] as String,
  priceImpactPct: json['priceImpactPct'] as String,
  currentPrice: json['currentPrice'] as String,
  expiresAt: DateTime.parse(json['expiresAt'] as String),
  previous: json['previous'] == null
      ? null
      : Previous.fromJson(json['previous'] as Map<String, dynamic>),
  short: json['short'] == null
      ? null
      : Short.fromJson(json['short'] as Map<String, dynamic>),
  cashAfter: json['cashAfter'] as String,
);

Map<String, dynamic> _$QuoteToJson(Quote instance) => <String, dynamic>{
  'asOf': instance.asOf.toIso8601String(),
  'marketState': instance.marketState,
  'nextChangeAt': instance.nextChangeAt?.toIso8601String(),
  'id': instance.id,
  'listingId': instance.listingId,
  'side': instance.side,
  'quantity': instance.quantity,
  'price': instance.price,
  'gross': instance.gross,
  'feeRate': instance.feeRate,
  'fee': instance.fee,
  'total': instance.total,
  'priceImpactPct': instance.priceImpactPct,
  'currentPrice': instance.currentPrice,
  'expiresAt': instance.expiresAt.toIso8601String(),
  'previous': instance.previous,
  'short': instance.short,
  'cashAfter': instance.cashAfter,
};
