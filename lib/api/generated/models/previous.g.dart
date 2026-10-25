// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'previous.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Previous _$PreviousFromJson(Map<String, dynamic> json) => Previous(
  quoteId: json['quoteId'] as String,
  price: json['price'] as String,
  total: json['total'] as String,
  changePct: json['changePct'] as String,
);

Map<String, dynamic> _$PreviousToJson(Previous instance) => <String, dynamic>{
  'quoteId': instance.quoteId,
  'price': instance.price,
  'total': instance.total,
  'changePct': instance.changePct,
};
