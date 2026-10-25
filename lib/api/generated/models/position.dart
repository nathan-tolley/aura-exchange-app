// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'listing_ref.dart';
import 'position_side.dart';
import 'position_status.dart';
import 'short_detail.dart';

part 'position.g.dart';

@JsonSerializable()
class Position {
  const Position({
    required this.id,
    required this.listing,
    required this.side,
    required this.status,
    required this.quantity,
    required this.avgPrice,
    required this.marketPrice,
    required this.marketValue,
    required this.unrealizedPnl,
    required this.unrealizedPnlPct,
    required this.short,
    required this.openedAt,
    required this.closedAt,
  });
  
  factory Position.fromJson(Map<String, Object?> json) => _$PositionFromJson(json);
  
  final String id;
  final ListingRef listing;
  final PositionSide side;
  final PositionStatus status;

  /// Share quantity, decimal string, up to 4 dp
  final String quantity;

  /// Price, decimal string, 2 dp
  final String avgPrice;

  /// Price, decimal string, 2 dp
  final String marketPrice;

  /// Aura Bucks, decimal string, 2 dp
  final String marketValue;

  /// Aura Bucks, decimal string, 2 dp
  final String unrealizedPnl;

  /// Percent units, decimal string, 2 dp (−12.19 = −12.19%)
  final String unrealizedPnlPct;
  final ShortDetail? short;
  final DateTime openedAt;
  final DateTime? closedAt;

  Map<String, Object?> toJson() => _$PositionToJson(this);
}
