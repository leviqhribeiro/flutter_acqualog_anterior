import 'package:canteiro/blocs/add_consumption_page_bloc.dart';
import 'package:canteiro/blocs/bloc_event.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CanteiroDateTimeFormField extends StatelessWidget {
  CanteiroDateTimeFormField(
      {Key key,
      this.initialDate,
      this.validator,
      this.onSaved,
      this.onDateSelected})
      : super(key: key);

  final DateTime initialDate;
  final FormFieldValidator<DateTime> validator;
  final FormFieldSetter<DateTime> onSaved;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddConsumptionPageBloc, AddConsumptionPageBlocState>(
      buildWhen: (oldState, newState) =>
          oldState.modeVerifyStatus != newState.modeVerifyStatus,
      builder: (blocContext, state) {
        final localizable = AppLocalizations.of(blocContext);
        return Row(
          children: [
            Expanded(
              child: DateTimeFormField(
                enabled: state.modeVerifyStatus !=
                    AddConsumptionModeVerifyStatus.verifying,
                decoration: InputDecoration(
                  //hintStyle: TextStyle(color: Colors.black45),
                  //errorStyle: TextStyle(color: Colors.redAccent),
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.event_note),
                  labelText: localizable.reading_date,
                ),
                initialValue: initialDate,
                firstDate: DateTime(DateTime.now().year,1,1),
                lastDate: DateTime(DateTime.now().year,12,31),
                mode: DateTimeFieldPickerMode.date,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onSaved: onSaved,
                validator: validator,
                onDateSelected: (value) => _onDateSelected(blocContext, value),
              ),
            ),
            SizedBox(width: state.modeVerifyStatus == AddConsumptionModeVerifyStatus.verifying ? 10 : 0,),
            AnimatedSwitcher(
              child: state.modeVerifyStatus == AddConsumptionModeVerifyStatus.verifying
                  ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
                  : SizedBox.shrink(),
                duration: Duration(milliseconds: 400),
            )

          ],
        );
      },
    );
  }

  void _onDateSelected(BuildContext context, DateTime value) {
    //Verify if this date is already added or not, if yes change to edit mode and inform to user
    BlocProvider.of<AddConsumptionPageBloc>(context).add(BlocEvent(AddConsumptionPageBlocEvent.updateModeForDate, data: value));
    if (onDateSelected != null) {
      onDateSelected(value);
    }
  }
}
