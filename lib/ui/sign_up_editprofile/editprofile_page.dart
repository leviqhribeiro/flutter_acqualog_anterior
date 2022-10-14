import 'package:canteiro/blocs/app_bloc.dart';
import 'package:canteiro/blocs/bloc_event.dart';
import 'package:canteiro/blocs/load_status.dart';
import 'package:canteiro/blocs/sign_up_editprofile_bloc.dart';
import 'package:canteiro/helpers/load_status_error_generic_feedback_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:canteiro/models/manager.dart';
import 'package:canteiro/router.dart';
import 'package:canteiro/ui/dialogs/ok_dialog.dart';
import 'package:canteiro/ui/sign_up_editprofile/address_step.dart';
import 'package:canteiro/ui/sign_up_editprofile/email_step.dart';
import 'package:canteiro/ui/sign_up_editprofile/manager_step.dart';
import 'package:canteiro/ui/sign_up_editprofile/name_step.dart';
import 'package:canteiro/ui/sign_up_editprofile/residentscount_step.dart';
import 'package:canteiro/ui/sign_up_editprofile/review_informations_step.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  PageController _pageController;

  @override
  void initState() {
    _pageController = PageController(initialPage: 5);
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
        title: Text(localized.edit_profile),
      ),
      body: BlocProvider(
        create: (context) {
          final account = BlocProvider.of<AppBloc>(context).state.user.account;
          return SignUpEditProfileBloc(
              SignUpEditProfileBlocState(
                SignUpEditProfileBlocMode.editProfile,
                name: account.name,
                email: account.email,
                address: account.address,
                manager: Manager(account.managerId, account.managerName),
                residentsCount: account.numberResidents,
              ),
              userId: BlocProvider.of<AppBloc>(context).state.user.id);
        },
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
              listener: _onLoadStatusChangeListener,
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

  void _onLoadStatusChangeListener(
      BuildContext context, SignUpEditProfileBlocState state) {
    final localizable = AppLocalizations.of(context);
    bool showAlert =
        [LoadStatus.failed, LoadStatus.success].contains(state.loadStatus);

    if (state.loadStatus == LoadStatus.success) {
      BlocProvider.of<AppBloc>(context)
          .add(BlocEvent(AppBlocEvent.reloadUserData));
    }
    bool hasError = state.loadStatus.hasError;
    if (showAlert) {
      String message = hasError
          ? localizable.editProfileFailed
          : localizable.editProfileSuccess;

      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return OkDialog(
                title: localizable.edit_profile,
                message: message,
                onOKPressed: () {
                  if (!hasError) {
                    Navigator.of(context).popUntil(
                        (route) => route.settings.name == AppRouter.home);
                  } else {
                    Navigator.of(context).pop();
                  }
                });
          });
    } else {
      LoadStatusErrorGenericFeedbackHelper.showSnackbarForLoadStatus(
        context: context,
        loadStatus: state.loadStatus,
      );
    }
  }
}
