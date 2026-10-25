// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'event_summary.dart';
import 'page.dart';

part 'get_exchanges_exchange_id_events_response.g.dart';

@JsonSerializable()
class GetExchangesExchangeIdEventsResponse {
  const GetExchangesExchangeIdEventsResponse({
    required this.nextCursor,
    required this.items,
  });
  
  factory GetExchangesExchangeIdEventsResponse.fromJson(Map<String, Object?> json) => _$GetExchangesExchangeIdEventsResponseFromJson(json);
  
  @JsonKey(includeIfNull: true)
  final String? nextCursor;
  final List<EventSummary> items;

  Map<String, Object?> toJson() => _$GetExchangesExchangeIdEventsResponseToJson(this);
}
