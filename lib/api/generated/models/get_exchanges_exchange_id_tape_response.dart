// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'page.dart';
import 'tape_item.dart';

part 'get_exchanges_exchange_id_tape_response.g.dart';

@JsonSerializable()
class GetExchangesExchangeIdTapeResponse {
  const GetExchangesExchangeIdTapeResponse({
    required this.nextCursor,
    required this.items,
  });
  
  factory GetExchangesExchangeIdTapeResponse.fromJson(Map<String, Object?> json) => _$GetExchangesExchangeIdTapeResponseFromJson(json);
  
  @JsonKey(includeIfNull: true)
  final String? nextCursor;
  final List<TapeItem> items;

  Map<String, Object?> toJson() => _$GetExchangesExchangeIdTapeResponseToJson(this);
}
