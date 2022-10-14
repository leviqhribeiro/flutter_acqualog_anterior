// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'single_consumption.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SingleConsumption _$SingleConsumptionFromJson(Map<String, dynamic> json) {
  return SingleConsumption()
    ..id = json['id'] as int
    ..userId = json['user_id'] as int
    ..residence = json['residence'] as String
    ..reading = (json['reading'] as num)?.toDouble()
    ..unity = _$enumDecodeNullable(
        _$ConsumptionMeasurementUnitsEnumMap, json['unity'])
    ..tax = (json['tax'] as num)?.toDouble()
    ..consumptionDate =
        consumptionDateFromJson(json['consumption_date'] as String);
}

Map<String, dynamic> _$SingleConsumptionToJson(SingleConsumption instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'residence': instance.residence,
      'reading': instance.reading,
      'unity': _$ConsumptionMeasurementUnitsEnumMap[instance.unity],
      'tax': instance.tax,
      'consumption_date': consumptionDateToJson(instance.consumptionDate),
    };

T _$enumDecode<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }

  final value = enumValues.entries
      .singleWhere((e) => e.value == source, orElse: () => null)
      ?.key;

  if (value == null && unknownValue == null) {
    throw ArgumentError('`$source` is not one of the supported values: '
        '${enumValues.values.join(', ')}');
  }
  return value ?? unknownValue;
}

T _$enumDecodeNullable<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source, unknownValue: unknownValue);
}

const _$ConsumptionMeasurementUnitsEnumMap = {
  ConsumptionMeasurementUnits.meter: 'meter',
  ConsumptionMeasurementUnits.liter: 'liter',
};
