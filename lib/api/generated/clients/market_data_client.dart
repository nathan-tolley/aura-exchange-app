// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/candle_series.dart';
import '../models/listing_detail.dart';
import '../models/market.dart';
import '../models/range.dart';

part 'market_data_client.g.dart';

@RestApi()
abstract class MarketDataClient {
  factory MarketDataClient(Dio dio, {String? baseUrl}) = _MarketDataClient;

  /// Every listing with price and today's sparkline
  @GET('/exchanges/{exchangeId}/market')
  Future<Market> getExchangesExchangeIdMarket({
    @Path('exchangeId') required String exchangeId,
  });

  /// Stock page
  @GET('/listings/{listingId}')
  Future<ListingDetail> getListingsListingId({
    @Path('listingId') required String listingId,
  });

  /// Chart data with event markers
  @GET('/listings/{listingId}/candles')
  Future<CandleSeries> getListingsListingIdCandles({
    @Path('listingId') required String listingId,
    @Query('range') Range? range = Range.value1d,
  });

  /// Aura Composite chart
  @GET('/exchanges/{exchangeId}/index/candles')
  Future<CandleSeries> getExchangesExchangeIdIndexCandles({
    @Path('exchangeId') required String exchangeId,
    @Query('range') Range? range = Range.value1d,
  });
}
