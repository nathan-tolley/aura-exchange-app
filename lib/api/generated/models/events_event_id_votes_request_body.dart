// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'direction.dart';

part 'events_event_id_votes_request_body.g.dart';

@JsonSerializable()
class EventsEventIdVotesRequestBody {
  const EventsEventIdVotesRequestBody({
    required this.direction,
  });
  
  factory EventsEventIdVotesRequestBody.fromJson(Map<String, Object?> json) => _$EventsEventIdVotesRequestBodyFromJson(json);
  
  final Direction direction;

  Map<String, Object?> toJson() => _$EventsEventIdVotesRequestBodyToJson(this);
}
