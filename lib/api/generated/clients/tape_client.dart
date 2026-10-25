// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/get_exchanges_exchange_id_leaderboards_response.dart';
import '../models/get_exchanges_exchange_id_tape_response.dart';

part 'tape_client.g.dart';

@RestApi()
abstract class TapeClient {
  factory TapeClient(Dio dio, {String? baseUrl}) = _TapeClient;

  /// The tape
  @GET('/exchanges/{exchangeId}/tape')
  Future<GetExchangesExchangeIdTapeResponse> getExchangesExchangeIdTape({
    @Path('exchangeId') required String exchangeId,
    @Query('limit') int? limit = 30,
    @Query('listingId') String? listingId,
    @Query('types') String? types,
    @Query('cursor') String? cursor,
  });

  /// Season leaders
  @GET('/exchanges/{exchangeId}/leaderboards')
  Future<GetExchangesExchangeIdLeaderboardsResponse> getExchangesExchangeIdLeaderboards({
    @Path('exchangeId') required String exchangeId,
  });
}
