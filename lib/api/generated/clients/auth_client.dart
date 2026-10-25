// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/auth_apple_request_body.dart';
import '../models/auth_email_start_request_body.dart';
import '../models/auth_email_verify_request_body.dart';
import '../models/auth_logout_request_body.dart';
import '../models/auth_refresh_request_body.dart';
import '../models/token_pair.dart';

part 'auth_client.g.dart';

@RestApi()
abstract class AuthClient {
  factory AuthClient(Dio dio, {String? baseUrl}) = _AuthClient;

  /// Email a 6-digit sign-in code.
  ///
  /// In development the code is printed to the server log instead of emailed.
  @POST('/auth/email/start')
  Future<void> postAuthEmailStart({
    @Header('Idempotency-Key') required String idempotencyKey,
    @Body() required AuthEmailStartRequestBody body,
  });

  /// Exchange the code for tokens
  @POST('/auth/email/verify')
  Future<TokenPair> postAuthEmailVerify({
    @Header('Idempotency-Key') required String idempotencyKey,
    @Body() required AuthEmailVerifyRequestBody body,
  });

  /// Sign in with Apple (needs the paid Apple program)
  @POST('/auth/apple')
  Future<TokenPair> postAuthApple({
    @Header('Idempotency-Key') required String idempotencyKey,
    @Body() required AuthAppleRequestBody body,
  });

  /// Rotate the token pair
  @POST('/auth/refresh')
  Future<TokenPair> postAuthRefresh({
    @Header('Idempotency-Key') required String idempotencyKey,
    @Body() required AuthRefreshRequestBody body,
  });

  /// Revoke this refresh-token family
  @POST('/auth/logout')
  Future<void> postAuthLogout({
    @Header('Idempotency-Key') required String idempotencyKey,
    @Body() required AuthLogoutRequestBody body,
  });
}
