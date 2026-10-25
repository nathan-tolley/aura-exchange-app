// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'traders.dart';
import 'stocks.dart';

part 'get_exchanges_exchange_id_leaderboards_response.g.dart';

@JsonSerializable()
class GetExchangesExchangeIdLeaderboardsResponse {
  const GetExchangesExchangeIdLeaderboardsResponse({
    this.traders,
    this.stocks,
  });
  
  factory GetExchangesExchangeIdLeaderboardsResponse.fromJson(Map<String, Object?> json) => _$GetExchangesExchangeIdLeaderboardsResponseFromJson(json);
  
  final List<Traders>? traders;
  final List<Stocks>? stocks;

  Map<String, Object?> toJson() => _$GetExchangesExchangeIdLeaderboardsResponseToJson(this);
}
