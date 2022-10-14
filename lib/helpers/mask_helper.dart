import 'package:email_validator/email_validator.dart';

class MaskHelper{

  static String applyCPFMask(String cpf){
    var value = cpf.replaceAllMapped(RegExp(r"(\d{3})(\d{3})(\d{3})(\d{2})"), (Match m){
        var result;
        if(m.groupCount > 0)
          result = "${m.group(1)}";
        if(m.groupCount > 1)
          result += ".${m.group(2)}";
        if(m.groupCount > 2)
          result += ".${m.group(3)}";
        if(m.groupCount > 3)
          result += "-${m.group(4)}";
        return result;
    });
    return value;
  }

  static String applyCEPMask(String cep){
    return cep.replaceAllMapped(RegExp(r"(\d{5})(\d{3})"), (Match m){
      var result;
      if(m.groupCount > 0)
        result = "${m.group(1)}";
      if(m.groupCount > 1)
        result += "-${m.group(2)}";
      return result;
    });
  }

  static String applyCNPJMask(String cnpj){
    var value = cnpj.replaceAllMapped(RegExp(r"(\d{2})(\d{3})(\d{3})(\d{4})(\d{2})"), (Match m){
      print(m.groupCount);
      var result;
      if(m.groupCount > 0)
        result = "${m.group(1)}";
      if(m.groupCount > 1)
        result += ".${m.group(2)}";
      if(m.groupCount > 2)
        result += ".${m.group(3)}";
      if(m.groupCount > 3)
        result += "/${m.group(4)}";
      if(m.groupCount > 4)
        result += "-${m.group(5)}";
      return result;
    });
    return value;
  }

  static String unmask(String maskedValue){
    return maskedValue.replaceAll(RegExp(r'\D'), "");
  }
}

class ValidatorHelper{
  static int cpfCount = 11;
  static int cnpjCount = 14;

  static bool isAValidCPF(String unmaskedCpf){
    var verifiedCPF = MaskHelper.unmask(unmaskedCpf);
    for(int i = 0; i < 10; i++){
        var str = "$i";
        var equal = true;
        var max = verifiedCPF.length;
        var n = 0;
        while(equal == true && n < max){
          equal = str == verifiedCPF[n];
          n++;
        }
        if(equal)
          return false;// invalid CPF
    }

    var splitedArray = verifiedCPF.split(RegExp(""));
    var cpfNumbers = splitedArray.map((String item){
      return int.tryParse(item)??0;
    }).toList();

    if(cpfNumbers.length > 10) {
      var firstDigit = cpfNumbers[9];
      var secondDigit = cpfNumbers[10];
      int valueOne = 0;
      int valueTwo = 0;

      for(int i = 0; i < 9; i++){
        valueOne += (10 - i)*cpfNumbers[i];
        valueTwo += (11 - i)*cpfNumbers[i];
      }

      var rest = valueOne%11;
      var correctFirstDigit = rest < 2 ? 0 : 11 - rest;

      if (correctFirstDigit != firstDigit){
        return false;
      }

      valueTwo += 2*firstDigit;
      var restTwo = valueTwo % 11;

      var correctSecondDigit = restTwo < 2 ? 0 : 11 - restTwo;
      if(correctSecondDigit != secondDigit){
        return false;
      }

      return true;
    }
    return false;
  }


  static bool isAValidCNPJ(String unmaskedCnpj){
    var b = [6,5,4,3,2,9,8,7,6,5,4,3,2];
    var verifiedCNPJ = MaskHelper.unmask(unmaskedCnpj);
    var splitedArray = verifiedCNPJ.split(RegExp(""));

    var cnpjNumbers = splitedArray.map((String item){
      return int.tryParse(item)??0;
    }).toList();

    if(cnpjNumbers.length == ValidatorHelper.cnpjCount){
      var n = 0;
      for (var i = 0; i < 12; i++) {
        n += cnpjNumbers[i] * b[i+1];
      }

      n = 11 - n%11;
      n = n >= 10 ? 0 : n;
      if (cnpjNumbers[12]!= n)  {
        return false;
      }

      n = 0;
      for (int i = 0; i <= 12; i++) {
        n += cnpjNumbers[i] * b[i];
      }

      n = 11 - n%11;
      n = n >= 10 ? 0 : n;

      if (cnpjNumbers[13] != n)  {
        return false;
      }

      return true;
    }

    return false;
  }

  static bool isAValidEmail(String email){
    return EmailValidator.validate(email);
  }
}