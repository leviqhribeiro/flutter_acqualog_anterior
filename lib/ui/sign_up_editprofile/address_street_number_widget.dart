import 'package:canteiro/helpers/format_helper.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter/material.dart';

class AddressStreetNumberWidget extends StatelessWidget {
  AddressStreetNumberWidget({
    @required this.streetController,
    @required this.streetFocusNode,
    @required this.numberController,
    @required this.numberFocusNode,
    @required this.onFieldSubmitted,
    Key key,
  }) : super(key: key);

  final FocusNode streetFocusNode;
  final TextEditingController streetController;

  final FocusNode numberFocusNode;
  final TextEditingController numberController;

  final void Function(String street, String number) onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    final localizable = AppLocalizations.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: TextFormField(
            focusNode: streetFocusNode,
            controller: streetController,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: localizable.street,
            ),
            validator: (newValue) {
              if (newValue == null || newValue.isEmpty) {
                return localizable.obligatedField;
              }
              return null;
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
        ),
        SizedBox(
          width: 10,
        ),
        Expanded(
          flex: 1,
          child: TextFormField(
            focusNode: numberFocusNode,
            controller: numberController,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: localizable.number,
            ),
            inputFormatters: [
              TextInputFormatter.withFunction(
                (oldValue, newValue) =>
                    FormatHelper.maskWithLength(6, oldValue, newValue),
              ),
              FormatHelper.allowOnlyNumbersLettersAndDots(),
            ],
            onFieldSubmitted: (value) {
              onFieldSubmitted(streetController.text, value);
            },
          ),
        )
      ],
    );
  }
}
