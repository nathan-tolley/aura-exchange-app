// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receipt.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Receipt _$ReceiptFromJson(Map<String, dynamic> json) => Receipt(
  id: json['id'] as String,
  kind: ReceiptKind.fromJson(json['kind'] as String),
  url: json['url'] as String,
  width: (json['width'] as num?)?.toInt(),
  height: (json['height'] as num?)?.toInt(),
);

Map<String, dynamic> _$ReceiptToJson(Receipt instance) => <String, dynamic>{
  'id': instance.id,
  'kind': instance.kind,
  'url': instance.url,
  'width': ?instance.width,
  'height': ?instance.height,
};
