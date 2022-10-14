import 'package:canteiro/blocs/bloc_event.dart';
import 'package:canteiro/blocs/load_status.dart';
import 'package:canteiro/blocs/sign_up_editprofile_bloc.dart';
import 'package:canteiro/helpers/load_status_error_generic_feedback_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:canteiro/router.dart';
import 'package:canteiro/ui/dialogs/ok_dialog.dart';
import 'package:canteiro/ui/sign_up_editprofile/address_step.dart';
import 'package:canteiro/ui/sign_up_editprofile/email_step.dart';
import 'package:canteiro/ui/sign_up_editprofile/manager_step.dart';
import 'package:canteiro/ui/sign_up_editprofile/name_step.dart';
import 'package:canteiro/ui/sign_up_editprofile/password_step.dart';
import 'package:canteiro/ui/sign_up_editprofile/residentscount_step.dart';
import 'package:canteiro/ui/sign_up_editprofile/review_informations_step.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  PageController _pageController;

  @override
  void initState() {
    _pageController = PageController();
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localized = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(localized.sign_up),
      ),
      body: BlocProvider(
        create: (context) => SignUpEditProfileBloc(SignUpEditProfileBlocState(
          SignUpEditProfileBlocMode.signUp,
        )),
        child: MultiBlocListener(
          listeners: [
            BlocListener<SignUpEditProfileBloc, SignUpEditProfileBlocState>(
              listenWhen: (oldState, newState) =>
                  oldState.currentStep != newState.currentStep,
              listener: (context, state) {
                _pageController.animateToPage(
                  state.currentStep,
                  duration: Duration(milliseconds: 800),
                  curve: Curves.linearToEaseOut,
                );
              },
            ),
            BlocListener<SignUpEditProfileBloc, SignUpEditProfileBlocState>(
              listenWhen: (oldState, newState) =>
                  oldState.loadStatus != newState.loadStatus,
              listener: _onSignUpStatusChangeListener,
            ),
          ],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.all(20),
                child: BlocBuilder<SignUpEditProfileBloc,
                    SignUpEditProfileBlocState>(
                  builder: (context, state) {
                    return LinearProgressIndicator(
                      value: state.currentStep / state.lastStep,
                    );
                  },
                ),
              ),
              Expanded(
                child: BlocBuilder<SignUpEditProfileBloc,
                    SignUpEditProfileBlocState>(
                  buildWhen: (oldState, newState) =>
                      oldState.currentStep != newState.currentStep,
                  builder: (context, state) {
                    return PageView(
                      controller: _pageController,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        NameStep(),
                        AddressStep(),
                        ResidentsCountStep(),
                        ManagerStep(),
                        EmailStep(),
                        PasswordStep(),
                        ReviewInformationsStep(),
                      ],
                    );
                  },
                ),
              ),
              BlocBuilder<SignUpEditProfileBloc, SignUpEditProfileBlocState>(
                buildWhen: (oldState, newState) =>
                    oldState.currentStep != newState.currentStep,
                builder: (context, state) {
                  return AnimatedSwitcher(
                    duration: Duration(
                      milliseconds: 400,
                    ),
                    child: state.currentStep > 0 &&
                            state.currentStep < state.lastStep - 1 &&
                            !state.editMode
                        ? _buildFooterWidget(context)
                        : SizedBox.shrink(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooterWidget(BuildContext context) {
    final localizable = AppLocalizations.of(context);
    return Row(
      children: [
        TextButton(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(Icons.chevron_left),
              Text(
                localizable.back,
              ),
            ],
          ),
          onPressed: () {
            BlocProvider.of<SignUpEditProfileBloc>(context)
                .add(BlocEvent(SignUpEditProfileBlocEvent.backStep));
          },
        ),
      ],
    );
  }

  void _onSignUpStatusChangeListener(
      BuildContext context, SignUpEditProfileBlocState state) {
    final localizable = AppLocalizations.of(context);
    bool showAlert =
        [LoadStatus.failed, LoadStatus.success].contains(state.loadStatus);
    bool hasError = state.loadStatus.hasError;
    if (showAlert) {
      String message =
          hasError ? localizable.signUpFailed : localizable.signUpSuccess;

      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return OkDialog(
                title: localizable.sign_up,
                message: message,
                onOKPressed: () {
                  if (!hasError) {
                    Navigator.of(context).popUntil(
                        (route) => route.settings.name == AppRouter.login);
                  } else {
                    Navigator.of(context).pop();
                  }
                });
          });
    } else if (hasError) {
      LoadStatusErrorGenericFeedbackHelper.showSnackbarForLoadStatus(
        context: context,
        loadStatus: state.loadStatus,
      );
    }
  }
}
