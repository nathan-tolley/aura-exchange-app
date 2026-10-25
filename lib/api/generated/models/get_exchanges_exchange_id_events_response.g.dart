// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_exchanges_exchange_id_events_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetExchangesExchangeIdEventsResponse
_$GetExchangesExchangeIdEventsResponseFromJson(Map<String, dynamic> json) =>
    GetExchangesExchangeIdEventsResponse(
      nextCursor: json['nextCursor'] as String?,
      items: (json['items'] as List<dynamic>)
          .map((e) => EventSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GetExchangesExchangeIdEventsResponseToJson(
  GetExchangesExchangeIdEventsResponse instance,
) => <String, dynamic>{
  'nextCursor': instance.nextCursor,
  'items': instance.items,
};
