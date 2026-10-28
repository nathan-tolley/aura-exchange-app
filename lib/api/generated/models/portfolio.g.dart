// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'portfolio.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Portfolio _$PortfolioFromJson(Map<String, dynamic> json) => Portfolio(
  asOf: DateTime.parse(json['asOf'] as String),
  marketState: MarketState.fromJson(json['marketState'] as String),
  nextChangeAt: json['nextChangeAt'] == null
      ? null
      : DateTime.parse(json['nextChangeAt'] as String),
  exchangeId: json['exchangeId'] as String,
  cash: json['cash'] as String,
  reservedCash: json['reservedCash'] as String,
  netWorth: json['netWorth'] as String,
  seasonChangeAbs: json['seasonChangeAbs'] as String,
  seasonChangePct: json['seasonChangePct'] as String,
  dayChangeAbs: json['dayChangeAbs'] as String,
  dayChangePct: json['dayChangePct'] as String,
  positions: (json['positions'] as List<dynamic>)
      .map((e) => Position.fromJson(e as Map<String, dynamic>))
      .toList(),
  openOrders: (json['openOrders'] as List<dynamic>)
      .map((e) => Order.fromJson(e as Map<String, dynamic>))
      .toList(),
  canDeclareBankruptcy: json['canDeclareBankruptcy'] as bool,
  nextStimulusAt: DateTime.parse(json['nextStimulusAt'] as String),
);

Map<String, dynamic> _$PortfolioToJson(Portfolio instance) => <String, dynamic>{
  'asOf': instance.asOf.toIso8601String(),
  'marketState': instance.marketState,
  'nextChangeAt': instance.nextChangeAt?.toIso8601String(),
  'exchangeId': instance.exchangeId,
  'cash': instance.cash,
  'reservedCash': instance.reservedCash,
  'netWorth': instance.netWorth,
  'seasonChangeAbs': instance.seasonChangeAbs,
  'seasonChangePct': instance.seasonChangePct,
  'dayChangeAbs': instance.dayChangeAbs,
  'dayChangePct': instance.dayChangePct,
  'positions': instance.positions,
  'openOrders': instance.openOrders,
  'canDeclareBankruptcy': instance.canDeclareBankruptcy,
  'nextStimulusAt': instance.nextStimulusAt.toIso8601String(),
};
