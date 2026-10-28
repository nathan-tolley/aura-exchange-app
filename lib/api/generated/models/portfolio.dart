// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'market_state.dart';
import 'order.dart';
import 'position.dart';

part 'portfolio.g.dart';

@JsonSerializable()
class Portfolio {
  const Portfolio({
    required this.asOf,
    required this.marketState,
    required this.nextChangeAt,
    required this.exchangeId,
    required this.cash,
    required this.reservedCash,
    required this.netWorth,
    required this.seasonChangeAbs,
    required this.seasonChangePct,
    required this.dayChangeAbs,
    required this.dayChangePct,
    required this.positions,
    required this.openOrders,
    required this.canDeclareBankruptcy,
    required this.nextStimulusAt,
  });
  
  factory Portfolio.fromJson(Map<String, Object?> json) => _$PortfolioFromJson(json);
  
  /// When these numbers were true
  final DateTime asOf;
  final MarketState marketState;

  /// When marketState next changes
  @JsonKey(includeIfNull: true)
  final DateTime? nextChangeAt;
  final String exchangeId;

  /// Aura Bucks, decimal string, 2 dp
  final String cash;

  /// Aura Bucks, decimal string, 2 dp
  final String reservedCash;

  /// Aura Bucks, decimal string, 2 dp
  final String netWorth;

  /// Aura Bucks, decimal string, 2 dp
  final String seasonChangeAbs;

  /// Percent units, decimal string, 2 dp (−12.19 = −12.19%)
  final String seasonChangePct;

  /// Aura Bucks, decimal string, 2 dp
  final String dayChangeAbs;

  /// Percent units, decimal string, 2 dp (−12.19 = −12.19%)
  final String dayChangePct;
  final List<Position> positions;
  final List<Order> openOrders;

  /// Net worth under A$100.00 (Phase 2)
  final bool canDeclareBankruptcy;

  /// When the next weekly allowance (the "stimulus check") lands
  final DateTime nextStimulusAt;

  Map<String, Object?> toJson() => _$PortfolioToJson(this);
}
