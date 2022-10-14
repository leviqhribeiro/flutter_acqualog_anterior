
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'consumption.g.dart';


@JsonSerializable(explicitToJson: true)
class Consumption {
  Consumption({@required this.data});

  ConsumptionData data;

  factory Consumption.fromJson(Map<String, dynamic> json) =>
      _$ConsumptionFromJson(json);

  Map<String, dynamic> toJson() => _$ConsumptionToJson(this);
}

@JsonSerializable()
class ConsumptionData {
  ConsumptionData({
    @required this.months,
    @required this.consumptions,
    @required this.outlays,
    @required this.contigengy,
});
  List<String> months;
  List<double> consumptions;
  List<double> outlays;
  List<double> contigengy;

  factory ConsumptionData.fromJson(Map<String, dynamic> json) =>
      _$ConsumptionDataFromJson(json);

  Map<String, dynamic> toJson() => _$ConsumptionDataToJson(this);
}
/*
*  "data": {
        "months": [
            "JAN",
            "FEV",
            "MAR",
            "ABR",
            "JUN",
            "JUL",
            "AGO",
            "SET",
            "OUT",
            "NOV",
            "DEZ"
        ],
        "consumptions": [
            45.6,
            100.92,
            85.02,
            90.67,
            45.7,
            30.99,
            210.99,
            79.05,
            80.1,
            60.1,
            97.1,
            57.1
        ],
        "outlays": [
            85,
            210.5,
            60.5,
            99.48,
            65.5,
            40.48,
            299.48,
            101.01,
            108.27,
            88.27,
            112.97,
            70.07
        ],
        "contigengy": [
            100,
            70,
            90,
            70,
            85,
            60,
            75,
            60,
            90,
            80,
            110,
            100
        ]
    },
* */