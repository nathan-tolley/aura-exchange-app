// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'ticker_check.g.dart';

@JsonSerializable()
class TickerCheck {
  const TickerCheck({
    required this.ticker,
    required this.available,
    required this.suggestions,
  });
  
  factory TickerCheck.fromJson(Map<String, Object?> json) => _$TickerCheckFromJson(json);
  
  final String ticker;
  final bool available;
  final List<String> suggestions;

  Map<String, Object?> toJson() => _$TickerCheckToJson(this);
}
