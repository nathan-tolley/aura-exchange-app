// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/event.dart';
import '../models/event_create.dart';
import '../models/events_event_id_appeal_request_body.dart';
import '../models/events_event_id_reactions_request_body.dart';
import '../models/events_event_id_statement_request_body.dart';
import '../models/events_event_id_votes_request_body.dart';
import '../models/get_exchanges_exchange_id_events_response.dart';
import '../models/halt.dart';
import '../models/halts_halt_id_votes_request_body.dart';
import '../models/upload.dart';
import '../models/upload_request.dart';

part 'events_client.g.dart';

@RestApi()
abstract class EventsClient {
  factory EventsClient(Dio dio, {String? baseUrl}) = _EventsClient;

  /// Get a signed URL for a receipt
  @POST('/uploads')
  Future<Upload> postUploads({
    @Header('Idempotency-Key') required String idempotencyKey,
    @Body() required UploadRequest body,
  });

  /// File an event (starts in SENDING for 30 s)
  @POST('/events')
  Future<Event> postEvents({
    @Header('Idempotency-Key') required String idempotencyKey,
    @Body() required EventCreate body,
  });

  /// An event and its status
  @GET('/events/{eventId}')
  Future<Event> getEventsEventId({
    @Path('eventId') required String eventId,
  });

  /// Cancel during the 30-second SENDING window
  @POST('/events/{eventId}/unsend')
  Future<Event> postEventsEventIdUnsend({
    @Path('eventId') required String eventId,
    @Header('Idempotency-Key') required String idempotencyKey,
  });

  /// Co-sign or cap a rumor (or withdraw).
  ///
  /// Co-signing makes you an insider until 30 min after the ruling.
  @POST('/events/{eventId}/reactions')
  Future<Event> postEventsEventIdReactions({
    @Path('eventId') required String eventId,
    @Header('Idempotency-Key') required String idempotencyKey,
    @Body() required EventsEventIdReactionsRequestBody body,
  });

  /// Subject's response during the rumor
  @POST('/events/{eventId}/statement')
  Future<Event> postEventsEventIdStatement({
    @Path('eventId') required String eventId,
    @Header('Idempotency-Key') required String idempotencyKey,
    @Body() required EventsEventIdStatementRequestBody body,
  });

  /// Up/down vote a ruling (2 h)
  @POST('/events/{eventId}/votes')
  Future<Event> postEventsEventIdVotes({
    @Path('eventId') required String eventId,
    @Header('Idempotency-Key') required String idempotencyKey,
    @Body() required EventsEventIdVotesRequestBody body,
  });

  /// News-halt vote
  @POST('/halts/{haltId}/votes')
  Future<Halt> postHaltsHaltIdVotes({
    @Path('haltId') required String haltId,
    @Header('Idempotency-Key') required String idempotencyKey,
    @Body() required HaltsHaltIdVotesRequestBody body,
  });

  /// Subject appeals within 7 days
  @POST('/events/{eventId}/appeal')
  Future<Event> postEventsEventIdAppeal({
    @Path('eventId') required String eventId,
    @Header('Idempotency-Key') required String idempotencyKey,
    @Body() required EventsEventIdAppealRequestBody body,
  });

  /// Super-injunction: hide the story, keep the price impact
  @POST('/events/{eventId}/injunction')
  Future<Event> postEventsEventIdInjunction({
    @Path('eventId') required String eventId,
    @Header('Idempotency-Key') required String idempotencyKey,
  });

  /// Events, newest first (filter by listing or status)
  @GET('/exchanges/{exchangeId}/events')
  Future<GetExchangesExchangeIdEventsResponse> getExchangesExchangeIdEvents({
    @Path('exchangeId') required String exchangeId,
    @Query('limit') int? limit = 30,
    @Query('listingId') String? listingId,
    @Query('status') String? status,
    @Query('cursor') String? cursor,
  });
}
