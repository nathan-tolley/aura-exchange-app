// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/blocks_request_body.dart';
import '../models/reports_request_body.dart';

part 'safety_client.g.dart';

@RestApi()
abstract class SafetyClient {
  factory SafetyClient(Dio dio, {String? baseUrl}) = _SafetyClient;

  /// Report an event, comment or member
  @POST('/reports')
  Future<void> postReports({
    @Header('Idempotency-Key') required String idempotencyKey,
    @Body() required ReportsRequestBody body,
  });

  /// Block a member
  @POST('/blocks')
  Future<void> postBlocks({
    @Header('Idempotency-Key') required String idempotencyKey,
    @Body() required BlocksRequestBody body,
  });
}
