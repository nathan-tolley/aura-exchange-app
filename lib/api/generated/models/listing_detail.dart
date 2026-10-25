// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'analyst.dart';
import 'badge.dart';
import 'event_summary.dart';
import 'halt.dart';
import 'listing_state.dart';
import 'market_state.dart';
import 'my_position.dart';

part 'listing_detail.g.dart';

@JsonSerializable()
class ListingDetail {
  const ListingDetail({
    required this.asOf,
    required this.marketState,
    required this.nextChangeAt,
    required this.id,
    required this.ticker,
    required this.displayName,
    required this.avatarUrl,
    required this.price,
    required this.changeAbs,
    required this.changePct,
    required this.state,
    required this.badges,
    required this.sparkline,
    required this.isMine,
    required this.myPosition,
    required this.prevClose,
    required this.open,
    required this.dayHigh,
    required this.dayLow,
    required this.seasonHigh,
    required this.seasonLow,
    required this.volume,
    required this.shortInterestPct,
    required this.borrowFeeDailyPct,
    required this.indicatedPrice,
    required this.indicatedChangePct,
    required this.halt,
    required this.lastTradeAt,
    required this.events,
    required this.analyst,
  });
  
  factory ListingDetail.fromJson(Map<String, Object?> json) => _$ListingDetailFromJson(json);
  
  /// When these numbers were true
  final DateTime asOf;
  final MarketState marketState;

  /// When marketState next changes
  final DateTime? nextChangeAt;
  final String id;
  final String ticker;
  final String displayName;
  final String? avatarUrl;

  /// Price, decimal string, 2 dp
  final String price;

  /// Change since previous close
  final String changeAbs;

  /// Percent units, decimal string, 2 dp (−12.19 = −12.19%)
  final String changePct;
  final ListingState state;
  final List<Badge> badges;

  /// Today's prices, ≤48 points, oldest first
  final List<String> sparkline;

  /// Your own listing: never tradeable by you
  final bool isMine;
  final MyPosition? myPosition;

  /// Price, decimal string, 2 dp
  final String prevClose;

  /// Price, decimal string, 2 dp
  final String? open;

  /// Price, decimal string, 2 dp
  final String dayHigh;

  /// Price, decimal string, 2 dp
  final String dayLow;

  /// Price, decimal string, 2 dp
  final String seasonHigh;

  /// Price, decimal string, 2 dp
  final String seasonLow;

  /// Share quantity, decimal string, up to 4 dp
  final String volume;

  /// Percent units, decimal string, 2 dp (−12.19 = −12.19%)
  final String shortInterestPct;

  /// Percent units, decimal string, 2 dp (−12.19 = −12.19%)
  final String borrowFeeDailyPct;

  /// Price, decimal string, 2 dp
  final String? indicatedPrice;

  /// Percent units, decimal string, 2 dp (−12.19 = −12.19%)
  final String? indicatedChangePct;
  final Halt? halt;
  final DateTime? lastTradeAt;
  final List<EventSummary> events;
  final Analyst? analyst;

  Map<String, Object?> toJson() => _$ListingDetailToJson(this);
}
