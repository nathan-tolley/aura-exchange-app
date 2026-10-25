// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_position.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MyPosition _$MyPositionFromJson(Map<String, dynamic> json) => MyPosition(
  side: PositionSide.fromJson(json['side'] as String),
  quantity: json['quantity'] as String,
);

Map<String, dynamic> _$MyPositionToJson(MyPosition instance) =>
    <String, dynamic>{'side': instance.side, 'quantity': instance.quantity};
