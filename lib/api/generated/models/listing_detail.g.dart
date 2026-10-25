// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListingDetail _$ListingDetailFromJson(Map<String, dynamic> json) =>
    ListingDetail(
      asOf: DateTime.parse(json['asOf'] as String),
      marketState: MarketState.fromJson(json['marketState'] as String),
      nextChangeAt: json['nextChangeAt'] == null
          ? null
          : DateTime.parse(json['nextChangeAt'] as String),
      id: json['id'] as String,
      ticker: json['ticker'] as String,
      displayName: json['displayName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      price: json['price'] as String,
      changeAbs: json['changeAbs'] as String,
      changePct: json['changePct'] as String,
      state: ListingState.fromJson(json['state'] as String),
      badges: (json['badges'] as List<dynamic>)
          .map((e) => Badge.fromJson(e as String))
          .toList(),
      sparkline: (json['sparkline'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      isMine: json['isMine'] as bool,
      myPosition: json['myPosition'] == null
          ? null
          : MyPosition.fromJson(json['myPosition'] as Map<String, dynamic>),
      prevClose: json['prevClose'] as String,
      open: json['open'] as String?,
      dayHigh: json['dayHigh'] as String,
      dayLow: json['dayLow'] as String,
      seasonHigh: json['seasonHigh'] as String,
      seasonLow: json['seasonLow'] as String,
      volume: json['volume'] as String,
      shortInterestPct: json['shortInterestPct'] as String,
      borrowFeeDailyPct: json['borrowFeeDailyPct'] as String,
      indicatedPrice: json['indicatedPrice'] as String?,
      indicatedChangePct: json['indicatedChangePct'] as String?,
      halt: json['halt'] == null
          ? null
          : Halt.fromJson(json['halt'] as Map<String, dynamic>),
      lastTradeAt: json['lastTradeAt'] == null
          ? null
          : DateTime.parse(json['lastTradeAt'] as String),
      events: (json['events'] as List<dynamic>)
          .map((e) => EventSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
      analyst: json['analyst'] == null
          ? null
          : Analyst.fromJson(json['analyst'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ListingDetailToJson(ListingDetail instance) =>
    <String, dynamic>{
      'asOf': instance.asOf.toIso8601String(),
      'marketState': instance.marketState,
      'nextChangeAt': instance.nextChangeAt?.toIso8601String(),
      'id': instance.id,
      'ticker': instance.ticker,
      'displayName': instance.displayName,
      'avatarUrl': instance.avatarUrl,
      'price': instance.price,
      'changeAbs': instance.changeAbs,
      'changePct': instance.changePct,
      'state': instance.state,
      'badges': instance.badges,
      'sparkline': instance.sparkline,
      'isMine': instance.isMine,
      'myPosition': instance.myPosition,
      'prevClose': instance.prevClose,
      'open': instance.open,
      'dayHigh': instance.dayHigh,
      'dayLow': instance.dayLow,
      'seasonHigh': instance.seasonHigh,
      'seasonLow': instance.seasonLow,
      'volume': instance.volume,
      'shortInterestPct': instance.shortInterestPct,
      'borrowFeeDailyPct': instance.borrowFeeDailyPct,
      'indicatedPrice': instance.indicatedPrice,
      'indicatedChangePct': instance.indicatedChangePct,
      'halt': instance.halt,
      'lastTradeAt': instance.lastTradeAt?.toIso8601String(),
      'events': instance.events,
      'analyst': instance.analyst,
    };
