// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'market_hours.dart';
import 'membership.dart';
import 'season.dart';

part 'exchange.g.dart';

@JsonSerializable()
class Exchange {
  const Exchange({
    required this.id,
    required this.name,
    required this.timezone,
    required this.hours,
    required this.feeRate,
    required this.extendedFeeRate,
    required this.listedCount,
    required this.memberCount,
    required this.minListingsToOpen,
    required this.season,
    required this.me,
  });
  
  factory Exchange.fromJson(Map<String, Object?> json) => _$ExchangeFromJson(json);
  
  final String id;
  final String name;

  /// IANA
  final String timezone;
  final MarketHours hours;

  /// Percent units, decimal string, 2 dp (−12.19 = −12.19%)
  final String feeRate;

  /// Percent units, decimal string, 2 dp (−12.19 = −12.19%)
  final String extendedFeeRate;
  final int listedCount;
  final int memberCount;

  /// Trading starts when listedCount reaches this
  final int minListingsToOpen;
  final Season season;
  final Membership me;

  Map<String, Object?> toJson() => _$ExchangeToJson(this);
}
