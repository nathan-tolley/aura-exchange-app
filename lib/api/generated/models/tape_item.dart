// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'listing_ref.dart';
import 'tape_item_type.dart';

part 'tape_item.g.dart';

/// Never names a trader in WHALE or LIQUIDATION items
@JsonSerializable()
class TapeItem {
  const TapeItem({
    required this.id,
    required this.type,
    required this.at,
    required this.listing,
    required this.headline,
    required this.body,
    required this.impact,
    required this.priceMovePct,
    required this.eventId,
    required this.haltId,
  });
  
  factory TapeItem.fromJson(Map<String, Object?> json) => _$TapeItemFromJson(json);
  
  final String id;
  final TapeItemType type;
  final DateTime at;
  final ListingRef? listing;
  final String headline;
  final String? body;
  final int? impact;

  /// Percent units, decimal string, 2 dp (−12.19 = −12.19%)
  final String? priceMovePct;
  final String? eventId;
  final String? haltId;

  Map<String, Object?> toJson() => _$TapeItemToJson(this);
}
