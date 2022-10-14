import 'dart:convert';

import 'package:flutter/cupertino.dart';

class JwtHelper{
  static Map<String, dynamic> _parseJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('invalid token');
    }

    final payload = _decodeBase64(parts[1]);
    final payloadMap = json.decode(payload);
    if (payloadMap is! Map<String, dynamic>) {
      throw Exception('invalid payload');
    }

    return payloadMap;
  }

  static String _decodeBase64(String str) {
    String output = str.replaceAll('-', '+').replaceAll('_', '/');

    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
      default:
        throw Exception('Illegal base64url string!"');
    }

    return utf8.decode(base64Url.decode(output));
  }

  static bool jwtIsExpired(String jwt){
    try{
      var claims = _parseJwt(jwt);
      int exp = claims["exp"];
      var date = DateTime.fromMillisecondsSinceEpoch(exp*1000,isUtc: true);
      return !DateTime.now().toUtc().isBefore(date);
    }
    catch(e){
      print(e);
    }
    return false;
  }

  static T customClaim<T>({@required String jwt,@required String key}) {
    try{
      var claims = _parseJwt(jwt);
      T claim = claims[key];
      return claim;
    }
    catch(e){
      print(e);
    }
    return null;
  }

}