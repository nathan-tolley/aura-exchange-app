// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exchanges_exchange_id_fed_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExchangesExchangeIdFedRequestBody _$ExchangesExchangeIdFedRequestBodyFromJson(
  Map<String, dynamic> json,
) => ExchangesExchangeIdFedRequestBody(
  borrowRateDailyPct: json['borrowRateDailyPct'] as String?,
  allowance: json['allowance'] as String?,
);

Map<String, dynamic> _$ExchangesExchangeIdFedRequestBodyToJson(
  ExchangesExchangeIdFedRequestBody instance,
) => <String, dynamic>{
  'borrowRateDailyPct': ?instance.borrowRateDailyPct,
  'allowance': ?instance.allowance,
};
