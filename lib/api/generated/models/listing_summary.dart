// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'badge.dart';
import 'listing_state.dart';
import 'my_position.dart';

part 'listing_summary.g.dart';

@JsonSerializable()
class ListingSummary {
  const ListingSummary({
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
  });
  
  factory ListingSummary.fromJson(Map<String, Object?> json) => _$ListingSummaryFromJson(json);
  
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

  Map<String, Object?> toJson() => _$ListingSummaryToJson(this);
}
