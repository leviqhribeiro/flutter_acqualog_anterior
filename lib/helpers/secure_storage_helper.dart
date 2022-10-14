
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageHelper {
  static final _jwtKey = "jwt";
  static final _attributesKey = "attributes";

  final storage = new FlutterSecureStorage();

  Future<String> getJWT() async => await storage.read(key: _jwtKey);

  void saveJWT(String jwt) async => await storage.write(key: _jwtKey, value: jwt);

  void clearJWT() async => await storage.delete(key: _jwtKey);

  // Future<Attributes> getAttributes() async {
  //   final json = await storage.read(key: _attributesKey);
  //   final map = RequestResponse.tryToDecode(json);
  //   return map != null ? Attributes.fromJson(map) : null;
  // }
  //
  // void saveAttributes(Attributes attributes) async =>
  //     await storage.write(key: _attributesKey, value: json.encode(attributes));

  void clearAttributes() async => await storage.delete(key: _attributesKey);
}
