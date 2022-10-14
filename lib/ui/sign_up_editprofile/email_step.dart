import 'package:canteiro/blocs/bloc_event.dart';
import 'package:canteiro/blocs/load_status.dart';
import 'package:canteiro/blocs/sign_up_editprofile_bloc.dart';
import 'package:canteiro/helpers/load_status_error_generic_feedback_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:canteiro/ui/widgets/load_action_button.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EmailStep extends StatefulWidget {
  @override
  _EmailStepState createState() => _EmailStepState();
}

class _EmailStepState extends State<EmailStep> {
  TextEditingController emailController;
  final GlobalKey<FormFieldState> emailFieldKey = GlobalKey();

  @override
  void initState() {
    SignUpEditProfileBlocState state =
        BlocProvider.of<SignUpEditProfileBloc>(context).state;
    emailController = TextEditingController(text: state.email);
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
    return BlocListener<SignUpEditProfileBloc, SignUpEditProfileBlocState>(
      listenWhen: (oldState, newState) =>
          oldState.emailStatus != newState.emailStatus,
      listener: (context, state) {
        if (state.emailStatus == LoadStatus.emailUnavailable) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
            localizable.emailUnavailable,
          )));
        } else if (state.emailStatus.hasError) {
          LoadStatusErrorGenericFeedbackHelper.showSnackbarForLoadStatus(
            context: context,
            loadStatus: state.emailStatus,
          );
        }
      },
      child: ListView(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        children: [
          Text(
            localizable.now_need_your_email,
            style: Theme.of(context)
                .textTheme
                .headline5
                .copyWith(fontWeight: FontWeight.w600),
          ),
          Text(
            localizable.this_email_use_login,
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
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              border: InputBorder.none,
              labelText: localizable.email,
              hintText: localizable.email_example,
            ),
            validator: (newValue) {
              if (!EmailValidator.validate(newValue.trim())) {
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
          BlocBuilder<SignUpEditProfileBloc, SignUpEditProfileBlocState>(
              builder: (context, state) {
            return LoadActionButton(
              child: Text(
                localizable.next,
              ),
              isLoading: state.emailStatus == LoadStatus.executing,
              onPressed: () {
                if (emailFieldKey.currentState.validate()) {
                  String email = emailController.text.trim();
                  BlocProvider.of<SignUpEditProfileBloc>(context).add(
                    BlocEvent(
                      SignUpEditProfileBlocEvent.validateAndAddEmail,
                      data: email,
                    ),
                  );
                }
              },
            );
          }),
        ],
      ),
    );
  }
}
