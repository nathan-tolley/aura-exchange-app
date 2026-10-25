// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'market_state.dart';
import 'previous.dart';
import 'short.dart';
import 'side.dart';

part 'quote.g.dart';

@JsonSerializable()
class Quote {
  const Quote({
    required this.asOf,
    required this.marketState,
    required this.nextChangeAt,
    required this.id,
    required this.listingId,
    required this.side,
    required this.quantity,
    required this.price,
    required this.gross,
    required this.feeRate,
    required this.fee,
    required this.total,
    required this.priceImpactPct,
    required this.currentPrice,
    required this.expiresAt,
    required this.previous,
    required this.short,
    required this.cashAfter,
  });
  
  factory Quote.fromJson(Map<String, Object?> json) => _$QuoteFromJson(json);
  
  /// When these numbers were true
  final DateTime asOf;
  final MarketState marketState;

  /// When marketState next changes
  final DateTime? nextChangeAt;
  final String id;
  final String listingId;
  final Side side;

  /// Share quantity, decimal string, up to 4 dp
  final String quantity;

  /// Price, decimal string, 2 dp
  final String price;

  /// Aura Bucks, decimal string, 2 dp
  final String gross;

  /// Percent units, decimal string, 2 dp (−12.19 = −12.19%)
  final String feeRate;

  /// Aura Bucks, decimal string, 2 dp
  final String fee;

  /// What leaves (buy/cover) or arrives in (sell) your cash
  final String total;

  /// Percent units, decimal string, 2 dp (−12.19 = −12.19%)
  final String priceImpactPct;

  /// Price, decimal string, 2 dp
  final String currentPrice;

  /// Quotes hold 15 s
  final DateTime expiresAt;
  final Previous? previous;
  final Short? short;

  /// Negative means the trade would be rejected
  final String cashAfter;

  Map<String, Object?> toJson() => _$QuoteToJson(this);
}
