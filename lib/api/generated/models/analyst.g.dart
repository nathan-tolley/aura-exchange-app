// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analyst.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Analyst _$AnalystFromJson(Map<String, dynamic> json) => Analyst(
  rating: Rating.fromJson(json['rating'] as String),
  priceTarget: json['priceTarget'] as String,
  note: json['note'] as String,
);

Map<String, dynamic> _$AnalystToJson(Analyst instance) => <String, dynamic>{
  'rating': instance.rating,
  'priceTarget': instance.priceTarget,
  'note': instance.note,
};
