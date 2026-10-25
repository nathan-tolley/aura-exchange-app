// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'position_side.dart';

part 'my_position.g.dart';

@JsonSerializable()
class MyPosition {
  const MyPosition({
    required this.side,
    required this.quantity,
  });
  
  factory MyPosition.fromJson(Map<String, Object?> json) => _$MyPositionFromJson(json);
  
  final PositionSide side;

  /// Share quantity, decimal string, up to 4 dp
  final String quantity;

  Map<String, Object?> toJson() => _$MyPositionToJson(this);
}
