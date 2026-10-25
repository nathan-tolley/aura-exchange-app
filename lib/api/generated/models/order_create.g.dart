// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_create.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderCreate _$OrderCreateFromJson(Map<String, dynamic> json) => OrderCreate(
  listingId: json['listingId'] as String,
  type: OrderType.fromJson(json['type'] as String),
  quantity: json['quantity'] as String,
  triggerPrice: json['triggerPrice'] as String,
  positionId: json['positionId'] as String?,
);

Map<String, dynamic> _$OrderCreateToJson(OrderCreate instance) =>
    <String, dynamic>{
      'listingId': instance.listingId,
      'type': instance.type,
      'quantity': instance.quantity,
      'triggerPrice': instance.triggerPrice,
      'positionId': instance.positionId,
    };
