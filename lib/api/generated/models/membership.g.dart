// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'membership.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Membership _$MembershipFromJson(Map<String, dynamic> json) => Membership(
  id: json['id'] as String,
  exchangeId: json['exchangeId'] as String,
  role: Role.fromJson(json['role'] as String),
  listing: json['listing'] == null
      ? null
      : ListingRef.fromJson(json['listing'] as Map<String, dynamic>),
  listingConsentAt: json['listingConsentAt'] == null
      ? null
      : DateTime.parse(json['listingConsentAt'] as String),
  joinedAt: DateTime.parse(json['joinedAt'] as String),
  badges: (json['badges'] as List<dynamic>)
      .map((e) => MembershipBadges.fromJson(e as String))
      .toList(),
  superInjunctionsLeft: (json['superInjunctionsLeft'] as num).toInt(),
);

Map<String, dynamic> _$MembershipToJson(Membership instance) =>
    <String, dynamic>{
      'id': instance.id,
      'exchangeId': instance.exchangeId,
      'role': instance.role,
      'listing': instance.listing,
      'listingConsentAt': instance.listingConsentAt?.toIso8601String(),
      'joinedAt': instance.joinedAt.toIso8601String(),
      'badges': instance.badges,
      'superInjunctionsLeft': instance.superInjunctionsLeft,
    };
