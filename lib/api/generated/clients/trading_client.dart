// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/get_exchanges_exchange_id_orders_response.dart';
import '../models/order.dart';
import '../models/order_create.dart';
import '../models/portfolio.dart';
import '../models/position.dart';
import '../models/quote.dart';
import '../models/quote_request.dart';
import '../models/trade.dart';
import '../models/trade_request.dart';

part 'trading_client.g.dart';

@RestApi()
abstract class TradingClient {
  factory TradingClient(Dio dio, {String? baseUrl}) = _TradingClient;

  /// Price a market order (holds 15 s).
  ///
  /// Validation that would reject the trade (cash, size, short cap, closed, halted) happens here too, so the sheet can explain it before the slide.
  @POST('/quotes')
  Future<Quote> postQuotes({
    @Header('Idempotency-Key') required String idempotencyKey,
    @Body() required QuoteRequest body,
  });

  /// Execute a quote.
  ///
  /// 409 QUOTE_STALE carries oldPrice/newPrice; the app then requests a new quote with previousQuoteId.
  @POST('/trades')
  Future<Trade> postTrades({
    @Header('Idempotency-Key') required String idempotencyKey,
    @Body() required TradeRequest body,
  });

  /// Cash, positions and open orders
  @GET('/exchanges/{exchangeId}/portfolio')
  Future<Portfolio> getExchangesExchangeIdPortfolio({
    @Path('exchangeId') required String exchangeId,
  });

  /// One position (margin detail for shorts)
  @GET('/positions/{positionId}')
  Future<Position> getPositionsPositionId({
    @Path('positionId') required String positionId,
  });

  /// Close a whole position with a quote for its full size
  @POST('/positions/{positionId}/close')
  Future<Trade> postPositionsPositionIdClose({
    @Path('positionId') required String positionId,
    @Header('Idempotency-Key') required String idempotencyKey,
    @Body() required TradeRequest body,
  });

  /// Your orders
  @GET('/exchanges/{exchangeId}/orders')
  Future<GetExchangesExchangeIdOrdersResponse> getExchangesExchangeIdOrders({
    @Path('exchangeId') required String exchangeId,
    @Query('limit') int? limit = 30,
    @Query('status') String? status,
    @Query('cursor') String? cursor,
  });

  /// Place a limit, stop-loss or take-profit order
  @POST('/orders')
  Future<Order> postOrders({
    @Header('Idempotency-Key') required String idempotencyKey,
    @Body() required OrderCreate body,
  });

  /// Cancel a resting order
  @DELETE('/orders/{orderId}')
  Future<Order> deleteOrdersOrderId({
    @Path('orderId') required String orderId,
    @Header('Idempotency-Key') required String idempotencyKey,
  });

  /// Chapter 7: reset to A$2,000 with a badge
  @POST('/exchanges/{exchangeId}/bankruptcy')
  Future<Portfolio> postExchangesExchangeIdBankruptcy({
    @Path('exchangeId') required String exchangeId,
    @Header('Idempotency-Key') required String idempotencyKey,
  });
}
