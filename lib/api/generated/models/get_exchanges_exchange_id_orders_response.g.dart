// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_exchanges_exchange_id_orders_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetExchangesExchangeIdOrdersResponse
_$GetExchangesExchangeIdOrdersResponseFromJson(Map<String, dynamic> json) =>
    GetExchangesExchangeIdOrdersResponse(
      nextCursor: json['nextCursor'] as String?,
      items: (json['items'] as List<dynamic>)
          .map((e) => Order.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GetExchangesExchangeIdOrdersResponseToJson(
  GetExchangesExchangeIdOrdersResponse instance,
) => <String, dynamic>{
  'nextCursor': instance.nextCursor,
  'items': instance.items,
};
