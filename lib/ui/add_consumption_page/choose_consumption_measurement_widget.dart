import 'package:canteiro/l10n/app_localizations_constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:canteiro/models/consumption_measurement_units.dart';
import 'package:flutter/material.dart';

class ChooseConsumptionMeasurementWidget extends StatelessWidget {

  ChooseConsumptionMeasurementWidget({
    this.focusNode,
    this.unit,
    this.onValueChanged,
    Key key
}):super(key: key);

  final ConsumptionMeasurementUnits unit;
  final ValueChanged<ConsumptionMeasurementUnits> onValueChanged;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 5),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.grey,width: 1)
      ),
      child: DropdownButton<ConsumptionMeasurementUnits>(
        focusNode: focusNode,
        value: unit,
        iconSize: 24,
        elevation: 16,
        underline: SizedBox.shrink(),
        onChanged: onValueChanged,
        items: <ConsumptionMeasurementUnits>[ConsumptionMeasurementUnits.meter, ConsumptionMeasurementUnits.liter]
            .map<DropdownMenuItem<ConsumptionMeasurementUnits>>((ConsumptionMeasurementUnits value) {
          return DropdownMenuItem<ConsumptionMeasurementUnits>(
            value: value,
            child: Text(
              AppLocalizationsConstants.consumptionMeasurementUnit(AppLocalizations.of(context),value),
            ),
          );
        })
            .toList(),
      ),
    );
  }
}
