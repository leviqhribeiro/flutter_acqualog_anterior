import 'dart:convert';

import 'package:canteiro/envs.dart';
import 'package:canteiro/models/user.dart';
import 'package:canteiro/resources/repository.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

//https://flutter.dev/docs/cookbook/networking/authenticated-requests
class LoginApiProvider {

  const LoginApiProvider();

  Future<RequestResponse<User>> login(String email, String password) async {
    final jsonString = json.encode({
      'email': email,
      'password': password,
    });

    final response = await http.post(
      Uri.parse(Constants.baseUrl + 'auth/login'),
      headers: Repository.basicHeaders,
      body: jsonString,
    );
    print(response.body);
    Repository.saveJWT(response.headers);
    User loggedUser;
    final map = RequestResponse.tryToDecode(response.body);
    if (map != null) loggedUser = User.fromJson(map);
    return RequestResponse(response, loggedUser);
  }

  Future<RequestResponse<String>> sendVerificationCode(String email) async {
    final jsonString = json.encode({'email': email});
    final response = await http.post(
      Uri.parse(Constants.baseUrl + 'auth/recovery'),
      headers: Repository.basicHeaders,
      body: jsonString,
    );
    return RequestResponse(response, response.body);
  }

  Future<RequestResponse<Map<String,dynamic>>> validateCode({@required String email, @required String code}) async {
    final jsonString = json.encode({
      'email': email,
      'code' : code,
    });
    final response = await http.post(
      Uri.parse(Constants.baseUrl + 'auth/validate'),
      headers: Repository.basicHeaders,
      body: jsonString,
    );
    final map = RequestResponse.tryToDecode(response.body);
    return RequestResponse(response, map);
  }

  Future<RequestResponse<Map<String,dynamic>>> resetPassword({@required String password, @required String email, @required String code}) async {
    final jsonString = json.encode({
      'email': email,
      'code' : code,
      'new_password': password,
    });
    final response = await http.post(
      Uri.parse(Constants.baseUrl + 'auth/reset'),
      headers: Repository.basicHeaders,
      body: jsonString,
    );
    final map = RequestResponse.tryToDecode(response.body);
    return RequestResponse(response, map);
  }

}
