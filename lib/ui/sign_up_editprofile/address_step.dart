import 'package:canteiro/blocs/bloc_event.dart';
import 'package:canteiro/blocs/sign_up_editprofile_bloc.dart';
import 'package:canteiro/helpers/mask_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:canteiro/models/address.dart';
import 'package:canteiro/ui/sign_up_editprofile/address_city_uf_widget.dart';
import 'package:canteiro/ui/sign_up_editprofile/address_street_number_widget.dart';
import 'package:canteiro/ui/widgets/cep_text_editing_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddressStep extends StatefulWidget {
  @override
  _AddressStepState createState() => _AddressStepState();
}

class _AddressStepState extends State<AddressStep> {
  TextEditingController _zipCodeController;
  TextEditingController _streetController;
  TextEditingController _numberController;
  TextEditingController _neighborhoodController;
  TextEditingController _cityController;
  TextEditingController _ufController;
  TextEditingController _complementController;
  final GlobalKey<FormState> _formKey = GlobalKey();

  FocusNode _streetFocusNode;
  FocusNode _numberFocusNode;
  FocusNode _neighborhoodFocusNode;
  FocusNode _cityFocusNode;
  FocusNode _ufFocusNode;
  FocusNode _complementFocusNode;

  @override
  void initState() {
    SignUpEditProfileBlocState state =
        BlocProvider.of<SignUpEditProfileBloc>(context).state;
    _zipCodeController = TextEditingController(text: state.address?.cep);
    _streetController = TextEditingController(text: state.address?.street);
    _numberController = TextEditingController(text: state.address?.number);
    _neighborhoodController =
        TextEditingController(text: state.address?.neighborhood);
    _cityController = TextEditingController(text: state.address?.city);
    _ufController = TextEditingController(text: state.address?.state);
    _complementController =
        TextEditingController(text: state.address?.complement);
    _streetFocusNode = FocusNode();
    _numberFocusNode = FocusNode();
    _neighborhoodFocusNode = FocusNode();
    _cityFocusNode = FocusNode();
    _ufFocusNode = FocusNode();
    _complementFocusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _zipCodeController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _neighborhoodController.dispose();
    _cityController.dispose();
    _ufController.dispose();
    _complementController.dispose();
    _streetFocusNode.dispose();
    _numberFocusNode.dispose();
    _neighborhoodFocusNode.dispose();
    _cityFocusNode.dispose();
    _ufFocusNode.dispose();
    _complementFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizable = AppLocalizations.of(context);
    return BlocListener<SignUpEditProfileBloc, SignUpEditProfileBlocState>(
      listenWhen: (oldState, newState) => oldState.address != newState.address,
      listener: (context, state) {
        _streetController.text = state.address?.street ?? '';
        _numberController.text = state.address?.number ?? '';
        _neighborhoodController.text = state.address?.neighborhood ?? '';
        _cityController.text = state.address?.city ?? '';
        _ufController.text = state.address?.state ?? '';
        _complementController.text = state.address?.complement ?? '';
      },
      child: ListView(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        children: [
          Text(
            localizable.what_your_address,
            style: Theme.of(context)
                .textTheme
                .headline5
                .copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(
            height: 20,
          ),
          Form(
            key: _formKey,
            child: Column(
              children: [
                CEPTextEditingFormField(
                  zipCodeController: _zipCodeController,
                  autoFocus: true,
                  onFieldSubmitted: (address) {
                    BlocProvider.of<SignUpEditProfileBloc>(context).add(
                        BlocEvent(SignUpEditProfileBlocEvent.addAddressByCEP,
                            data: address));
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                AddressStreetNumberWidget(
                  streetFocusNode: _streetFocusNode,
                  streetController: _streetController,
                  numberController: _numberController,
                  numberFocusNode: _numberFocusNode,
                  onFieldSubmitted: (street, number) => FocusScope.of(context)
                      .requestFocus(_neighborhoodFocusNode),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  focusNode: _neighborhoodFocusNode,
                  controller: _neighborhoodController,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: localizable.neighborhood,
                  ),
                  validator: (newValue) {
                    if (newValue == null || newValue.isEmpty) {
                      return localizable.obligatedField;
                    }
                    return null;
                  },
                  onFieldSubmitted: (value) =>
                      FocusScope.of(context).requestFocus(_cityFocusNode),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                const SizedBox(
                  height: 10,
                ),
                AddressCityUFWidget(
                  cityController: _cityController,
                  cityFocusNode: _cityFocusNode,
                  ufController: _ufController,
                  ufFocusNode: _ufFocusNode,
                  onFieldSubmitted: (city, uf) =>
                      FocusScope.of(context).requestFocus(_complementFocusNode),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  focusNode: _complementFocusNode,
                  controller: _complementController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: localizable.complement,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          ElevatedButton(
            child: Text(
              localizable.next,
            ),
            onPressed: () {
              if (_formKey.currentState.validate()) {
                final address = Address(
                  street: _streetController.text,
                  state: _ufController.text,
                  complement: _complementController.text,
                  neighborhood: _neighborhoodController.text,
                  city: _cityController.text,
                  cep: MaskHelper.unmask(_zipCodeController.text),
                  number: _numberController.text,
                );

                BlocProvider.of<SignUpEditProfileBloc>(context).add(BlocEvent(
                    SignUpEditProfileBlocEvent.addAddress,
                    data: address));
              }
            },
          ),
        ],
      ),
    );
  }
}
