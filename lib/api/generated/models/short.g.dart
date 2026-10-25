// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'short.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Short _$ShortFromJson(Map<String, dynamic> json) => Short(
  collateralRequired: json['collateralRequired'] as String,
  liquidationPrice: json['liquidationPrice'] as String,
);

Map<String, dynamic> _$ShortToJson(Short instance) => <String, dynamic>{
  'collateralRequired': instance.collateralRequired,
  'liquidationPrice': instance.liquidationPrice,
};
