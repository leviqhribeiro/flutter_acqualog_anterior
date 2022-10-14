import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter/material.dart';

class OkDialog extends StatelessWidget {
  OkDialog({
    @required this.title,
    @required this.message,
    @required this.onOKPressed,
    Key key,
}):super(key: key);

  final title;
  final message;
  final void Function() onOKPressed;

  @override
  Widget build(BuildContext context) {
    final localizable = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(
        title,
      ),
      content: Text(
        message
      ),
      actions: [
        TextButton(onPressed: onOKPressed, child: Text(
        localizable.ok,
        ),
    ),
      ],
    );
  }
}