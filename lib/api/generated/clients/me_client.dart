// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/devices_request_body.dart';
import '../models/get_me_notifications_response.dart';
import '../models/me.dart';
import '../models/me_notifications_read_request_body.dart';
import '../models/me_request_body.dart';
import '../models/notification_prefs.dart';
import '../models/user.dart';

part 'me_client.g.dart';

@RestApi()
abstract class MeClient {
  factory MeClient(Dio dio, {String? baseUrl}) = _MeClient;

  /// You and your memberships
  @GET('/me')
  Future<Me> getMe();

  /// Update your display name
  @PATCH('/me')
  Future<User> patchMe({
    @Header('Idempotency-Key') required String idempotencyKey,
    @Body() required MeRequestBody body,
  });

  /// Notification inbox (push comes later)
  @GET('/me/notifications')
  Future<GetMeNotificationsResponse> getMeNotifications({
    @Query('limit') int? limit = 30,
    @Query('cursor') String? cursor,
    @Query('exchangeId') String? exchangeId,
  });

  /// Mark notifications read
  @POST('/me/notifications/read')
  Future<void> postMeNotificationsRead({
    @Header('Idempotency-Key') required String idempotencyKey,
    @Body() required MeNotificationsReadRequestBody body,
  });

  /// Notification settings
  @GET('/me/notification-prefs')
  Future<NotificationPrefs> getMeNotificationPrefs();

  /// Change notification settings
  @PATCH('/me/notification-prefs')
  Future<NotificationPrefs> patchMeNotificationPrefs({
    @Header('Idempotency-Key') required String idempotencyKey,
    @Body() required NotificationPrefs body,
  });

  /// Register an APNs token
  @POST('/devices')
  Future<void> postDevices({
    @Header('Idempotency-Key') required String idempotencyKey,
    @Body() required DevicesRequestBody body,
  });
}
