// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

/// Additive: the app maps unknown codes to a generic error screen
@JsonEnum()
enum ErrorCode {
  @JsonValue('VALIDATION')
  validation('VALIDATION'),
  @JsonValue('AUTH_EXPIRED')
  authExpired('AUTH_EXPIRED'),
  @JsonValue('LOGIN_CODE_INVALID')
  loginCodeInvalid('LOGIN_CODE_INVALID'),
  @JsonValue('LOGIN_CODE_EXPIRED')
  loginCodeExpired('LOGIN_CODE_EXPIRED'),
  @JsonValue('FORBIDDEN')
  forbidden('FORBIDDEN'),
  @JsonValue('NOT_A_MEMBER')
  notAMember('NOT_A_MEMBER'),
  @JsonValue('SELF_TRADE')
  selfTrade('SELF_TRADE'),
  @JsonValue('NOT_FOUND')
  notFound('NOT_FOUND'),
  @JsonValue('CONFLICT')
  conflict('CONFLICT'),
  @JsonValue('QUOTE_STALE')
  quoteStale('QUOTE_STALE'),
  @JsonValue('IDEMPOTENCY_MISMATCH')
  idempotencyMismatch('IDEMPOTENCY_MISMATCH'),
  @JsonValue('IDEMPOTENCY_IN_PROGRESS')
  idempotencyInProgress('IDEMPOTENCY_IN_PROGRESS'),
  @JsonValue('INVITE_EXPIRED')
  inviteExpired('INVITE_EXPIRED'),
  @JsonValue('EXCHANGE_FULL')
  exchangeFull('EXCHANGE_FULL'),
  @JsonValue('TICKER_TAKEN')
  tickerTaken('TICKER_TAKEN'),
  @JsonValue('TRADING_NOT_OPEN')
  tradingNotOpen('TRADING_NOT_OPEN'),
  @JsonValue('LISTING_HALTED')
  listingHalted('LISTING_HALTED'),
  @JsonValue('MARKET_CLOSED')
  marketClosed('MARKET_CLOSED'),
  @JsonValue('ORDER_TYPE_NOT_ALLOWED')
  orderTypeNotAllowed('ORDER_TYPE_NOT_ALLOWED'),
  @JsonValue('INSUFFICIENT_CASH')
  insufficientCash('INSUFFICIENT_CASH'),
  @JsonValue('INSUFFICIENT_SHARES')
  insufficientShares('INSUFFICIENT_SHARES'),
  @JsonValue('ORDER_TOO_LARGE')
  orderTooLarge('ORDER_TOO_LARGE'),
  @JsonValue('SHORT_CAP')
  shortCap('SHORT_CAP'),
  @JsonValue('OPPOSITE_POSITION')
  oppositePosition('OPPOSITE_POSITION'),
  @JsonValue('EQUITY_TOO_LOW')
  equityTooLow('EQUITY_TOO_LOW'),
  @JsonValue('DAILY_FILING_LIMIT')
  dailyFilingLimit('DAILY_FILING_LIMIT'),
  @JsonValue('UNSEND_EXPIRED')
  unsendExpired('UNSEND_EXPIRED'),
  @JsonValue('UPDATE_REQUIRED')
  updateRequired('UPDATE_REQUIRED'),
  @JsonValue('RATE_LIMITED')
  rateLimited('RATE_LIMITED'),
  @JsonValue('SERVER')
  server('SERVER'),
  @JsonValue('MAINTENANCE')
  maintenance('MAINTENANCE'),
  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const ErrorCode(this.json);

  factory ErrorCode.fromJson(String json) => values.firstWhere(
        (e) => e.json == json,
        orElse: () => $unknown,
      );

  final String? json;
  String toJson() {
    final value = json;
    if (value == null) {
      throw StateError('Cannot convert enum value with null JSON representation to String. '
          'This usually happens for \$unknown or @JsonValue(null) entries.');
    }
    return value as String;
  }

  @override
  String toString() => json?.toString() ?? super.toString();
  /// Returns all defined enum values excluding the $unknown value.
  static List<ErrorCode> get $valuesDefined => values.where((value) => value != $unknown).toList();
}
