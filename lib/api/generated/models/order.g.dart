// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Order _$OrderFromJson(Map<String, dynamic> json) => Order(
  id: json['id'] as String,
  listing: ListingRef.fromJson(json['listing'] as Map<String, dynamic>),
  type: OrderType.fromJson(json['type'] as String),
  quantity: json['quantity'] as String,
  triggerPrice: json['triggerPrice'] as String,
  status: OrderStatus.fromJson(json['status'] as String),
  reservedCash: json['reservedCash'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  filledAt: json['filledAt'] == null
      ? null
      : DateTime.parse(json['filledAt'] as String),
  fillPrice: json['fillPrice'] as String?,
  rejectCode: json['rejectCode'] as String?,
);

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
  'id': instance.id,
  'listing': instance.listing,
  'type': instance.type,
  'quantity': instance.quantity,
  'triggerPrice': instance.triggerPrice,
  'status': instance.status,
  'reservedCash': instance.reservedCash,
  'createdAt': instance.createdAt.toIso8601String(),
  'filledAt': instance.filledAt?.toIso8601String(),
  'fillPrice': instance.fillPrice,
  'rejectCode': instance.rejectCode,
};
