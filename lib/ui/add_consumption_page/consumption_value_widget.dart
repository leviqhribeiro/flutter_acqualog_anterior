import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:canteiro/models/consumption_measurement_units.dart';
import 'package:canteiro/ui/add_consumption_page/choose_consumption_measurement_widget.dart';
import 'package:flutter/material.dart';

class ConsumptionValueWidget extends StatelessWidget {


  ConsumptionValueWidget({
    this.consumptionController,
    this.consumptionFocusNode,
    this.unit,
    this.consumptionValueValidator,
    this.onFieldSubmitted,
    this.onMeasureValueChanged,
    Key key,
}):super(key: key);

  final FocusNode consumptionFocusNode;
  final TextEditingController consumptionController;
  final FormFieldValidator<String> consumptionValueValidator;
  final ValueChanged<String> onFieldSubmitted;
  final ConsumptionMeasurementUnits unit;
  final ValueChanged<ConsumptionMeasurementUnits> onMeasureValueChanged;


  @override
  Widget build(BuildContext context) {
    final localizable = AppLocalizations.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextFormField(
            focusNode: consumptionFocusNode,
            controller: consumptionController,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: localizable.consumption,
            ),
            keyboardType: TextInputType.number,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: consumptionValueValidator,
            onFieldSubmitted: onFieldSubmitted,
          ),
          flex: 2,
        ),
        SizedBox(
          width: 10,
        ),
        Expanded(
          child: ChooseConsumptionMeasurementWidget(
            unit: unit,
            onValueChanged: onMeasureValueChanged,
          ),
        ),
      ],
    );
  }
}
