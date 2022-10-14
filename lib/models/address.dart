
import 'package:json_annotation/json_annotation.dart';

part 'address.g.dart';

/*
* "id": 1,
            "cep": "60040000",
            "street": "Rua Antônio Pompeu",
            "number": 8888,
            "neighborhood": "centro",
            "city": "Fortaleza",
            "state": "CE",
            "complement": "teste"
* */

@JsonSerializable()
class Address {
  Address({
    this.cep,
    this.street,
    this.number,
    this.neighborhood,
    this.city,
    this.state,
    this.complement,
  });

  @JsonKey(required: false, nullable: true)
  String cep;
  String street;
  @JsonKey(required: false, nullable: true,fromJson: _streetNumberFromJson)
  String number;
  String neighborhood;
  String city;
  String state;
  @JsonKey(required: false, nullable: true)
  String complement;

  factory Address.fromJson(Map<String, dynamic> json) => _$AddressFromJson(json);
  Map<String, dynamic> toJson() => _$AddressToJson(this);

  factory Address.fromViaCep(Map<String,dynamic> json) {
    /*
    * val cep:String?,
        var logradouro:String?,
        var complemento:String?,
        var bairro:String?,
        var localidade:String?,
        var uf:String?

    * */
    return Address(
      cep: json['cep'],
      city: json['localidade'],
      neighborhood: json['bairro'],
      complement: json['complemento'],
      state: json['uf'],
      street: json['logradouro'],
    );
  }
}

_streetNumberFromJson(int value) {
  return '${value == null ? '' : value}';
}