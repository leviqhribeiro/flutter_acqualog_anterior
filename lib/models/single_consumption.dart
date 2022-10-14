import 'package:canteiro/models/consumption_measurement_units.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

part 'single_consumption.g.dart';

@JsonSerializable()
class SingleConsumption {
  SingleConsumption();
  int id;
  @JsonKey(name: 'user_id')
  int userId;
  String residence;
  double reading;
  ConsumptionMeasurementUnits unity;
  double tax;
  @JsonKey(toJson: consumptionDateToJson, fromJson: consumptionDateFromJson, name: 'consumption_date')
  DateTime consumptionDate;

  factory SingleConsumption.fromJson(Map<String, dynamic> json) =>
      _$SingleConsumptionFromJson(json);

  Map<String, dynamic> toJson() => _$SingleConsumptionToJson(this);
}

String consumptionDateToJson(DateTime date) {
  final formatter = DateFormat('dd/MM/yyyy');
  return formatter.format(date);
}


DateTime consumptionDateFromJson(String date) {
  final formatter = DateFormat('dd/MM/yyyy');
  return formatter.parse(date);
}

/*
* "id": 1,
        "user_id": 8,
        "residence": "Casa 3",
        "reading": 45.6,
        "unity": "meter",
        "tax": 85,
        "consumption_date": "20/01/2021"
* */