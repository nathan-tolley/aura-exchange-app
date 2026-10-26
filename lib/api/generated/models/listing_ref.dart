// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'listing_ref.g.dart';

@JsonSerializable()
class ListingRef {
  const ListingRef({
    required this.id,
    required this.ticker,
    required this.displayName,
    required this.avatarUrl,
  });
  
  factory ListingRef.fromJson(Map<String, Object?> json) => _$ListingRefFromJson(json);
  
  final String id;

  /// Always uppercase with $
  final String ticker;
  final String displayName;
  @JsonKey(includeIfNull: true)
  final String? avatarUrl;

  Map<String, Object?> toJson() => _$ListingRefToJson(this);
}
