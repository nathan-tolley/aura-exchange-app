// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'invite_preview_status.dart';
import 'listing_ref.dart';

part 'invite_preview.g.dart';

@JsonSerializable()
class InvitePreview {
  const InvitePreview({
    required this.code,
    required this.exchangeName,
    required this.listed,
    required this.memberCount,
    required this.expiresAt,
    required this.status,
  });
  
  factory InvitePreview.fromJson(Map<String, Object?> json) => _$InvitePreviewFromJson(json);
  
  final String code;
  final String exchangeName;
  final List<ListingRef> listed;
  final int memberCount;
  final DateTime expiresAt;
  final InvitePreviewStatus status;

  Map<String, Object?> toJson() => _$InvitePreviewToJson(this);
}
