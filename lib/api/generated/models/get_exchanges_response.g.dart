// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_exchanges_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetExchangesResponse _$GetExchangesResponseFromJson(
  Map<String, dynamic> json,
) => GetExchangesResponse(
  items: (json['items'] as List<dynamic>)
      .map((e) => Exchange.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$GetExchangesResponseToJson(
  GetExchangesResponse instance,
) => <String, dynamic>{'items': instance.items};
