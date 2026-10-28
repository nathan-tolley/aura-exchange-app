// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'position.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Position _$PositionFromJson(Map<String, dynamic> json) => Position(
  id: json['id'] as String,
  listing: ListingRef.fromJson(json['listing'] as Map<String, dynamic>),
  side: PositionSide.fromJson(json['side'] as String),
  status: PositionStatus.fromJson(json['status'] as String),
  quantity: json['quantity'] as String,
  avgPrice: json['avgPrice'] as String,
  marketPrice: json['marketPrice'] as String,
  marketValue: json['marketValue'] as String,
  unrealizedPnl: json['unrealizedPnl'] as String,
  unrealizedPnlPct: json['unrealizedPnlPct'] as String,
  short: json['short'] == null
      ? null
      : ShortDetail.fromJson(json['short'] as Map<String, dynamic>),
  openedAt: DateTime.parse(json['openedAt'] as String),
  closedAt: json['closedAt'] == null
      ? null
      : DateTime.parse(json['closedAt'] as String),
  liquidation: json['liquidation'] == null
      ? null
      : Liquidation.fromJson(json['liquidation'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PositionToJson(Position instance) => <String, dynamic>{
  'id': instance.id,
  'listing': instance.listing,
  'side': instance.side,
  'status': instance.status,
  'quantity': instance.quantity,
  'avgPrice': instance.avgPrice,
  'marketPrice': instance.marketPrice,
  'marketValue': instance.marketValue,
  'unrealizedPnl': instance.unrealizedPnl,
  'unrealizedPnlPct': instance.unrealizedPnlPct,
  'short': instance.short,
  'openedAt': instance.openedAt.toIso8601String(),
  'closedAt': instance.closedAt?.toIso8601String(),
  'liquidation': instance.liquidation,
};
