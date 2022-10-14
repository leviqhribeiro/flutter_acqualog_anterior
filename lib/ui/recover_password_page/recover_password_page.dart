import 'package:canteiro/blocs/bloc_event.dart';
import 'package:canteiro/blocs/load_status.dart';
import 'package:canteiro/blocs/recover_password_page_bloc.dart';
import 'package:canteiro/helpers/load_status_error_generic_feedback_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:canteiro/router.dart';
import 'package:canteiro/ui/dialogs/ok_dialog.dart';
import 'package:canteiro/ui/recover_password_page/recover_password_code_step.dart';
import 'package:canteiro/ui/recover_password_page/recover_password_email_step.dart';
import 'package:canteiro/ui/recover_password_page/recover_password_new_password_step.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RecoverPasswordPage extends StatefulWidget {
  @override
  _RecoverPasswordpageState createState() => _RecoverPasswordpageState();
}

class _RecoverPasswordpageState extends State<RecoverPasswordPage> {
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
    final localizable = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          localizable.recover_account_flow,
        ),
      ),
      body: BlocProvider(
        create: (context) =>
            RecoverPasswordPageBloc(RecoverPasswordPageBlocState()),
        child: MultiBlocListener(
          listeners: [
            BlocListener<RecoverPasswordPageBloc, RecoverPasswordPageBlocState>(
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
            BlocListener<RecoverPasswordPageBloc, RecoverPasswordPageBlocState>(
              listenWhen: (oldState, newState) =>
                  oldState.requestCodeStatus != newState.requestCodeStatus,
              listener: _onRequestCodeStatusChangeListener,
            ),
            BlocListener<RecoverPasswordPageBloc, RecoverPasswordPageBlocState>(
              listenWhen: (oldState, newState) =>
                  oldState.verifyCodeStatus != newState.verifyCodeStatus,
              listener: _onVerifyCodeStatusChangeListener,
            ),
            BlocListener<RecoverPasswordPageBloc, RecoverPasswordPageBlocState>(
              listenWhen: (oldState, newState) =>
                  oldState.resetPasswordStatus != newState.resetPasswordStatus,
              listener: _onResetPasswordStatusChangeListener,
            ),
          ],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.all(20),
                child: BlocBuilder<RecoverPasswordPageBloc,
                    RecoverPasswordPageBlocState>(
                  builder: (context, state) {
                    return LinearProgressIndicator(
                      value: state.currentStep / state.lastStep,
                    );
                  },
                ),
              ),
              Expanded(
                child: BlocBuilder<RecoverPasswordPageBloc,
                    RecoverPasswordPageBlocState>(
                  buildWhen: (oldState, newState) =>
                      oldState.currentStep != newState.currentStep,
                  builder: (context, state) {
                    return PageView(
                      controller: _pageController,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        RecoverPasswordEmailStep(),
                        RecoverPasswordCodeStep(),
                        RecoverPasswordNewPasswordStep(),
                      ],
                    );
                  },
                ),
              ),
              BlocBuilder<RecoverPasswordPageBloc,
                  RecoverPasswordPageBlocState>(
                buildWhen: (oldState, newState) =>
                    oldState.currentStep != newState.currentStep,
                builder: (context, state) {
                  return AnimatedSwitcher(
                    duration: Duration(
                      milliseconds: 400,
                    ),
                    child: state.currentStep > 0
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
            BlocProvider.of<RecoverPasswordPageBloc>(context)
                .add(BlocEvent(RecoverPasswordPageBlocEvent.backStep));
          },
        ),
      ],
    );
  }

  void _onRequestCodeStatusChangeListener(
      BuildContext context, RecoverPasswordPageBlocState state) {
    final localizable = AppLocalizations.of(context);
    if (state.requestCodeStatus == LoadStatus.failed) {
      showDialog(
        context: context,
        builder: (context) {
          return OkDialog(
            title: localizable.recover_account_flow,
            message: localizable.failed_to_request_code,
            onOKPressed: () {
              Navigator.of(context).pop();
            },
          );
        },
      );
    } else if (state.requestCodeStatus.hasError) {
      LoadStatusErrorGenericFeedbackHelper.showSnackbarForLoadStatus(
        context: context,
        loadStatus: state.requestCodeStatus,
      );
    } else if (state.requestCodeStatus == LoadStatus.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
          localizable.code_sent,
        )),
      );
    }
  }

  void _onVerifyCodeStatusChangeListener(
      BuildContext context, RecoverPasswordPageBlocState state) {
    if (state.verifyCodeStatus == LoadStatus.failed) {
      final localizable = AppLocalizations.of(context);
      showDialog(
        context: context,
        builder: (context) {
          return OkDialog(
            title: localizable.recover_account_flow,
            message: localizable.invalid_or_expired_code,
            onOKPressed: () {
              Navigator.of(context).pop();
            },
          );
        },
      );
    } else if(state.verifyCodeStatus.hasError){
      LoadStatusErrorGenericFeedbackHelper.showSnackbarForLoadStatus(
        context: context,
        loadStatus: state.verifyCodeStatus,
      );
    }
  }

  void _onResetPasswordStatusChangeListener(
      BuildContext context, RecoverPasswordPageBlocState state) {
    if ([LoadStatus.failed, LoadStatus.success]
        .contains(state.resetPasswordStatus)) {
      final localizable = AppLocalizations.of(context);
      final isSuccess = state.resetPasswordStatus == LoadStatus.success;
      final message = isSuccess
          ? localizable.success_updating_password
          : localizable.failed_updating_password;
      showDialog(
        context: context,
        builder: (context) {
          return OkDialog(
            title: localizable.recover_account_flow,
            message: message,
            onOKPressed: () {
              if (isSuccess) {
                Navigator.of(context).popUntil(
                    (route) => route.settings.name == AppRouter.login);
              } else {
                Navigator.of(context).pop();
              }
            },
          );
        },
      );
    } else if (state.resetPasswordStatus.hasError) {
      LoadStatusErrorGenericFeedbackHelper.showSnackbarForLoadStatus(
        context: context,
        loadStatus: state.resetPasswordStatus,
      );
    }
  }
}
