import 'package:canteiro/blocs/app_bloc.dart';
import 'package:canteiro/blocs/load_status.dart';
import 'package:canteiro/helpers/load_status_error_generic_feedback_helper.dart';
import 'package:canteiro/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ExtendedLaunchScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AppBloc, AppBlocState>(
        listenWhen: (oldState, newState) =>
            oldState.refreshStatus != newState.refreshStatus,
        listener: (context, state) {
          if (state.refreshStatus == LoadStatus.success) {
            Navigator.of(context).pushReplacementNamed(AppRouter.home);
          } else if (state.refreshStatus.hasError) {
            Navigator.of(context).pushReplacementNamed(AppRouter.login);
            final needToPresentFeedback =
                state.refreshStatus != LoadStatus.failed;
            if (needToPresentFeedback) {
              LoadStatusErrorGenericFeedbackHelper.showSnackbarForLoadStatus(
                context: context,
                loadStatus: state.refreshStatus,
              );
            }
          }
        },
        child: LaunchScreenPage(),
      ),
    );
  }
}

class LaunchScreenPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: 'logo',
              child: ConstrainedBox(
                constraints: BoxConstraints.loose(Size.fromWidth(200)),
                child: Image.asset(
                  "assets/images/logo.png",
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            ConstrainedBox(
              constraints: BoxConstraints.loose(Size.fromWidth(200)),
              child: LinearProgressIndicator(),
            )
          ],
        ),
      ),
    );
  }
}
