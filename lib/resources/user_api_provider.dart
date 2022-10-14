import 'dart:convert';

import 'package:canteiro/helpers/secure_storage_helper.dart';
import 'package:canteiro/models/address.dart';
import 'package:canteiro/models/manager.dart';
import 'package:flutter/foundation.dart';
import 'package:canteiro/envs.dart';
import 'package:canteiro/models/user.dart';
import 'package:canteiro/resources/repository.dart';
import 'package:http/http.dart' as http;

class UserApiProvider {
  const UserApiProvider();

  Future<RequestResponse<Map<String, dynamic>>> updateDeviceToken({@required String deviceId}) async {
    final storageHelper = SecureStorageHelper();
    final jwt = await storageHelper.getJWT();

    final jsonString = json.encode({
      'token': deviceId,
    });

    final response = await http.post(
      Uri.parse(Constants.baseUrl + 'auth/account/device'),
      headers: Repository.headersWithJWT(jwt),
      body: jsonString,
    );

    final map = RequestResponse.tryToDecode(response.body);
    return RequestResponse(response, map);
  }


  Future<RequestResponse<User>> getAccount() async {
    final storageHelper = SecureStorageHelper();
    final jwt = await storageHelper.getJWT();

    final response = await http.get(
        Uri.parse(Constants.baseUrl + 'auth/account'),
        headers: Repository.headersWithJWT(jwt)
    );
    final map = RequestResponse.tryToDecode(response.body);
    User user;
    if(map != null) {
      user = User.fromJson(map);
    }
    return RequestResponse(response, user);
  }

  Future<RequestResponse<String>> refreshJWT({@required String jwt}) async {

    final response = await http.get(
      Uri.parse(Constants.baseUrl + 'auth/refresh'),
      headers: Repository.headersWithJWT(jwt)
    );
    return RequestResponse(response, response.body);

  }

  Future<RequestResponse<List<Manager>>> getManagers() async {

    final response = await http.get(
        Uri.parse(Constants.baseUrl + 'auth/user/managers'),
        headers: Repository.basicHeaders
    );
    return RequestResponse(response, await compute(_computeParseManagersList,response.body));

  }

  Future<RequestResponse<Map<String, dynamic>>> signUpUser({
  @required String name,
    @required String email,
    @required String password,
    @required int managerId,
    @required int residentsCount,
    @required Address address,
}) async {
     final map = {
       'name': name,
       'email': email,
       'password': password,
       'password_confirmation': password,
       'manager': '$managerId',
       'qtd_residents': '$residentsCount',
       'address' : address.toJson(),
     };

     final jsonString = json.encode(map);

     final response = await http.post(
       Uri.parse(Constants.baseUrl + 'auth/user/create'),
       headers: Repository.basicHeaders,
       body: jsonString,
     );

     final responseMap = RequestResponse.tryToDecode(response.body);
     return RequestResponse(response, responseMap);
  }

  Future<RequestResponse<Map<String, dynamic>>> editProfile({
    @required int userId,
    @required String name,
    @required String email,
    @required int managerId,
    @required int residentsCount,
    @required Address address,
  }) async {
    final storageHelper = SecureStorageHelper();
    final jwt = await storageHelper.getJWT();

    final map = {
      'name': name,
      'email': email,
      'manager': '$managerId',
      'qtd_residents': '$residentsCount',
      'address' : address.toJson(),
    };

    final jsonString = json.encode(map);

    final response = await http.put(
      Uri.parse(Constants.baseUrl + 'auth/user/update/$userId'),
      headers: Repository.headersWithJWT(jwt),
      body: jsonString,
    );

    final responseMap = RequestResponse.tryToDecode(response.body);
    return RequestResponse(response, responseMap);
  }

  Future<RequestResponse<bool>> verifyEmailAvailability({@required String email}) async {
    final jsonString = json.encode({
      'email': email,
    });
    final response = await http.post(
        Uri.parse(Constants.baseUrl + 'auth/check/email'),
        headers: Repository.basicHeaders,
      body: jsonString,
    );
    final map = RequestResponse.tryToDecode(response.body);
    return RequestResponse(response, map['status'] == false);
  }

}

List<Manager> _computeParseManagersList(String json){
  final map = RequestResponse.tryToDecode(json);
  List<Manager> managers;
  if(map != null) {
    managers = map['managers'].map<Manager>((map) => Manager.fromJson(map)).toList();
  }
  return managers;
}
