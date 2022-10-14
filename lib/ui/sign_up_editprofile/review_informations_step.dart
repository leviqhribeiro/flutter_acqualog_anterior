import 'package:canteiro/blocs/bloc_event.dart';
import 'package:canteiro/blocs/load_status.dart';
import 'package:canteiro/blocs/sign_up_editprofile_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:canteiro/ui/widgets/load_action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReviewInformationsStep extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final localizable = AppLocalizations.of(context);
    return BlocConsumer<SignUpEditProfileBloc, SignUpEditProfileBlocState>(
        listener: (context, state) {},
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Text(
                  localizable.reviewInformations,
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
                child: ListView(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  children: [
                    ListTile(
                      title: Text(
                        localizable.name,
                      ),
                      subtitle: Text(
                        state.name,
                      ),
                      trailing: Icon(Icons.chevron_right),
                      onTap: () => _editStep(
                          context: context, step: SignUpEditProfileStep.name),
                    ),
                    Divider(),
                    ListTile(
                      title: Text(
                        state.addressIsDefined
                            ? localizable.address
                            : localizable.define_address,
                      ),
                      subtitle: state.addressIsDefined
                          ? Text(
                              '${state.address.street} ${state.address.number} ${state.address.neighborhood}',
                            )
                          : null,
                      trailing: Icon(Icons.chevron_right),
                      onTap: () => _editStep(
                          context: context,
                          step: SignUpEditProfileStep.address),
                    ),
                    Divider(),
                    ListTile(
                      title: Text(
                        localizable.numberResidents,
                      ),
                      subtitle: Text(
                        '${state.residentsCount}',
                      ),
                      trailing: Icon(Icons.chevron_right),
                      onTap: () => _editStep(
                          context: context,
                          step: SignUpEditProfileStep.residentCount),
                    ),
                    Divider(),
                    ListTile(
                      title: Text(
                        localizable.manager,
                      ),
                      subtitle: Text(
                        '${state.manager.name}',
                      ),
                      trailing: Icon(Icons.chevron_right),
                      onTap: () => _editStep(
                          context: context,
                          step: SignUpEditProfileStep.manager),
                    ),
                    Divider(),
                    ListTile(
                      title: Text(
                        localizable.email,
                      ),
                      subtitle: Text(
                        '${state.email}',
                      ),
                      trailing: Icon(Icons.chevron_right),
                      onTap: () => _editStep(
                          context: context, step: SignUpEditProfileStep.email),
                    ),
                    if (state.mode == SignUpEditProfileBlocMode.signUp) ...[
                      Divider(),
                      ListTile(
                        title: Text(
                          localizable.password,
                        ),
                        subtitle: Text(
                          '*****',
                        ),
                        trailing: Icon(Icons.chevron_right),
                        onTap: () => _editStep(
                            context: context,
                            step: SignUpEditProfileStep.password),
                      ),
                    ]
                  ],
                ),
              ),
              Divider(),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                child: LoadActionButton(
                  isLoading: state.loadStatus ==
                      LoadStatus.executing,
                  child: Text(localizable.confirm),
                  onPressed: () => _onConfirmButtonPressed(context, state),
                ),
              )
            ],
          );
        });
  }

  void _editStep(
      {@required BuildContext context, @required SignUpEditProfileStep step}) {
    BlocProvider.of<SignUpEditProfileBloc>(context).add(
      BlocEvent(SignUpEditProfileBlocEvent.editStep, data: step),
    );
  }

  void _onConfirmButtonPressed(BuildContext context, SignUpEditProfileBlocState state){
    if(state.addressIsDefined) {
      final event = state.mode == SignUpEditProfileBlocMode.signUp
          ? SignUpEditProfileBlocEvent.signUp
          : SignUpEditProfileBlocEvent.editProfile;
      BlocProvider.of<SignUpEditProfileBloc>(context).add(
        BlocEvent(event),
      );
    }
    else {
      final localizable = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(
            localizable.address_obligated_field,
          ),)
      );
    }
  }
}
