// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_exchanges_exchange_id_tape_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetExchangesExchangeIdTapeResponse _$GetExchangesExchangeIdTapeResponseFromJson(
  Map<String, dynamic> json,
) => GetExchangesExchangeIdTapeResponse(
  nextCursor: json['nextCursor'] as String?,
  items: (json['items'] as List<dynamic>)
      .map((e) => TapeItem.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$GetExchangesExchangeIdTapeResponseToJson(
  GetExchangesExchangeIdTapeResponse instance,
) => <String, dynamic>{
  'nextCursor': instance.nextCursor,
  'items': instance.items,
};
