import 'package:canteiro/blocs/add_consumption_page_bloc.dart';
import 'package:canteiro/blocs/app_bloc.dart';
import 'package:canteiro/blocs/bloc_event.dart';
import 'package:canteiro/blocs/dashboard_page_bloc.dart';
import 'package:canteiro/blocs/load_status.dart';
import 'package:canteiro/helpers/load_status_error_generic_feedback_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:canteiro/models/consumption_measurement_units.dart';
import 'package:canteiro/models/single_consumption.dart';
import 'package:canteiro/router.dart';
import 'package:canteiro/ui/add_consumption_page/add_consumption_validators.dart';
import 'package:canteiro/ui/add_consumption_page/consumption_value_widget.dart';
import 'package:canteiro/ui/add_consumption_page/currency_text_form_field.dart';
import 'package:canteiro/ui/add_consumption_page/canteiro_date_time_text_form_field.dart';
import 'package:canteiro/ui/dialogs/ok_dialog.dart';
import 'package:canteiro/ui/widgets/load_action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class AddConsumptionPage extends StatefulWidget {
  @override
  _AddConsumptionPageState createState() => _AddConsumptionPageState();
}

class _AddConsumptionPageState extends State<AddConsumptionPage> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  TextEditingController _residenceController;
  TextEditingController _consumptionController;
  TextEditingController _valueController;
  ConsumptionMeasurementUnits unit = ConsumptionMeasurementUnits.meter;
  DateTime _readingDate;

  FocusNode _residenceFocusNode;
  FocusNode _consumptionFocusNode;
  FocusNode _valueFocusNode;
  FocusNode _dateFocusNode;

  AddConsumptionValidators _validators;

  AddConsumptionPageBloc _bloc;

  @override
  void initState() {
    final userId = BlocProvider.of<AppBloc>(context).state.user.id;
    _bloc = AddConsumptionPageBloc(userId, AddConsumptionPageBlocState());
    _residenceController = TextEditingController();
    _consumptionController = TextEditingController();
    _valueController = TextEditingController();
    _residenceFocusNode = FocusNode();
    _consumptionFocusNode = FocusNode();
    _valueFocusNode = FocusNode();
    _dateFocusNode = FocusNode();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _validators = AddConsumptionValidators(AppLocalizations.of(context));
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _validators = null;
    _residenceController.dispose();
    _consumptionController.dispose();
    _valueController.dispose();
    _residenceFocusNode.dispose();
    _consumptionFocusNode.dispose();
    _valueFocusNode.dispose();
    _dateFocusNode.dispose();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizable = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(localizable.new_consumption),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<AddConsumptionPageBloc, AddConsumptionPageBlocState>(
            bloc: _bloc,
            listenWhen: (oldState, newState) =>
                oldState.createStatus != newState.createStatus,
            listener: _onCreateStatusChangeListener,
          ),
          BlocListener<AddConsumptionPageBloc, AddConsumptionPageBlocState>(
            bloc: _bloc,
            listenWhen: (oldState, newState) =>
                oldState.modeVerifyStatus != newState.modeVerifyStatus &&
                newState.modeVerifyStatus !=
                    AddConsumptionModeVerifyStatus.verifying,
            listener: _onModeChangeListener,
          ),
        ],
        child: _buildBody(context, localizable),
      ),
    );
  }

  Widget _buildBody(BuildContext context, AppLocalizations localizable) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              children: [
                BlocProvider.value(
                  value: _bloc,
                  child: CanteiroDateTimeFormField(
                    initialDate: _readingDate,
                    validator: _validators.onValidateDateTime,
                    onDateSelected: (date) => _readingDate = date,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  focusNode: _residenceFocusNode,
                  controller: _residenceController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: localizable.residence,
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: _validators.onValidateResidence,
                  onFieldSubmitted: (value) => FocusScope.of(context)
                      .requestFocus(_consumptionFocusNode),
                ),
                const SizedBox(
                  height: 20,
                ),
                _buildConsumptionWidget(),
                const SizedBox(
                  height: 20,
                ),
                CurrencyTextFormField(
                  focusNode: _valueFocusNode,
                  controller: _valueController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: localizable.consumption_value,
                    hintText: NumberFormat.simpleCurrency().format(0),
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: _validators.onValidateValue,
                ),
              ],
            ),
          ),
        ),
        Divider(),
        Padding(
          padding: EdgeInsets.all(20),
          child:
              BlocBuilder<AddConsumptionPageBloc, AddConsumptionPageBlocState>(
            bloc: _bloc,
            buildWhen: (oldState, newState) =>
                oldState.createStatus != newState.createStatus ||
                oldState.mode != newState.mode,
            builder: (context, state) {
              return LoadActionButton(
                isLoading: state.createStatus == LoadStatus.executing,
                child: Text(state.mode == AddConsumptionMode.create
                    ? localizable.add_consumption
                    : localizable.update_consumption),
                onPressed: _onAddConsumptionButtonPressed,
              );
            },
          ),
        )
      ],
    );
  }

  Widget _buildConsumptionWidget() {
    return ConsumptionValueWidget(
      consumptionFocusNode: _consumptionFocusNode,
      consumptionController: _consumptionController,
      consumptionValueValidator: _validators.onValidateConsumption,
      unit: this.unit,
      onMeasureValueChanged: (newValue) {
        setState(() {
          this.unit = newValue;
        });
      },
    );
  }

  void _onCreateStatusChangeListener(
      context, AddConsumptionPageBlocState state) {
    switch (state.createStatus) {
      case LoadStatus.none:
        break;
      case LoadStatus.executing:
        break;
      case LoadStatus.success:
        BlocProvider.of<DashboardPageBloc>(context)
            .add(BlocEvent(DashboardPageBlocEvent.loadConsumption));
        showDialog(
            context: context,
            builder: (context) {
              final localizable = AppLocalizations.of(context);
              return OkDialog(
                  title: localizable.new_consumption,
                  message: localizable.success_to_add_consumption,
                  onOKPressed: () {
                    Navigator.of(context).popUntil(
                        (route) => route.settings.name == AppRouter.home);
                  });
            });
        break;
      case LoadStatus.failed:
        showDialog(
            context: context,
            builder: (context) {
              final localizable = AppLocalizations.of(context);
              return OkDialog(
                  title: localizable.new_consumption,
                  message: localizable.failed_to_add_consumption,
                  onOKPressed: () {
                    Navigator.of(context).pop();
                  });
            });
        break;
      default:
        LoadStatusErrorGenericFeedbackHelper.showSnackbarForLoadStatus(
          context: context,
          loadStatus: state.createStatus,
        );
        break;
    }
  }

  void _onModeChangeListener(context, AddConsumptionPageBlocState state) {
    if (state.mode == AddConsumptionMode.update && _readingDate != null) {
      showDialog(
          context: context,
          builder: (context) {
            final localizable = AppLocalizations.of(context);
            final monthYear = DateFormat.yMMM().format(_readingDate);
            return OkDialog(
                title: localizable.new_consumption,
                message:
                    localizable.you_already_have_consumption_for(monthYear),
                onOKPressed: () {
                  _loadDataOfLastAddedConsumption(state.lastAddedConsumption);
                  Navigator.of(context).pop();
                });
          });
    }
  }

  void _loadDataOfLastAddedConsumption(SingleConsumption consumption) {
    print(consumption);
    if (consumption != null) {
      _residenceController.text = consumption.residence;
      _consumptionController.text =
          NumberFormat.decimalPattern().format(consumption.reading);
      _valueController.text =
          NumberFormat.simpleCurrency(locale: 'pt-BR').format(consumption.tax);
      setState(() {
        unit = consumption.unity;
      });
    }
  }

  void _onAddConsumptionButtonPressed() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      final residence = _residenceController.text;
      final consumption = NumberFormat.decimalPattern('pt-BR')
          .parse(_consumptionController.text);
      final unit = this.unit;
      final value = NumberFormat.simpleCurrency(locale: 'pt-BR')
          .parse(_valueController.text);
      final readingDate = this._readingDate;

      final userId = BlocProvider.of<AppBloc>(context).state.user.id;
      _bloc.fireCreateConsumptionEvent(
        userId: userId,
        residence: residence,
        consumption: consumption,
        unit: unit,
        value: value,
        consumptionDate: readingDate,
      );
    }
  }
}
