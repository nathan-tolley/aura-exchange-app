// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum Category {
  @JsonValue('EARNINGS_BEAT')
  earningsBeat('EARNINGS_BEAT'),
  @JsonValue('EARNINGS_MISS')
  earningsMiss('EARNINGS_MISS'),
  @JsonValue('SCANDAL')
  scandal('SCANDAL'),
  @JsonValue('PRODUCT_LAUNCH')
  productLaunch('PRODUCT_LAUNCH'),
  @JsonValue('MERGER')
  merger('MERGER'),
  @JsonValue('DIVESTITURE')
  divestiture('DIVESTITURE'),
  @JsonValue('GUIDANCE_CUT')
  guidanceCut('GUIDANCE_CUT'),
  @JsonValue('MANAGEMENT_SHAKEUP')
  managementShakeup('MANAGEMENT_SHAKEUP'),
  @JsonValue('REGULATORY_ACTION')
  regulatoryAction('REGULATORY_ACTION'),
  @JsonValue('LORE')
  lore('LORE'),
  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const Category(this.json);

  factory Category.fromJson(String json) => values.firstWhere(
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
  static List<Category> get $valuesDefined => values.where((value) => value != $unknown).toList();
}
