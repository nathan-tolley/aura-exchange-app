// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'exchange.dart';

part 'get_exchanges_response.g.dart';

@JsonSerializable()
class GetExchangesResponse {
  const GetExchangesResponse({
    required this.items,
  });
  
  factory GetExchangesResponse.fromJson(Map<String, Object?> json) => _$GetExchangesResponseFromJson(json);
  
  final List<Exchange> items;

  Map<String, Object?> toJson() => _$GetExchangesResponseToJson(this);
}
