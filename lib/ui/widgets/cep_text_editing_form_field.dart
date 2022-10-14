import 'package:canteiro/blocs/bloc_event.dart';
import 'package:canteiro/blocs/cep_text_editing_form_field_bloc.dart';
import 'package:canteiro/helpers/format_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:canteiro/models/address.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CEPTextEditingFormField extends StatelessWidget {

  CEPTextEditingFormField({
    @required this.zipCodeController,
    @required this.autoFocus,
    @required this.onFieldSubmitted,
    Key key,
}):
      assert(autoFocus != null, 'autoFocus must be false or true'),
  assert(onFieldSubmitted != null, 'onFieldSubmitted must not be null'),
        super(key: key);

  final TextEditingController zipCodeController;
  final bool autoFocus;
  final void Function(Address) onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    final localizable = AppLocalizations.of(context);
    return BlocProvider(
        create: (context) => CEPTextEditingFormFieldBloc(CEPTextEditingFormFieldBlocState()),
      child: BlocConsumer<CEPTextEditingFormFieldBloc,CEPTextEditingFormFieldBlocState>(
        listenWhen: (oldState, newState) => oldState.status != newState.status && oldState.address != newState.address,
        listener: (context, state){
          if(state.status == SearchAddressByCepStatus.searchFinished) {
            onFieldSubmitted(state.address);
          }
        },
        builder: (context, state) {
          return TextFormField(
            controller: zipCodeController,
            autofocus: autoFocus,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: localizable.zipCode,
              hintText: localizable.zipCodeExample,
              suffixIconConstraints: BoxConstraints(
                maxWidth: 30,
                maxHeight: 20,
                minWidth: 25,
                minHeight: 15
              ),
              suffixIcon: Visibility(
                visible: state.status == SearchAddressByCepStatus.searching,
                child: Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
              )
            ),
            inputFormatters: [
              TextInputFormatter.withFunction(FormatHelper.cepTFFormatter)
            ],
            validator: (newValue) {
              if (newValue == null || newValue.isEmpty) {
                return localizable.obligatedField;
              }
              return null;
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onFieldSubmitted: (newValue) {
              BlocProvider.of<CEPTextEditingFormFieldBloc>(context).add(BlocEvent(CEPTextEditingFormFieldBlocEvent.searchAddress,data:newValue));
            },
          );
        },
      ),
    );
  }
}
