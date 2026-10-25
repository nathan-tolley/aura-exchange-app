// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/exchange.dart';
import '../models/exchange_create.dart';
import '../models/exchange_settings.dart';
import '../models/exchanges_exchange_id_fed_request_body.dart';
import '../models/get_exchanges_response.dart';
import '../models/invite.dart';
import '../models/invite_preview.dart';
import '../models/ipo_request.dart';
import '../models/listing_ref.dart';
import '../models/membership.dart';
import '../models/tape_item.dart';
import '../models/ticker_check.dart';

part 'exchanges_client.g.dart';

@RestApi()
abstract class ExchangesClient {
  factory ExchangesClient(Dio dio, {String? baseUrl}) = _ExchangesClient;

  /// Your exchanges
  @GET('/exchanges')
  Future<GetExchangesResponse> getExchanges();

  /// Create an exchange (you become its admin)
  @POST('/exchanges')
  Future<Exchange> postExchanges({
    @Header('Idempotency-Key') required String idempotencyKey,
    @Body() required ExchangeCreate body,
  });

  /// One exchange
  @GET('/exchanges/{exchangeId}')
  Future<Exchange> getExchangesExchangeId({
    @Path('exchangeId') required String exchangeId,
  });

  /// Admin: change settings
  @PATCH('/exchanges/{exchangeId}/settings')
  Future<Exchange> patchExchangesExchangeIdSettings({
    @Path('exchangeId') required String exchangeId,
    @Header('Idempotency-Key') required String idempotencyKey,
    @Body() required ExchangeSettings body,
  });

  /// Create an invite link
  @POST('/exchanges/{exchangeId}/invites')
  Future<Invite> postExchangesExchangeIdInvites({
    @Path('exchangeId') required String exchangeId,
    @Header('Idempotency-Key') required String idempotencyKey,
  });

  /// Preview an invite before joining
  @GET('/invites/{code}')
  Future<InvitePreview> getInvitesCode({
    @Path('code') required String code,
  });

  /// Join the exchange
  @POST('/invites/{code}/accept')
  Future<Membership> postInvitesCodeAccept({
    @Path('code') required String code,
    @Header('Idempotency-Key') required String idempotencyKey,
  });

  /// Is a ticker free?
  @GET('/exchanges/{exchangeId}/tickers/check')
  Future<TickerCheck> getExchangesExchangeIdTickersCheck({
    @Path('exchangeId') required String exchangeId,
    @Query('ticker') required String ticker,
  });

  /// Your IPO: consent and pick a ticker
  @POST('/exchanges/{exchangeId}/listing')
  Future<ListingRef> postExchangesExchangeIdListing({
    @Path('exchangeId') required String exchangeId,
    @Header('Idempotency-Key') required String idempotencyKey,
    @Body() required IpoRequest body,
  });

  /// Opt out: delist yourself (holders cashed out at last price)
  @DELETE('/exchanges/{exchangeId}/listing')
  Future<void> deleteExchangesExchangeIdListing({
    @Path('exchangeId') required String exchangeId,
    @Header('Idempotency-Key') required String idempotencyKey,
  });

  /// Admin: set borrow rate / allowance (writes a Fed statement)
  @POST('/exchanges/{exchangeId}/fed')
  Future<TapeItem> postExchangesExchangeIdFed({
    @Path('exchangeId') required String exchangeId,
    @Header('Idempotency-Key') required String idempotencyKey,
    @Body() required ExchangesExchangeIdFedRequestBody body,
  });
}
