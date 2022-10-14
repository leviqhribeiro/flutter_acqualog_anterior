// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) {
  return User(
    id: json['id'] as int,
    account: json['account'] == null
        ? null
        : Account.fromJson(json['account'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'account': instance.account?.toJson(),
    };

Account _$AccountFromJson(Map<String, dynamic> json) {
  return Account(
    name: json['name'] as String,
    email: json['email'] as String,
    address: json['address'] == null
        ? null
        : Address.fromJson(json['address'] as Map<String, dynamic>),
    userType: userTypeFromJson(json['user_type'] as String),
    status: json['status'] as int,
    managerId: json['manager_id'] as int,
    managerName: json['manager_name'] as String,
    numberResidents: json['qtd_residents'] as int,
  );
}

Map<String, dynamic> _$AccountToJson(Account instance) => <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'user_type': userTypeToJson(instance.userType),
      'address': instance.address,
      'status': instance.status,
      'qtd_residents': instance.numberResidents,
      'manager_name': instance.managerName,
      'manager_id': instance.managerId,
    };

Profile _$ProfileFromJson(Map<String, dynamic> json) {
  return Profile(
    phoneNumber: json['phoneNumber'] as String,
    birthdate: json['birthdate'] as String,
    docNumber: json['doc_number'] as String,
    address: json['address'] == null
        ? null
        : Address.fromJson(json['address'] as Map<String, dynamic>),
    thumbnail: json['thumbnail'] as String,
  );
}

Map<String, dynamic> _$ProfileToJson(Profile instance) => <String, dynamic>{
      'phoneNumber': instance.phoneNumber,
      'birthdate': instance.birthdate,
      'doc_number': instance.docNumber,
      'address': instance.address?.toJson(),
      'thumbnail': instance.thumbnail,
    };
