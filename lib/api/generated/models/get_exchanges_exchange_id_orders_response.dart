// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'order.dart';
import 'page.dart';

part 'get_exchanges_exchange_id_orders_response.g.dart';

@JsonSerializable()
class GetExchangesExchangeIdOrdersResponse {
  const GetExchangesExchangeIdOrdersResponse({
    required this.nextCursor,
    required this.items,
  });
  
  factory GetExchangesExchangeIdOrdersResponse.fromJson(Map<String, Object?> json) => _$GetExchangesExchangeIdOrdersResponseFromJson(json);
  
  @JsonKey(includeIfNull: true)
  final String? nextCursor;
  final List<Order> items;

  Map<String, Object?> toJson() => _$GetExchangesExchangeIdOrdersResponseToJson(this);
}
