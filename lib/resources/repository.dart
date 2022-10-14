import 'dart:convert';

import 'package:canteiro/helpers/secure_storage_helper.dart';
import 'package:canteiro/resources/user_api_provider.dart';
import 'package:http/http.dart' as http;

class RequestResponse<T> {
  RequestResponse(this.allData, this.body);

  T body;

  bool get success => (statusCode ?? 400) == 200;
  bool get forbidden => (statusCode ?? 400) == 403;
  bool get internalServerError => statusCode >= 500;
  bool get unauthorized => statusCode == 401;

  int get statusCode => this.allData?.statusCode;
  http.Response allData;

  static Map<String, dynamic> tryToDecode(String jsonString) {
    if (jsonString != null) {
      try {
        return json.decode(jsonString);
      } catch (e) {
        print(e);
      }
    }
    return null;
  }

  static List<Map<String, dynamic>> tryToDecodeList(String jsonString) {
    if (jsonString != null) {
      try {
        return json.decode(jsonString) as List<Map<String, dynamic>>;
      } catch (e) {
        print('tryToDecodeList: $e');
      }
    }
    return null;
  }
}

class Repository {
  const Repository();

  //static final _loginProvider = LoginApiProvider();
  static final _userProvider = UserApiProvider();

  static final basicHeaders = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  static Map<String, dynamic> headersWithJWT(String jwt) {
    var headers = basicHeaders;
    headers['Authorization'] = 'Bearer $jwt';
    return headers;
  }

  static void saveJWT(Map<String, dynamic> headers) {
    final jwt = headers['authorization'];
    if (jwt != null) {
      final storageHelper = SecureStorageHelper();
      storageHelper.saveJWT(jwt);
    }
  }

  Future<RequestResponse<String>> refresh() async {
    final storageHelper = SecureStorageHelper();
    final jwt = await storageHelper.getJWT();
    final response = await _userProvider.refreshJWT(jwt: jwt);
    saveJWT(response.allData?.headers);
    return response;
  }

// Future<RequestResponse<Attributes>> getAttributes() async {
//   final storageHelper = SecureStorageHelper();
//   final jwt = await storageHelper.getJWT();
//   final response = await _taskProvider.getAttributes(jwt: jwt);
//   log("[GET-ATTRIBUTES] RESULT => ${response.success.toString().toUpperCase()}");
//   return response;
// }
//
// Future<RequestResponse<TaskApiResponse>> deleteTask(int taskId) async {
//   final storageHelper = SecureStorageHelper();
//   final jwt = await storageHelper.getJWT();
//   final response = await _taskProvider.delete(taskId, jwt);
//   log("[DELETE-TASK] RESULT => ${response.success.toString().toUpperCase()}");
//   return response;
// }
//
// Future<RequestResponse<TaskApiResponse>> createTask(Task task) async {
//   final storageHelper = SecureStorageHelper();
//   final jwt = await storageHelper.getJWT();
//   final response = await _taskProvider.create(task, jwt);
//   log("[CREATE-TASK] RESULT => ${response.success.toString().toUpperCase()}");
//   return response;
// }
//
// Future<RequestResponse<TaskApiResponse>> updateTask(int userId, Task task) async {
//   final storageHelper = SecureStorageHelper();
//   final jwt = await storageHelper.getJWT();
//   final response = await _taskProvider.update(userId, task, jwt);
//   log("[UPDATE-TASK] RESULT => ${response.success.toString().toUpperCase()}");
//   return response;
// }
//
// Future<RequestResponse<TaskApiResponse>> updateTaskStatus(int userId, int taskId, String status, String motive) async {
//   final storageHelper = SecureStorageHelper();
//   final jwt = await storageHelper.getJWT();
//   final response = await _taskProvider.updateStatus(userId, taskId, status, motive, jwt);
//   log("[UPDATE-TASK-STATUS] RESULT => ${response.success.toString().toUpperCase()}");
//   return response;
// }
//
// Future<List<Task>> filterTasks(Task task) async {
//   final storageHelper = SecureStorageHelper();
//   final jwt = await storageHelper.getJWT();
//   final response = await _taskProvider.filter(task, jwt);
//   log("[FILTER-TASK] RESULT => ${response.success.toString().toUpperCase()}");
//   return response.body;
// }

//  Future<TaskFilterResponse> taskFilteredBy(int id, String start_date, String end_date, String priority, String status) async {
//    final storageHelper = SecureStorageHelper();
//    final jwt = await storageHelper.getJWT();
//    final response = await _taskProvider.filter(jwt, id, start_date, end_date, priority, status);
//    print(response.allData.body);
//    return response.body;
//  }

}
