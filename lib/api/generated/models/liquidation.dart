// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'liquidation.g.dart';

/// How a liquidated short settled (W08). quantity on the Position is what was bought back. returned = collateral − cost − fee, never below zero (a shortfall is written off, not charged).
@JsonSerializable()
class Liquidation {
  const Liquidation({
    required this.at,
    required this.triggerPrice,
    required this.maintenanceRatioPct,
    required this.collateral,
    required this.price,
    required this.cost,
    required this.feeRate,
    required this.fee,
    required this.returned,
    required this.realizedPnl,
    required this.realizedPnlPct,
  });
  
  factory Liquidation.fromJson(Map<String, Object?> json) => _$LiquidationFromJson(json);
  
  final DateTime at;

  /// The price that crossed the liquidation price
  final String triggerPrice;

  /// The collateral ratio it fell under
  final String maintenanceRatioPct;

  /// What was held against the short
  final String collateral;

  /// Average buy-back price
  final String price;

  /// The buy-back before the fee
  final String cost;

  /// Percent units, decimal string, 2 dp (−12.19 = −12.19%)
  final String feeRate;

  /// Aura Bucks, decimal string, 2 dp
  final String fee;

  /// What came back to your cash
  final String returned;

  /// The whole short's realized P&L, after fees
  final String realizedPnl;

  /// Against the entry value (avgPrice × quantity)
  final String realizedPnlPct;

  Map<String, Object?> toJson() => _$LiquidationToJson(this);
}
