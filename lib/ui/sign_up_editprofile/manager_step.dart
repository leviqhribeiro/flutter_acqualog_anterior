import 'package:canteiro/blocs/bloc_event.dart';
import 'package:canteiro/blocs/sign_up_editprofile_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:canteiro/models/manager.dart';
import 'package:canteiro/resources/repository.dart';
import 'package:canteiro/resources/user_api_provider.dart';
import 'package:canteiro/ui/widgets/load_info_widget.dart';
import 'package:canteiro/ui/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ManagerStep extends StatefulWidget {
  @override
  _ManagerStepState createState() => _ManagerStepState();
}

class _ManagerStepState extends State<ManagerStep> {
  Future<RequestResponse<List<Manager>>> _managersFuture;

  @override
  void initState() {
    _managersFuture = UserApiProvider().getManagers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final localizable = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Text(
            localizable.chooseManager,
            style: Theme.of(context)
                .textTheme
                .headline5
                .copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        SizedBox(
          height: 20,
        ),
        Expanded(
          child: FutureBuilder<RequestResponse<List<Manager>>>(
            future: _managersFuture,
            builder: (context, snapshot) {
              if ([ConnectionState.active, ConnectionState.waiting]
                  .contains(snapshot.connectionState)) {
                return LoadingWidget(
                  title: localizable.loadingManagers,
                );
              }

              if (snapshot.hasError ||
                  snapshot.data?.success == false ||
                  !snapshot.hasData || snapshot.data?.body == null) {
                final error =
                    snapshot.hasError || snapshot.data?.success == false;
                return LoadInfoWidget(
                  title: error
                      ? localizable.failedLoadingManagers
                      : localizable.noManagersFound,
                  reloadButtonTitle: localizable.try_again,
                  reloadAction: () {
                    setState(() {
                      _managersFuture = UserApiProvider().getManagers();
                    });
                  },
                );
              }

              return _buildManagersListWidget(snapshot.data?.body);
            },
          ),
        )
      ],
    );
  }

  Widget _buildManagersListWidget(List<Manager> managers) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      itemBuilder: (context, index) {
        final manager = managers[index];
        return ListTile(
          title: Text(
            manager.name,
            maxLines: 3,
            style: Theme.of(context).textTheme.headline6,
          ),
          trailing: Icon(Icons.chevron_right),
          onTap: () {
            BlocProvider.of<SignUpEditProfileBloc>(context)
                .add(BlocEvent(SignUpEditProfileBlocEvent.addManager, data: manager));
          },
        );
      },
      separatorBuilder: (context, index) => Divider(),
      itemCount: managers.length,
    );
  }
}
