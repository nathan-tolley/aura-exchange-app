// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invite_preview.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InvitePreview _$InvitePreviewFromJson(Map<String, dynamic> json) =>
    InvitePreview(
      code: json['code'] as String,
      exchangeName: json['exchangeName'] as String,
      listed: (json['listed'] as List<dynamic>)
          .map((e) => ListingRef.fromJson(e as Map<String, dynamic>))
          .toList(),
      memberCount: (json['memberCount'] as num).toInt(),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      status: InvitePreviewStatus.fromJson(json['status'] as String),
    );

Map<String, dynamic> _$InvitePreviewToJson(InvitePreview instance) =>
    <String, dynamic>{
      'code': instance.code,
      'exchangeName': instance.exchangeName,
      'listed': instance.listed,
      'memberCount': instance.memberCount,
      'expiresAt': instance.expiresAt.toIso8601String(),
      'status': instance.status,
    };
