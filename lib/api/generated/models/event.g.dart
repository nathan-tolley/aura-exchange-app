// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Event _$EventFromJson(Map<String, dynamic> json) => Event(
  id: json['id'] as String,
  exchangeId: json['exchangeId'] as String,
  subject: ListingRef.fromJson(json['subject'] as Map<String, dynamic>),
  status: EventStatus.fromJson(json['status'] as String),
  author: json['author'] == null
      ? null
      : ListingRef.fromJson(json['author'] as Map<String, dynamic>),
  isMine: json['isMine'] as bool,
  isAboutMe: json['isAboutMe'] as bool,
  isSelfFiled: json['isSelfFiled'] as bool,
  teaser: json['teaser'] as String,
  text: json['text'] as String?,
  receipts: (json['receipts'] as List<dynamic>)
      .map((e) => Receipt.fromJson(e as Map<String, dynamic>))
      .toList(),
  happenedAt: json['happenedAt'] == null
      ? null
      : DateTime.parse(json['happenedAt'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  unsendUntil: json['unsendUntil'] == null
      ? null
      : DateTime.parse(json['unsendUntil'] as String),
  rumorEndsAt: json['rumorEndsAt'] == null
      ? null
      : DateTime.parse(json['rumorEndsAt'] as String),
  reactions: Reactions.fromJson(json['reactions'] as Map<String, dynamic>),
  subjectStatement: json['subjectStatement'] == null
      ? null
      : EventSubjectStatement.fromJson(json['subjectStatement'] as String?),
  insiderUntil: json['insiderUntil'] == null
      ? null
      : DateTime.parse(json['insiderUntil'] as String),
  ruling: json['ruling'] == null
      ? null
      : Ruling.fromJson(json['ruling'] as Map<String, dynamic>),
  halt: json['halt'] == null
      ? null
      : Halt.fromJson(json['halt'] as Map<String, dynamic>),
  votes: json['votes'] == null
      ? null
      : Votes.fromJson(json['votes'] as Map<String, dynamic>),
  appeal: json['appeal'] == null
      ? null
      : Appeal.fromJson(json['appeal'] as Map<String, dynamic>),
  denialPenaltyPct: json['denialPenaltyPct'] as String,
);

Map<String, dynamic> _$EventToJson(Event instance) => <String, dynamic>{
  'id': instance.id,
  'exchangeId': instance.exchangeId,
  'subject': instance.subject,
  'status': instance.status,
  'author': instance.author,
  'isMine': instance.isMine,
  'isAboutMe': instance.isAboutMe,
  'isSelfFiled': instance.isSelfFiled,
  'teaser': instance.teaser,
  'text': instance.text,
  'receipts': instance.receipts,
  'happenedAt': instance.happenedAt?.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
  'unsendUntil': instance.unsendUntil?.toIso8601String(),
  'rumorEndsAt': instance.rumorEndsAt?.toIso8601String(),
  'reactions': instance.reactions,
  'subjectStatement': instance.subjectStatement,
  'insiderUntil': instance.insiderUntil?.toIso8601String(),
  'ruling': instance.ruling,
  'halt': instance.halt,
  'votes': instance.votes,
  'appeal': instance.appeal,
  'denialPenaltyPct': instance.denialPenaltyPct,
};
