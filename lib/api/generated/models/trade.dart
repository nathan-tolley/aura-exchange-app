// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'listing_ref.dart';
import 'position.dart';
import 'side.dart';

part 'trade.g.dart';

@JsonSerializable()
class Trade {
  const Trade({
    required this.id,
    required this.quoteId,
    required this.listing,
    required this.side,
    required this.quantity,
    required this.price,
    required this.fee,
    required this.total,
    required this.cashAfter,
    required this.position,
    required this.executedAt,
  });
  
  factory Trade.fromJson(Map<String, Object?> json) => _$TradeFromJson(json);
  
  final String id;
  final String quoteId;
  final ListingRef listing;
  final Side side;

  /// Share quantity, decimal string, up to 4 dp
  final String quantity;

  /// Price, decimal string, 2 dp
  final String price;

  /// Aura Bucks, decimal string, 2 dp
  final String fee;

  /// Aura Bucks, decimal string, 2 dp
  final String total;

  /// Aura Bucks, decimal string, 2 dp
  final String cashAfter;
  final Position? position;
  final DateTime executedAt;

  Map<String, Object?> toJson() => _$TradeToJson(this);
}
