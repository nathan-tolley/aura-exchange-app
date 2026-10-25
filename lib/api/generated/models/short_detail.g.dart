// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'short_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShortDetail _$ShortDetailFromJson(Map<String, dynamic> json) => ShortDetail(
  collateral: json['collateral'] as String,
  collateralRatioPct: json['collateralRatioPct'] as String,
  warningRatioPct: json['warningRatioPct'] as String,
  maintenanceRatioPct: json['maintenanceRatioPct'] as String,
  liquidationPrice: json['liquidationPrice'] as String,
  borrowFeeDailyPct: json['borrowFeeDailyPct'] as String,
);

Map<String, dynamic> _$ShortDetailToJson(ShortDetail instance) =>
    <String, dynamic>{
      'collateral': instance.collateral,
      'collateralRatioPct': instance.collateralRatioPct,
      'warningRatioPct': instance.warningRatioPct,
      'maintenanceRatioPct': instance.maintenanceRatioPct,
      'liquidationPrice': instance.liquidationPrice,
      'borrowFeeDailyPct': instance.borrowFeeDailyPct,
    };
