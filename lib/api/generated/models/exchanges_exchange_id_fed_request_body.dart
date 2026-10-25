// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'exchanges_exchange_id_fed_request_body.g.dart';

@JsonSerializable()
class ExchangesExchangeIdFedRequestBody {
  const ExchangesExchangeIdFedRequestBody({
    this.borrowRateDailyPct,
    this.allowance,
  });
  
  factory ExchangesExchangeIdFedRequestBody.fromJson(Map<String, Object?> json) => _$ExchangesExchangeIdFedRequestBodyFromJson(json);
  
  /// Percent units, decimal string, 2 dp (−12.19 = −12.19%)
  @JsonKey(includeIfNull: false)
  final String? borrowRateDailyPct;

  /// Aura Bucks, decimal string, 2 dp
  @JsonKey(includeIfNull: false)
  final String? allowance;

  Map<String, Object?> toJson() => _$ExchangesExchangeIdFedRequestBodyToJson(this);
}
