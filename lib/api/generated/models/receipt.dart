// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'receipt_kind.dart';

part 'receipt.g.dart';

@JsonSerializable()
class Receipt {
  const Receipt({
    required this.id,
    required this.kind,
    required this.url,
    this.width,
    this.height,
  });
  
  factory Receipt.fromJson(Map<String, Object?> json) => _$ReceiptFromJson(json);
  
  final String id;
  final ReceiptKind kind;

  /// Signed, short-lived
  final String url;
  final int? width;
  final int? height;

  Map<String, Object?> toJson() => _$ReceiptToJson(this);
}
