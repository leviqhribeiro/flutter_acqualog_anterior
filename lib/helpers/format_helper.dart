import 'package:canteiro/helpers/mask_helper.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class FormatHelper {
  static FilteringTextInputFormatter allowOnlyNumbersLettersDotsAndSpaces() {
    return FilteringTextInputFormatter.allow(RegExp(r'[A-Za-zÀ-ÖØ-öø-ÿ\d\.\ ]'));
  }

  static FilteringTextInputFormatter allowOnlyNumbersLettersAndDots() {
    return FilteringTextInputFormatter.allow(RegExp(r'[A-Za-zÀ-ÖØ-öø-ÿ\d\.]'));
  }

  static TextEditingValue maskWithLength(
    int maxLength,
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var newText = newValue.text;
    if (newText.length > maxLength) {
      return oldValue;
    }
    return newValue;
  }

  static TextEditingValue brazilUFFormatter(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final ufLength = 2;
    var currentUF = newValue.text.replaceAll(RegExp(r'\W'), '');
    if (currentUF.length > ufLength) {
      currentUF = currentUF.substring(0, 2);
    }
    return TextEditingValue(
      text: currentUF.toUpperCase(),
      selection: TextSelection.fromPosition(
        TextPosition(
            affinity: TextAffinity.downstream, offset: currentUF.length),
      ),
    );
  }

  static String currencyFormat(double value, {String locale = 'pt-BR'}) {
    final formatter = NumberFormat.simpleCurrency(locale: locale);
    return formatter.format(value);
  }

  static TextEditingValue currencyTFFormatter(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var currentNumber = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (currentNumber.length > 3) {
      if (currentNumber.substring(0, 1) == '0') {
        currentNumber = currentNumber.substring(1);
      }
    }
    var doubleValue = double.tryParse(currentNumber);
    if (doubleValue != null) {
      var resultText = currencyFormat(doubleValue);
      if (doubleValue >= 1) {
        resultText = currencyFormat(doubleValue / 100.0);
      }
      return TextEditingValue(
        text: resultText,
        selection: TextSelection.fromPosition(
          TextPosition(
              affinity: TextAffinity.downstream, offset: resultText.length),
        ),
      );
    } else {
      return oldValue;
    }
  }

  static TextEditingValue cepTFFormatter(
      TextEditingValue oldValue, TextEditingValue newValue) {
    const cepLength = 8;
    var currentNumber = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (currentNumber.length > cepLength) {
      currentNumber = currentNumber.substring(0, cepLength);
    }
    final resultText = MaskHelper.applyCEPMask(currentNumber);
    return TextEditingValue(
      text: resultText,
      selection: TextSelection.fromPosition(
        TextPosition(
            affinity: TextAffinity.downstream, offset: resultText.length),
      ),
    );
  }
}
