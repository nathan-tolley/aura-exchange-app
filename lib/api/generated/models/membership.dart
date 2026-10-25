// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'listing_ref.dart';
import 'membership_badges.dart';
import 'role.dart';

part 'membership.g.dart';

@JsonSerializable()
class Membership {
  const Membership({
    required this.id,
    required this.exchangeId,
    required this.role,
    required this.listing,
    required this.listingConsentAt,
    required this.joinedAt,
    required this.badges,
    required this.superInjunctionsLeft,
  });
  
  factory Membership.fromJson(Map<String, Object?> json) => _$MembershipFromJson(json);
  
  final String id;
  final String exchangeId;
  final Role role;
  @JsonKey(includeIfNull: true)
  final ListingRef? listing;
  @JsonKey(includeIfNull: true)
  final DateTime? listingConsentAt;
  final DateTime joinedAt;
  final List<MembershipBadges> badges;
  final int superInjunctionsLeft;

  Map<String, Object?> toJson() => _$MembershipToJson(this);
}
