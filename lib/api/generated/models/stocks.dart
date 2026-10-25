// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'listing_ref.dart';

part 'stocks.g.dart';

@JsonSerializable()
class Stocks {
  const Stocks({
    this.listing,
    this.seasonChangePct,
  });
  
  factory Stocks.fromJson(Map<String, Object?> json) => _$StocksFromJson(json);
  
  @JsonKey(includeIfNull: false)
  final ListingRef? listing;

  /// Percent units, decimal string, 2 dp (−12.19 = −12.19%)
  @JsonKey(includeIfNull: false)
  final String? seasonChangePct;

  Map<String, Object?> toJson() => _$StocksToJson(this);
}
