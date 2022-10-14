import 'package:canteiro/blocs/bloc_event.dart';
import 'package:canteiro/blocs/load_status.dart';
import 'package:canteiro/blocs/recover_password_page_bloc.dart';
import 'package:canteiro/ui/widgets/load_action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

class RecoverPasswordCodeStep extends StatefulWidget {
  @override
  _RecoverPasswordCodeStepState createState() =>
      _RecoverPasswordCodeStepState();
}

class _RecoverPasswordCodeStepState extends State<RecoverPasswordCodeStep> {
  TextEditingController codeController;
  final GlobalKey<FormFieldState> codeFieldKey = GlobalKey();

  @override
  void initState() {
    codeController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizable = AppLocalizations.of(context);
    return ListView(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      children: [
        Text(
          localizable.type_recovery_code,
          style: Theme.of(context)
              .textTheme
              .headline5
              .copyWith(fontWeight: FontWeight.w600),
        ),
        BlocBuilder<RecoverPasswordPageBloc, RecoverPasswordPageBlocState>(
          builder: (context, state) {
            return Text(
              localizable.thisCodeYouReceiveEmail(state.recoveryEmail),
              style: Theme.of(context)
                  .textTheme
                  .bodyText2
                  .copyWith(color: Colors.grey),
            );
          },
        ),
        SizedBox(
          height: 60,
        ),
        TextFormField(
          key: codeFieldKey,
          controller: codeController,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            border: InputBorder.none,
            labelText: localizable.code,
            hintText: '######',
          ),
          validator: (code){
            if(code.length < 6) {
              return localizable.invalid_code_format;
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
                localizable.validate_code,
              ),
              isLoading: state.verifyCodeStatus == LoadStatus.executing,
              onPressed: () {
                if (codeFieldKey.currentState.validate()) {
                  BlocProvider.of<RecoverPasswordPageBloc>(context).add(
                    BlocEvent(RecoverPasswordPageBlocEvent.verifyCode,
                      data: codeController.text,
                    ),
                  );
                }
              },
            );
          },
        ),
        TextButton(
          child: Text(
              localizable.resent_code
          ),
          onPressed: (){
            BlocProvider.of<RecoverPasswordPageBloc>(context).add(
              BlocEvent(RecoverPasswordPageBlocEvent.resendCode,),
            );
          },
        )
      ],
    );
  }
}
