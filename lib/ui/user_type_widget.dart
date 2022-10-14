import 'package:canteiro/l10n/app_localizations_constants.dart';
import 'package:canteiro/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UserTypeWidget extends StatelessWidget {
  const UserTypeWidget({@required this.userType, Key key}) : super(key: key);

  final UserType userType;

  @override
  Widget build(BuildContext context) {
    final localizable = AppLocalizations.of(context);
    return Container(
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: userType == UserType.manager ? Theme.of(context).primaryColor : Colors.lightGreen,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        AppLocalizationsConstants.textForUserType(localizable, userType),
        style: Theme.of(context).textTheme.caption.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
