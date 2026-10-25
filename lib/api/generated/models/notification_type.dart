// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum NotificationType {
  @JsonValue('RUMOR_ABOUT_YOU')
  rumorAboutYou('RUMOR_ABOUT_YOU'),
  @JsonValue('RULING_ABOUT_YOU')
  rulingAboutYou('RULING_ABOUT_YOU'),
  @JsonValue('HOLDING_MOVED')
  holdingMoved('HOLDING_MOVED'),
  @JsonValue('MARGIN_WARNING')
  marginWarning('MARGIN_WARNING'),
  @JsonValue('LIQUIDATED')
  liquidated('LIQUIDATED'),
  @JsonValue('HALT_VOTE')
  haltVote('HALT_VOTE'),
  @JsonValue('ORDER_FILLED')
  orderFilled('ORDER_FILLED'),
  @JsonValue('SEC_CHARGE')
  secCharge('SEC_CHARGE'),
  @JsonValue('PRICE_ALERT')
  priceAlert('PRICE_ALERT'),
  @JsonValue('BELL')
  bell('BELL'),
  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const NotificationType(this.json);

  factory NotificationType.fromJson(String json) => values.firstWhere(
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
  static List<NotificationType> get $valuesDefined => values.where((value) => value != $unknown).toList();
}
