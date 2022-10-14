
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class FixPermissionDialog extends StatelessWidget {
  FixPermissionDialog({@required this.title,@required this.message, Key key}):super(key: key);

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final localizables = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(
        title,
      ),
      content: Text(
        message,
      ),
      actions: <Widget>[
        TextButton(
          child: Text(
            localizables.cancel,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: Text(
            localizables.grant_permissions,
          ),
          onPressed: () {
            openAppSettings();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
