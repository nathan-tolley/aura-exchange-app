// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'market_state.dart';

part 'freshness.g.dart';

/// Included in every payload with prices. The app shows 'Delayed · as of …' when asOf is >60 s old or the socket is down.
@JsonSerializable()
class Freshness {
  const Freshness({
    required this.asOf,
    required this.marketState,
    required this.nextChangeAt,
  });
  
  factory Freshness.fromJson(Map<String, Object?> json) => _$FreshnessFromJson(json);
  
  /// When these numbers were true
  final DateTime asOf;
  final MarketState marketState;

  /// When marketState next changes
  @JsonKey(includeIfNull: true)
  final DateTime? nextChangeAt;

  Map<String, Object?> toJson() => _$FreshnessToJson(this);
}
