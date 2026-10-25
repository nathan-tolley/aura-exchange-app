// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'listing_ref.dart';
import 'order_status.dart';
import 'order_type.dart';

part 'order.g.dart';

@JsonSerializable()
class Order {
  const Order({
    required this.id,
    required this.listing,
    required this.type,
    required this.quantity,
    required this.triggerPrice,
    required this.status,
    required this.reservedCash,
    required this.createdAt,
    required this.filledAt,
    required this.fillPrice,
    required this.rejectCode,
  });
  
  factory Order.fromJson(Map<String, Object?> json) => _$OrderFromJson(json);
  
  final String id;
  final ListingRef listing;
  final OrderType type;

  /// Share quantity, decimal string, up to 4 dp
  final String quantity;

  /// Price, decimal string, 2 dp
  final String triggerPrice;
  final OrderStatus status;

  /// Aura Bucks, decimal string, 2 dp
  final String reservedCash;
  final DateTime createdAt;
  final DateTime? filledAt;

  /// Price, decimal string, 2 dp
  final String? fillPrice;
  final String? rejectCode;

  Map<String, Object?> toJson() => _$OrderToJson(this);
}
