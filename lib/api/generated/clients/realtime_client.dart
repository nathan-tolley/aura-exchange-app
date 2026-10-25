// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'realtime_client.g.dart';

@RestApi()
abstract class RealtimeClient {
  factory RealtimeClient(Dio dio, {String? baseUrl}) = _RealtimeClient;

  /// WebSocket upgrade: ticks, tape, status, notifications.
  ///
  /// See API-CONTRACT.md → Realtime for the message shapes. Returns 101 Switching Protocols.
  @GET('/stream')
  Future<dynamic> getStream({
    @Query('access_token') required String accessToken,
  });
}
