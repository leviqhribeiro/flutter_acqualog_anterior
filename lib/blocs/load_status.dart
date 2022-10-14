import 'dart:io';

import 'package:canteiro/resources/repository.dart';

enum LoadStatus {
  none,
  executing,
  success,
  failed,
  unexpectedError,
  notFound,
  unauthorized,
  noInternetConnection,
  internalServerError,

  emailUnavailable,
}

extension LoadStatusExtension on LoadStatus {
  static LoadStatus loadStatusForException(dynamic exception) {
    if(exception is Exception) {
      if(exception is SocketException) {
        return LoadStatus.noInternetConnection;
      }
      else {
        return LoadStatus.failed;
      }
    }
    else {
      return LoadStatus.unexpectedError;
    }
  }

  static LoadStatus loadStatusForRequestResponse(RequestResponse response) {
    if(response.success) {
      return LoadStatus.success;
    }
    else if(response.internalServerError) {
      return LoadStatus.internalServerError;
    }
    else if(response.unauthorized) {
      return LoadStatus.unauthorized;
    }
    else if(response.statusCode == 404) {
      return LoadStatus.notFound;
    }
    else {
      return LoadStatus.failed;
    }
  }

  bool get hasError => ![
    LoadStatus.none,
    LoadStatus.executing,
    LoadStatus.success,
  ].contains(this);

}