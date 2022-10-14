import 'package:canteiro/blocs/bloc_event.dart';
import 'package:canteiro/blocs/sign_up_editprofile_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NameStep extends StatefulWidget {
  @override
  _NameStepState createState() => _NameStepState();
}

class _NameStepState extends State<NameStep> {
  TextEditingController nameController;
  final GlobalKey<FormFieldState> nameFieldKey = GlobalKey();

  @override
  void initState() {
    SignUpEditProfileBlocState state = BlocProvider.of<SignUpEditProfileBloc>(context).state;
    nameController = TextEditingController(text: state.name);
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizable = AppLocalizations.of(context);
    return ListView(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      children: [
        Text(
          localizable.your_name_please,
          style: Theme.of(context)
              .textTheme
              .headline5
              .copyWith(fontWeight: FontWeight.w600),
        ),
        SizedBox(
          height: 60,
        ),
        TextFormField(
          key: nameFieldKey,
          controller: nameController,
          autofocus: true,
          keyboardType: TextInputType.name,
          decoration: InputDecoration(
            border: InputBorder.none,
            labelText: localizable.name,
            hintText: localizable.name_example,
          ),
          validator: (newValue) {
            if (newValue == null || newValue.isEmpty) {
              return localizable.invalidName;
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
            if (nameFieldKey.currentState.validate()) {
              BlocProvider.of<SignUpEditProfileBloc>(context).add(
                BlocEvent(SignUpEditProfileBlocEvent.addName,
                    data: nameController.text),
              );
            }
          },
        ),
      ],
    );
  }
}
