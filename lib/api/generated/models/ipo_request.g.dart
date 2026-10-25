// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ipo_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IpoRequest _$IpoRequestFromJson(Map<String, dynamic> json) => IpoRequest(
  ticker: json['ticker'] as String,
  consent: json['consent'] as bool,
);

Map<String, dynamic> _$IpoRequestToJson(IpoRequest instance) =>
    <String, dynamic>{'ticker': instance.ticker, 'consent': instance.consent};
