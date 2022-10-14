// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'consumption.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Consumption _$ConsumptionFromJson(Map<String, dynamic> json) {
  return Consumption(
    data: json['data'] == null
        ? null
        : ConsumptionData.fromJson(json['data'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$ConsumptionToJson(Consumption instance) =>
    <String, dynamic>{
      'data': instance.data?.toJson(),
    };

ConsumptionData _$ConsumptionDataFromJson(Map<String, dynamic> json) {
  return ConsumptionData(
    months: (json['months'] as List)?.map((e) => e as String)?.toList(),
    consumptions: (json['consumptions'] as List)
        ?.map((e) => (e as num)?.toDouble())
        ?.toList(),
    outlays:
        (json['outlays'] as List)?.map((e) => (e as num)?.toDouble())?.toList(),
    contigengy: (json['contigengy'] as List)
        ?.map((e) => (e as num)?.toDouble())
        ?.toList(),
  );
}

Map<String, dynamic> _$ConsumptionDataToJson(ConsumptionData instance) =>
    <String, dynamic>{
      'months': instance.months,
      'consumptions': instance.consumptions,
      'outlays': instance.outlays,
      'contigengy': instance.contigengy,
    };
