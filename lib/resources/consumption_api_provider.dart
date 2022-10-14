import 'dart:convert';

import 'package:canteiro/envs.dart';
import 'package:canteiro/helpers/secure_storage_helper.dart';
import 'package:canteiro/models/consumption.dart';
import 'package:canteiro/models/consumption_measurement_units.dart';
import 'package:canteiro/models/single_consumption.dart';
import 'package:canteiro/resources/repository.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ConsumptionApiProvider {

  const ConsumptionApiProvider();

  Future<RequestResponse<Consumption>> getConsumption({
  @required int userId,
}) async {
    final userJWT = await SecureStorageHelper().getJWT();
    final response = await http.get(
      Uri.parse(Constants.baseUrl + 'auth/client/$userId/dashboard'),
      headers: Repository.headersWithJWT(userJWT),
    );

    Consumption consumption;
    final map = RequestResponse.tryToDecode(response.body);
    if (map != null) consumption = Consumption.fromJson(map);
    return RequestResponse(response, consumption);
  }

  Future<RequestResponse<String>> createConsumption({
    @required int userId,
    @required String residence,
    @required double reading,
    @required ConsumptionMeasurementUnits unity,
    @required double tax,
    @required DateTime consumptionDate,
  }) async {
    final userJWT = await SecureStorageHelper().getJWT();

    final map = {
      "id": '$userId',
      "residence" : residence,
      "reading" :reading,
      "unity" : describeEnum(unity),
      "tax" : tax,
      "consumption_date" : DateFormat('dd/MM/yyyy').format(consumptionDate),
    };

    final response = await http.post(
      Uri.parse(Constants.baseUrl + 'auth/client/consumption/add'),
      headers: Repository.headersWithJWT(userJWT),
      body:  json.encode(map),
    );

    return RequestResponse(response, response.body);
  }

  Future<RequestResponse<String>> updateConsumption({
    @required int consumptionId,
    @required String residence,
    @required double reading,
    @required ConsumptionMeasurementUnits unity,
    @required double tax,
    @required DateTime consumptionDate,
  }) async {
    final userJWT = await SecureStorageHelper().getJWT();

    final map = {
      "residence" : residence,
      "reading" :reading,
      "unity" : describeEnum(unity),
      "tax" : tax,
      "consumption_date" : DateFormat('dd/MM/yyyy').format(consumptionDate),
    };

    final response = await http.put(
      Uri.parse(Constants.baseUrl + 'auth/client/consumption/update/$consumptionId'),
      headers: Repository.headersWithJWT(userJWT),
      body:  json.encode(map),
    );

    return RequestResponse(response, response.body);
  }


  Future<RequestResponse<SingleConsumption>> getSingleConsumptionOfPeriod({@required int userId, @required DateTime date}) async {
    final month = DateFormat('MM').format(date);
    final year = DateFormat.y().format(date);
    final userJWT = await SecureStorageHelper().getJWT();
    final map = {
      'user_id': '$userId',
      'month': month,
      'year': year
    };
    final response = await http.post(
      Uri.parse(Constants.baseUrl + 'auth/client/consumption/list/time'),
      headers: Repository.headersWithJWT(userJWT),
      body:  json.encode(map),
    );

    SingleConsumption consumption;
    final responseMap = RequestResponse.tryToDecode(response.body);
    if (responseMap != null && responseMap.containsKey('consumptions')) consumption = SingleConsumption.fromJson(responseMap['consumptions']);
    return RequestResponse(response, consumption);

  }

}