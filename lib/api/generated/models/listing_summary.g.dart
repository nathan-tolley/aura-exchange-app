// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListingSummary _$ListingSummaryFromJson(Map<String, dynamic> json) =>
    ListingSummary(
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
    );

Map<String, dynamic> _$ListingSummaryToJson(ListingSummary instance) =>
    <String, dynamic>{
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
    };
