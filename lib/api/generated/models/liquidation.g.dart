// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'liquidation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Liquidation _$LiquidationFromJson(Map<String, dynamic> json) => Liquidation(
  at: DateTime.parse(json['at'] as String),
  triggerPrice: json['triggerPrice'] as String,
  maintenanceRatioPct: json['maintenanceRatioPct'] as String,
  collateral: json['collateral'] as String,
  price: json['price'] as String,
  cost: json['cost'] as String,
  feeRate: json['feeRate'] as String,
  fee: json['fee'] as String,
  returned: json['returned'] as String,
  realizedPnl: json['realizedPnl'] as String,
  realizedPnlPct: json['realizedPnlPct'] as String,
);

Map<String, dynamic> _$LiquidationToJson(Liquidation instance) =>
    <String, dynamic>{
      'at': instance.at.toIso8601String(),
      'triggerPrice': instance.triggerPrice,
      'maintenanceRatioPct': instance.maintenanceRatioPct,
      'collateral': instance.collateral,
      'price': instance.price,
      'cost': instance.cost,
      'feeRate': instance.feeRate,
      'fee': instance.fee,
      'returned': instance.returned,
      'realizedPnl': instance.realizedPnl,
      'realizedPnlPct': instance.realizedPnlPct,
    };
