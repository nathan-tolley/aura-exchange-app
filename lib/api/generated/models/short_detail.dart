// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'short_detail.g.dart';

@JsonSerializable()
class ShortDetail {
  const ShortDetail({
    required this.collateral,
    required this.collateralRatioPct,
    required this.warningRatioPct,
    required this.maintenanceRatioPct,
    required this.liquidationPrice,
    required this.borrowFeeDailyPct,
  });
  
  factory ShortDetail.fromJson(Map<String, Object?> json) => _$ShortDetailFromJson(json);
  
  /// Aura Bucks, decimal string, 2 dp
  final String collateral;

  /// Percent units, decimal string, 2 dp (−12.19 = −12.19%)
  final String collateralRatioPct;

  /// Percent units, decimal string, 2 dp (−12.19 = −12.19%)
  final String warningRatioPct;

  /// Percent units, decimal string, 2 dp (−12.19 = −12.19%)
  final String maintenanceRatioPct;

  /// Price, decimal string, 2 dp
  final String liquidationPrice;

  /// Percent units, decimal string, 2 dp (−12.19 = −12.19%)
  final String borrowFeeDailyPct;

  Map<String, Object?> toJson() => _$ShortDetailToJson(this);
}
