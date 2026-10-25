// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_exchanges_exchange_id_leaderboards_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetExchangesExchangeIdLeaderboardsResponse
_$GetExchangesExchangeIdLeaderboardsResponseFromJson(
  Map<String, dynamic> json,
) => GetExchangesExchangeIdLeaderboardsResponse(
  traders: (json['traders'] as List<dynamic>?)
      ?.map((e) => Traders.fromJson(e as Map<String, dynamic>))
      .toList(),
  stocks: (json['stocks'] as List<dynamic>?)
      ?.map((e) => Stocks.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$GetExchangesExchangeIdLeaderboardsResponseToJson(
  GetExchangesExchangeIdLeaderboardsResponse instance,
) => <String, dynamic>{
  'traders': ?instance.traders,
  'stocks': ?instance.stocks,
};
