import 'package:canteiro/models/address.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable(
  explicitToJson: true,
)
//{"status":true,"message":"","error":"","id":8,"account":{"name":"Jose Lucas","email":"chagasjoselucas@nucleus.eti.br","user_type":"Cliente","status":0}}

class User {
  User({
    this.id,
    this.account
  });

  int id;
  Account account;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable()
class Account {
  Account({
    this.name,
    this.email,
    this.address,
    this.userType,
    this.status,
    this.managerId,
    this.managerName,
    this.numberResidents,
  });

  String name;
  String email;
  @JsonKey(name: 'user_type', fromJson: userTypeFromJson, toJson: userTypeToJson)
  UserType userType;
  Address address;
  int status;
  @JsonKey(name:'qtd_residents')
  int numberResidents;

  @JsonKey(name: 'manager_name')
  String managerName;
  @JsonKey(name: 'manager_id')
  int managerId;

  factory Account.fromJson(Map<String, dynamic> json) =>
      _$AccountFromJson(json);

  Map<String, dynamic> toJson() => _$AccountToJson(this);
}




@JsonSerializable(
  explicitToJson: true,
)
class Profile {
  Profile({
    this.phoneNumber,
    this.birthdate,
    this.docNumber,
    this.address,
    this.thumbnail,
  });

  String phoneNumber;
  String birthdate;
  @JsonKey(name: 'doc_number')
  String docNumber;
  Address address;
  String thumbnail;

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileToJson(this);
}

enum UserType {
  manager,
  client
}

UserType userTypeFromJson(String json) {
  switch(json){
    case 'Gerente':
      return UserType.manager;
    case 'Cliente':
      return UserType.client;
    default:
      return UserType.client;
  }
}

String userTypeToJson(UserType userType) {
  switch(userType){
    case UserType.manager:
      return 'Gerente';
    case UserType.client:
      return 'Cliente';
    default:
      return 'Cliente';
  }
}