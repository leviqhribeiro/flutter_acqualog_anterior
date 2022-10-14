import 'package:canteiro/helpers/format_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CurrencyTextFormField extends TextFormField {
  CurrencyTextFormField(
  {
    Key key,
    TextEditingController controller,
    TextStyle style,
    FocusNode focusNode,
    InputDecoration decoration = const InputDecoration(),
    AutovalidateMode autovalidateMode,
    FormFieldValidator<String> validator,
    ValueChanged<String> onFieldSubmitted,
    FormFieldSetter<String> onSaved,
    ValueChanged<String> onChanged
}
      ):super(
    key: key,
    inputFormatters: [
      TextInputFormatter.withFunction(FormatHelper.currencyTFFormatter)
    ],
    showCursor: false,
    keyboardType: TextInputType.number,
    style: style,
    controller: controller,
    decoration: decoration,
    focusNode: focusNode,
    autovalidateMode: autovalidateMode,
    validator: validator,
    onFieldSubmitted: onFieldSubmitted,
    onSaved: onSaved,
    onChanged: onChanged,
  );
}