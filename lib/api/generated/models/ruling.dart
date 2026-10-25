// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'category.dart';
import 'multipliers.dart';
import 'ruling_verdict.dart';

part 'ruling.g.dart';

@JsonSerializable()
class Ruling {
  const Ruling({
    required this.verdict,
    required this.impactAnalyst,
    required this.impactFinal,
    required this.multipliers,
    required this.confidence,
    required this.category,
    required this.headline,
    required this.analystNote,
    required this.ruledAt,
    required this.priceMovePct,
    required this.landsAt,
    required this.indicatedPrice,
    required this.correction,
  });
  
  factory Ruling.fromJson(Map<String, Object?> json) => _$RulingFromJson(json);
  
  final RulingVerdict verdict;
  final int impactAnalyst;
  final int impactFinal;
  final Multipliers multipliers;
  final String confidence;
  final Category category;

  /// Wire style, ≤90 chars, sentence case in the app (the tape uppercases it)
  final String headline;

  /// ≤280 chars
  final String analystNote;
  final DateTime ruledAt;

  /// Move from the curve m(d)
  final String priceMovePct;

  /// Set when the market is closed: the shock waits for the open
  final DateTime? landsAt;

  /// Price, decimal string, 2 dp
  final String? indicatedPrice;

  /// Set after an overturned appeal
  final String? correction;

  Map<String, Object?> toJson() => _$RulingToJson(this);
}
