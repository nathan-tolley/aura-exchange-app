// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ruling.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Ruling _$RulingFromJson(Map<String, dynamic> json) => Ruling(
  verdict: RulingVerdict.fromJson(json['verdict'] as String),
  impactAnalyst: (json['impactAnalyst'] as num).toInt(),
  impactFinal: (json['impactFinal'] as num).toInt(),
  multipliers: Multipliers.fromJson(
    json['multipliers'] as Map<String, dynamic>,
  ),
  confidence: json['confidence'] as String,
  category: Category.fromJson(json['category'] as String),
  headline: json['headline'] as String,
  analystNote: json['analystNote'] as String,
  ruledAt: DateTime.parse(json['ruledAt'] as String),
  priceMovePct: json['priceMovePct'] as String,
  landsAt: json['landsAt'] == null
      ? null
      : DateTime.parse(json['landsAt'] as String),
  indicatedPrice: json['indicatedPrice'] as String?,
  correction: json['correction'] as String?,
);

Map<String, dynamic> _$RulingToJson(Ruling instance) => <String, dynamic>{
  'verdict': instance.verdict,
  'impactAnalyst': instance.impactAnalyst,
  'impactFinal': instance.impactFinal,
  'multipliers': instance.multipliers,
  'confidence': instance.confidence,
  'category': instance.category,
  'headline': instance.headline,
  'analystNote': instance.analystNote,
  'ruledAt': instance.ruledAt.toIso8601String(),
  'priceMovePct': instance.priceMovePct,
  'landsAt': instance.landsAt?.toIso8601String(),
  'indicatedPrice': instance.indicatedPrice,
  'correction': instance.correction,
};
