import 'package:canteiro/models/address.dart';
import 'package:canteiro/resources/repository.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ViewCEPApiProvider {
  const ViewCEPApiProvider();
  Future<RequestResponse<Address>> findAddressByCep({@required String cep}) async {
    final response = await http.get(
      Uri.parse('https://viacep.com.br/ws/$cep/json'),
    );
    Address address;
    final map = RequestResponse.tryToDecode(response.body);
    if (map != null) address = Address.fromViaCep(map);
    return RequestResponse(response, address);
  }
}