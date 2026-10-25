// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'listing_ref.dart';

part 'traders.g.dart';

@JsonSerializable()
class Traders {
  const Traders({
    this.listing,
    this.netWorth,
  });
  
  factory Traders.fromJson(Map<String, Object?> json) => _$TradersFromJson(json);
  
  @JsonKey(includeIfNull: false)
  final ListingRef? listing;

  /// Aura Bucks, decimal string, 2 dp
  @JsonKey(includeIfNull: false)
  final String? netWorth;

  Map<String, Object?> toJson() => _$TradersToJson(this);
}
