// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum Action {
  @JsonValue('RETRY')
  retry('RETRY'),
  @JsonValue('REQUOTE')
  requote('REQUOTE'),
  @JsonValue('REDUCE_QUANTITY')
  reduceQuantity('REDUCE_QUANTITY'),
  @JsonValue('SELL_SOMETHING')
  sellSomething('SELL_SOMETHING'),
  @JsonValue('WAIT')
  wait('WAIT'),
  @JsonValue('SIGN_IN')
  signIn('SIGN_IN'),
  @JsonValue('UPDATE_APP')
  updateApp('UPDATE_APP'),
  @JsonValue('CONTACT_ADMIN')
  contactAdmin('CONTACT_ADMIN'),
  @JsonValue('NONE')
  none('NONE'),
  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const Action(this.json);

  factory Action.fromJson(String json) => values.firstWhere(
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
  static List<Action> get $valuesDefined => values.where((value) => value != $unknown).toList();
}
