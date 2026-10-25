// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'kind2.dart';

part 'events_event_id_statement_request_body.g.dart';

@JsonSerializable()
class EventsEventIdStatementRequestBody {
  const EventsEventIdStatementRequestBody({
    required this.kind,
  });
  
  factory EventsEventIdStatementRequestBody.fromJson(Map<String, Object?> json) => _$EventsEventIdStatementRequestBodyFromJson(json);
  
  final Kind2 kind;

  Map<String, Object?> toJson() => _$EventsEventIdStatementRequestBodyToJson(this);
}
