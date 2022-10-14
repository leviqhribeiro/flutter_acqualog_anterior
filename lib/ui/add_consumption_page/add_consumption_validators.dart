import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:intl/intl.dart';

class AddConsumptionValidators {
  AddConsumptionValidators(this.localizable);
  AppLocalizations localizable;

  String onValidateResidence(String value){
    if(value == null || value.isEmpty) {
      return 'O campo residência não pode ficar vazio.';
    }
    return null;
  }

  String onValidateConsumption(String value){
    if(value == null || value.isEmpty) {
      return 'Campo obrigatório';
    }
    else {
      try {
        final formatter = NumberFormat.decimalPattern('pt-BR');
        final numericValue = formatter.parse(value);
        if(numericValue < 0) {
          return 'Valor inválido';
        }
      }
      catch(e){
        return 'Formato inválido';
      }
    }
    return null;
  }

  String onValidateValue(String value){
    if(value == null || value.isEmpty) {
      return 'Campo obrigatório';
    }
    else {
      try {
        final formatter = NumberFormat.simpleCurrency(locale: 'pt-BR');
        final numericValue = formatter.parse(value);
        if(numericValue < 0) {
          return 'Valor inválido';
        }
      }
      catch(e){
        return 'Formato inválido';
      }
    }
    return null;
  }

  String onValidateDateTime(DateTime value){
    if(value == null) {
      return 'Campo obrigatório';
    }
    return null;
  }
}