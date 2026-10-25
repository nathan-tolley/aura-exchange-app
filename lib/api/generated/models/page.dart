// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'page.g.dart';

@JsonSerializable()
class Page {
  const Page({
    required this.nextCursor,
  });
  
  factory Page.fromJson(Map<String, Object?> json) => _$PageFromJson(json);
  
  final String? nextCursor;

  Map<String, Object?> toJson() => _$PageToJson(this);
}
