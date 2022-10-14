import 'package:canteiro/blocs/app_bloc.dart';
import 'package:canteiro/blocs/bloc_event.dart';
import 'package:canteiro/models/user.dart';
import 'package:canteiro/ui/user_type_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:canteiro/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppBlocState>(
        buildWhen: (oldState, newState) =>
            oldState.user != newState.user && newState.user != null,
        builder: (context, state) {
          final localizable = AppLocalizations.of(context);
          final account = state.user.account;
          final containsAddress = account.address != null;
          final isClient = account.userType == UserType.client;
          return ListView(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            children: [
              SizedBox(
                height: 40,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _buildHelloUser(account.name, localizable),
                    maxLines: 2,
                    style: Theme.of(context).textTheme.headline4.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor),
                  ),
                  Spacer(),
                  if(isClient)
                    MaterialButton(
                        child: Text('Editar'),
                        onPressed: () {
                          Navigator.of(context).pushNamed(AppRouter.editProfile);
                        },
                    ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Center(
                child: UserTypeWidget(
                  userType: account.userType,
                ),
              ),
              SizedBox(
                height: 60,
              ),
              ListTile(
                title: Text(
                  localizable.email,
                ),
                subtitle: Text(
                  account.email,
                ),
              ),
              Divider(),
              if(containsAddress)
                ...[
                  ListTile(
                    title: Text(
                      localizable.address,
                    ),
                    subtitle: Text(
                        '${account.address.street} ${account.address.number != null ? account.address.number : ''}, ${account.address.neighborhood}'),
                  ),
                  Divider(),
                ],
              if(isClient)
                ...[
                  ListTile(
                    title: Text(
                      localizable.numberResidents,
                    ),
                    subtitle: Text(
                      '${account.numberResidents ?? 0}',
                    ),
                  ),
                  Divider(),
                  ListTile(
                    title: Text(
                      localizable.manager,
                    ),
                    subtitle: Text(
                      account.managerName ?? '',
                    ),
                  ),
                  Divider(),
                ],
              SizedBox(
                height: 20,
              ),
              MaterialButton(
                child: Text(
                  localizable.signOut,
                  style: TextStyle(color: Colors.redAccent),
                ),
                onPressed: () {
                  _onSignOutButtonPressed(context);
                },
              )
            ],
          );
        });
  }

  String _buildHelloUser(String username, AppLocalizations localizable) {
    final slipts = username.split(' ');
    final name =
        slipts.length > 1 ? slipts.first + ' ' + slipts[1] : slipts.first;
    return localizable.helloUser(name);
  }

  void _onSignOutButtonPressed(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          final localizable = AppLocalizations.of(context);
          return AlertDialog(
            title: Text(
              localizable.signOut,
            ),
            content: Text(
              localizable.doYouWantSignOut,
            ),
            actions: [
              TextButton(
                child: Text(
                  localizable.no,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: Text(
                  localizable.yes,
                  style: TextStyle(
                    color: Colors.redAccent,
                  ),
                ),
                onPressed: () {
                  BlocProvider.of<AppBloc>(context)
                      .add(BlocEvent(AppBlocEvent.performSignOut));
                  Navigator.of(context).pushReplacementNamed(AppRouter.login);
                },
              ),
            ],
          );
        });
  }
}
