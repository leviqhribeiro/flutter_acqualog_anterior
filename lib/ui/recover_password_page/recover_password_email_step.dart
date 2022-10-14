import 'package:canteiro/blocs/bloc_event.dart';
import 'package:canteiro/blocs/load_status.dart';
import 'package:canteiro/blocs/recover_password_page_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:canteiro/ui/widgets/load_action_button.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RecoverPasswordEmailStep extends StatefulWidget {
  @override
  _RecoverPasswordEmailStepState createState() =>
      _RecoverPasswordEmailStepState();
}

class _RecoverPasswordEmailStepState extends State<RecoverPasswordEmailStep> {
  TextEditingController emailController;
  final GlobalKey<FormFieldState> emailFieldKey = GlobalKey();

  @override
  void initState() {
    emailController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizable = AppLocalizations.of(context);
    return ListView(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      children: [
        Text(
          localizable.type_your_account_email,
          style: Theme.of(context)
              .textTheme
              .headline5
              .copyWith(fontWeight: FontWeight.w600),
        ),
        Text(
          localizable.this_email_receive_code,
          style: Theme.of(context)
              .textTheme
              .bodyText2
              .copyWith(color: Colors.grey),
        ),
        SizedBox(
          height: 60,
        ),
        TextFormField(
          key: emailFieldKey,
          controller: emailController,
          autofocus: true,
          decoration: InputDecoration(
            border: InputBorder.none,
            labelText: localizable.email,
            hintText: localizable.email_example,
          ),
          validator: (newValue) {
            if (!EmailValidator.validate(newValue)) {
              return localizable.invalidEmail;
            }
            return null;
          },
          autovalidateMode: AutovalidateMode.onUserInteraction,
          style: Theme.of(context).textTheme.headline6,
        ),
        SizedBox(
          height: 60,
        ),
        BlocBuilder<RecoverPasswordPageBloc, RecoverPasswordPageBlocState>(
            builder: (context, state) {
          return LoadActionButton(
            child: Text(
              localizable.send_code,
            ),
            isLoading: state.requestCodeStatus == LoadStatus.executing,
            onPressed: () {
              if (emailFieldKey.currentState.validate()) {
                BlocProvider.of<RecoverPasswordPageBloc>(context).add(BlocEvent(
                    RecoverPasswordPageBlocEvent.recoveryForEmail,
                    data: emailController.text),
                );
              }
            },
          );
        }),
      ],
    );
  }
}
