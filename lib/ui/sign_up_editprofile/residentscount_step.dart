import 'package:canteiro/blocs/bloc_event.dart';
import 'package:canteiro/blocs/sign_up_editprofile_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ResidentsCountStep extends StatefulWidget {
  @override
  _ResidentsCountStepState createState() => _ResidentsCountStepState();
}

class _ResidentsCountStepState extends State<ResidentsCountStep> {
  TextEditingController residentsCountController;
  final GlobalKey<FormFieldState> residentsCountFieldKey = GlobalKey();

  @override
  void initState() {
    SignUpEditProfileBlocState state = BlocProvider.of<SignUpEditProfileBloc>(context).state;
    residentsCountController = TextEditingController(text: '${state.residentsCount}');
    super.initState();
  }

  @override
  void dispose() {
    residentsCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizable = AppLocalizations.of(context);
    return ListView(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      children: [
        Text(
          localizable.whatsNumberOfResidents,
          style: Theme.of(context)
              .textTheme
              .headline5
              .copyWith(fontWeight: FontWeight.w600),
        ),
        Text(
          localizable.residentsCountingWithYou,
          style: Theme.of(context)
              .textTheme
              .bodyText2
              .copyWith(color: Colors.grey),
        ),
        SizedBox(
          height: 60,
        ),
        TextFormField(
          key: residentsCountFieldKey,
          controller: residentsCountController,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            border: InputBorder.none,
            labelText: localizable.numberResidents,
          ),
          validator: (newValue) {
            final count = int.tryParse(newValue);
            if (count == null || count < 0) {
              return localizable.invalidResidentsCount;
            }
            return null;
          },
          autovalidateMode: AutovalidateMode.onUserInteraction,
          style: Theme.of(context).textTheme.headline6,
        ),
        SizedBox(
          height: 60,
        ),
        ElevatedButton(
          child: Text(
            localizable.next,
          ),
          onPressed: () {
            if (residentsCountFieldKey.currentState.validate()) {
              BlocProvider.of<SignUpEditProfileBloc>(context).add(
                BlocEvent(SignUpEditProfileBlocEvent.addResidentCount,
                    data: int.tryParse(residentsCountController.text)),
              );
            }
          },
        ),
      ],
    );
  }

}
