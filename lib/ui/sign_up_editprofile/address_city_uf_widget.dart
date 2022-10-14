import 'package:canteiro/helpers/format_helper.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter/material.dart';

class AddressCityUFWidget extends StatelessWidget {
  AddressCityUFWidget({
    @required this.cityController,
    @required this.cityFocusNode,
    @required this.ufController,
    @required this.ufFocusNode,
    @required this.onFieldSubmitted,
    Key key,
  }) : super(key: key);

  final FocusNode cityFocusNode;
  final TextEditingController cityController;

  final FocusNode ufFocusNode;
  final TextEditingController ufController;

  final void Function(String city, String uf) onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    final localizable = AppLocalizations.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: TextFormField(
            focusNode: cityFocusNode,
            controller: cityController,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: localizable.city,
            ),
            inputFormatters: [
              FormatHelper.allowOnlyNumbersLettersDotsAndSpaces(),
            ],
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
            focusNode: ufFocusNode,
            controller: ufController,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: localizable.uf,
              hintText: localizable.ufExample,
            ),
            inputFormatters: [
              TextInputFormatter.withFunction(FormatHelper.brazilUFFormatter),
            ],
            validator: (newValue) {
              if (newValue == null || newValue.isEmpty) {
                return localizable.obligatedFieldSmall;
              }
              return null;
            },
            onFieldSubmitted: (value) {
              onFieldSubmitted(cityController.text, value);
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
        )
      ],
    );
  }
}
