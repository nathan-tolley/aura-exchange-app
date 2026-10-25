// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'index.dart';
import 'listing_summary.dart';
import 'market_state.dart';

part 'market.g.dart';

@JsonSerializable()
class Market {
  const Market({
    required this.asOf,
    required this.marketState,
    required this.nextChangeAt,
    required this.exchangeId,
    required this.index,
    required this.listings,
    required this.queuedEventsCount,
    required this.tradingEnabled,
  });
  
  factory Market.fromJson(Map<String, Object?> json) => _$MarketFromJson(json);
  
  /// When these numbers were true
  final DateTime asOf;
  final MarketState marketState;

  /// When marketState next changes
  final DateTime? nextChangeAt;
  final String exchangeId;
  final Index index;
  final List<ListingSummary> listings;

  /// Rulings waiting for the next open
  final int queuedEventsCount;

  /// False until minListingsToOpen is reached
  final bool tradingEnabled;

  Map<String, Object?> toJson() => _$MarketToJson(this);
}
