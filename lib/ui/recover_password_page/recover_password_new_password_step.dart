import 'package:canteiro/blocs/bloc_event.dart';
import 'package:canteiro/blocs/load_status.dart';
import 'package:canteiro/blocs/recover_password_page_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:canteiro/ui/widgets/load_action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RecoverPasswordNewPasswordStep extends StatefulWidget {
  @override
  _RecoverPasswordNewPasswordStepState createState() => _RecoverPasswordNewPasswordStepState();
}

class _RecoverPasswordNewPasswordStepState extends State<RecoverPasswordNewPasswordStep> {
  TextEditingController newPasswordController;
  TextEditingController confirmPasswordController;
  GlobalKey<FormState> _formKey = GlobalKey();
  FocusNode _confirmPasswordFocusNode;

  @override
  void initState() {
    newPasswordController = TextEditingController();
    _confirmPasswordFocusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    newPasswordController.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizable = AppLocalizations.of(context);
    return ListView(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      children: [
        Text(
          localizable.type_new_password,
          style: Theme.of(context)
              .textTheme
              .headline5
              .copyWith(fontWeight: FontWeight.w600),
        ),
        Text(
          localizable.this_will_be_new_password,
          style: Theme.of(context)
              .textTheme
              .bodyText2
              .copyWith(color: Colors.grey),
        ),
        SizedBox(
          height: 60,
        ),
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: newPasswordController,
                autofocus: true,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelText: localizable.new_password,
                ),
                onFieldSubmitted: (newValue){
                  FocusScope.of(context).requestFocus(_confirmPasswordFocusNode);
                },
                validator: (newValue) {
                  if (newValue == null || newValue.isEmpty) {
                    return localizable.invalid_passsword;
                  }
                  return null;
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
                style: Theme.of(context).textTheme.headline6,
              ),
              TextFormField(
                focusNode: _confirmPasswordFocusNode,
                controller: confirmPasswordController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelText: localizable.confirm_password,
                ),
                validator: (newValue) {
                  if (newPasswordController.text != newValue) {
                    return localizable.password_not_corresponding;
                  }
                  return null;
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
                style: Theme.of(context).textTheme.headline6,
              ),
            ],
          ),
        ),
        SizedBox(
          height: 60,
        ),
        BlocBuilder<RecoverPasswordPageBloc, RecoverPasswordPageBlocState>(
            builder: (context, state) {
              return LoadActionButton(
                child: Text(
                  localizable.reset_password,
                ),
                isLoading: state.resetPasswordStatus == LoadStatus.executing,
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    BlocProvider.of<RecoverPasswordPageBloc>(context).add(BlocEvent(
                        RecoverPasswordPageBlocEvent.resetPassword,
                        data: newPasswordController.text),
                    );
                  }
                },
              );
            }),
      ],
    );
  }
}
