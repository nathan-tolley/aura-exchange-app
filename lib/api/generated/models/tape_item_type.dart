// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum TapeItemType {
  @JsonValue('IPO')
  ipo('IPO'),
  @JsonValue('RUMOR')
  rumor('RUMOR'),
  @JsonValue('RULING')
  ruling('RULING'),
  @JsonValue('HALT')
  halt('HALT'),
  @JsonValue('HALT_RESULT')
  haltResult('HALT_RESULT'),
  @JsonValue('WHALE')
  whale('WHALE'),
  @JsonValue('LIQUIDATION')
  liquidation('LIQUIDATION'),
  @JsonValue('CORRECTION')
  correction('CORRECTION'),
  @JsonValue('BELL')
  bell('BELL'),
  @JsonValue('SEC')
  sec('SEC'),
  @JsonValue('EARNINGS')
  earnings('EARNINGS'),
  @JsonValue('RATING')
  rating('RATING'),
  @JsonValue('FED')
  fed('FED'),
  @JsonValue('SPLIT')
  split('SPLIT'),
  @JsonValue('CHAPTER_11')
  chapter11('CHAPTER_11'),
  @JsonValue('BANKRUPTCY')
  bankruptcy('BANKRUPTCY'),
  @JsonValue('DELISTING')
  delisting('DELISTING'),
  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const TapeItemType(this.json);

  factory TapeItemType.fromJson(String json) => values.firstWhere(
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
  static List<TapeItemType> get $valuesDefined => values.where((value) => value != $unknown).toList();
}
