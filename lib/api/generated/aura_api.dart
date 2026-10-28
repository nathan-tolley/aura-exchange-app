// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';

import 'clients/system_client.dart';
import 'clients/auth_client.dart';
import 'clients/me_client.dart';
import 'clients/exchanges_client.dart';
import 'clients/market_data_client.dart';
import 'clients/trading_client.dart';
import 'clients/events_client.dart';
import 'clients/tape_client.dart';
import 'clients/safety_client.dart';
import 'clients/realtime_client.dart';

/// Aura Exchange API `v1.0.0-draft.7`.
///
/// The v1 contract between the iPhone app and the server. Rules that apply everywhere (money as strings, freshness, errors, statuses, realtime, idempotency) are in API-CONTRACT.md. Every operation is tagged x-phase.
class AuraApi {
  AuraApi(
    Dio dio, {
    String? baseUrl,
  })  : _dio = dio,
        _baseUrl = baseUrl;

  final Dio _dio;
  final String? _baseUrl;

  static String get version => '1.0.0-draft.7';

  SystemClient? _system;
  AuthClient? _auth;
  MeClient? _me;
  ExchangesClient? _exchanges;
  MarketDataClient? _marketData;
  TradingClient? _trading;
  EventsClient? _events;
  TapeClient? _tape;
  SafetyClient? _safety;
  RealtimeClient? _realtime;

  SystemClient get system => _system ??= SystemClient(_dio, baseUrl: _baseUrl);

  AuthClient get auth => _auth ??= AuthClient(_dio, baseUrl: _baseUrl);

  MeClient get me => _me ??= MeClient(_dio, baseUrl: _baseUrl);

  ExchangesClient get exchanges => _exchanges ??= ExchangesClient(_dio, baseUrl: _baseUrl);

  MarketDataClient get marketData => _marketData ??= MarketDataClient(_dio, baseUrl: _baseUrl);

  TradingClient get trading => _trading ??= TradingClient(_dio, baseUrl: _baseUrl);

  EventsClient get events => _events ??= EventsClient(_dio, baseUrl: _baseUrl);

  TapeClient get tape => _tape ??= TapeClient(_dio, baseUrl: _baseUrl);

  SafetyClient get safety => _safety ??= SafetyClient(_dio, baseUrl: _baseUrl);

  RealtimeClient get realtime => _realtime ??= RealtimeClient(_dio, baseUrl: _baseUrl);
}
