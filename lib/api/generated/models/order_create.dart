// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'order_type.dart';

part 'order_create.g.dart';

@JsonSerializable()
class OrderCreate {
  const OrderCreate({
    required this.listingId,
    required this.type,
    required this.quantity,
    required this.triggerPrice,
    this.positionId,
  });
  
  factory OrderCreate.fromJson(Map<String, Object?> json) => _$OrderCreateFromJson(json);
  
  final String listingId;
  final OrderType type;

  /// Share quantity, decimal string, up to 4 dp
  final String quantity;

  /// Price, decimal string, 2 dp
  final String triggerPrice;

  /// Required for STOP_LOSS / TAKE_PROFIT
  final String? positionId;

  Map<String, Object?> toJson() => _$OrderCreateToJson(this);
}
