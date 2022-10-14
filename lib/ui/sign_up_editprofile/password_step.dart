import 'package:canteiro/blocs/bloc_event.dart';
import 'package:canteiro/blocs/sign_up_editprofile_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PasswordStep extends StatefulWidget {
  @override
  _PasswordStepState createState() => _PasswordStepState();
}

class _PasswordStepState extends State<PasswordStep> {
  TextEditingController newPasswordController;
  TextEditingController confirmPasswordController;
  GlobalKey<FormState> _formKey = GlobalKey();
  FocusNode _confirmPasswordFocusNode;

  @override
  void initState() {
    final state = BlocProvider.of<SignUpEditProfileBloc>(context).state;
    newPasswordController = TextEditingController(text: state.password);
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
          localizable.yourPassword,
          style: Theme.of(context)
              .textTheme
              .headline5
              .copyWith(fontWeight: FontWeight.w600),
        ),
        Text(
          localizable.thisIsYourAccountPassword,
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
                  labelText: localizable.password,
                ),
                onFieldSubmitted: (newValue) {
                  FocusScope.of(context)
                      .requestFocus(_confirmPasswordFocusNode);
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
        ElevatedButton(
            child: Text(
              localizable.next,
            ),
            onPressed: () {
              BlocProvider.of<SignUpEditProfileBloc>(context).add(BlocEvent(SignUpEditProfileBlocEvent.addPassword,data: newPasswordController.text));
            }),
      ],
    );
  }
}
