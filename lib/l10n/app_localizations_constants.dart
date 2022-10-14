import 'package:canteiro/models/consumption_measurement_units.dart';
import 'package:canteiro/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AppLocalizationsConstants {
  static List<Locale> get supportedLocales => [
    Locale.fromSubtags(
        languageCode: 'pt',
        countryCode: 'BR'
    )
  ];

  static String consumptionMeasurementUnit(AppLocalizations localizable, ConsumptionMeasurementUnits units) {
    switch(units) {
      case ConsumptionMeasurementUnits.meter:
        return localizable.consumption_measurement_unit_meter;
      case ConsumptionMeasurementUnits.liter:
        return localizable.consumption_measurement_unit_liter;
    }
    return '';
  }

  static String textForUserType(AppLocalizations localizable,UserType type) {
    switch(type) {
      case UserType.manager:
        return localizable.manager;
      case UserType.client:
        return localizable.client;
    }
    return localizable.client;
  }
}