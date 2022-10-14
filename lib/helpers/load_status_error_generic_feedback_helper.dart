import 'package:canteiro/blocs/load_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoadStatusErrorGenericFeedbackHelper {
  static void showSnackbarForLoadStatus({
    @required BuildContext context,
    @required LoadStatus loadStatus,
  }) {
    final localizable = AppLocalizations.of(context);
    String message;
    switch (loadStatus) {
      case LoadStatus.noInternetConnection:
        message = localizable.not_internet_connection;
        break;
      case LoadStatus.internalServerError:
        message = localizable.internal_server_error;
        break;
      case LoadStatus.unexpectedError:
        message = localizable.unexpected_error;
        break;
      default:
        //For errors that does not have a generic specific error message
        if (loadStatus.hasError) {
          message = localizable.failed_perform_request;
        }
        break;
    }
    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
          ),
        ),
      );
    }
  }
}
