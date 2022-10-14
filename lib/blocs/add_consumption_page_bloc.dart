import 'package:bloc/bloc.dart';
import 'package:canteiro/blocs/bloc_event.dart';
import 'package:canteiro/models/consumption_measurement_units.dart';
import 'package:canteiro/models/single_consumption.dart';
import 'package:canteiro/resources/consumption_api_provider.dart';
import 'package:canteiro/resources/repository.dart';
import 'package:flutter/cupertino.dart';

import 'load_status.dart';

class AddConsumptionPageBloc extends Bloc<
    BlocEvent<AddConsumptionPageBlocEvent>, AddConsumptionPageBlocState> {
  AddConsumptionPageBloc(this.userId,AddConsumptionPageBlocState initialState)
      : super(initialState);

  final _consumptionProvider = ConsumptionApiProvider();
  final int userId;

  @override
  Stream<AddConsumptionPageBlocState> mapEventToState(
      BlocEvent<AddConsumptionPageBlocEvent> event) async* {
    switch (event.event) {
      case AddConsumptionPageBlocEvent._createConsumption:
        final newState = AddConsumptionPageBlocState.fromState(state);
        newState.createStatus = LoadStatus.executing;
        yield newState;
        if (event.data is Map<String, dynamic>) {
          if(state.mode == AddConsumptionMode.create) {
            yield await _createConsumption(event.data);
          }
          else {
            yield await _updateConsumption(event.data);
          }
        } else {
          final newState = AddConsumptionPageBlocState.fromState(state);
          newState.createStatus = LoadStatus.failed;
          yield newState;
        }
        break;
      case AddConsumptionPageBlocEvent.updateModeForDate:
        final newState = AddConsumptionPageBlocState.fromState(state);
        newState.modeVerifyStatus = AddConsumptionModeVerifyStatus.verifying;
        yield newState;
        if(event.data is DateTime) {
          yield await _updateModeForDate(event.data);
        }
        else {
          final newState = AddConsumptionPageBlocState.fromState(state);
          newState.modeVerifyStatus = AddConsumptionModeVerifyStatus.none;
          yield newState;
        }
        break;
    }
  }

  void fireCreateConsumptionEvent({
    @required int userId,
    @required String residence,
    @required double consumption,
    @required ConsumptionMeasurementUnits unit,
    @required double value,
    @required DateTime consumptionDate,
  }) {
    add(BlocEvent(AddConsumptionPageBlocEvent._createConsumption, data: {
      'userId' : userId,
      'residence': residence,
      'consumption': consumption,
      'unit': unit,
      'value': value,
      'consumptionDate': consumptionDate,
    }));
  }

  Future<AddConsumptionPageBlocState> _createConsumption(
      Map<String, dynamic> map) async {
    final newState = AddConsumptionPageBlocState.fromState(state);
    try {
      final RequestResponse<String> response =
          await _consumptionProvider.createConsumption(
        userId: map['userId'],
        residence: map['residence'],
        reading: map['consumption'],
        unity: map['unit'],
        tax: map['value'],
        consumptionDate: map['consumptionDate'],
      );
      newState.createStatus = LoadStatusExtension.loadStatusForRequestResponse(response);
    } catch (error) {
      print('AddConsumptionPageBloc._createConsumption:$error');
      newState.createStatus = LoadStatusExtension.loadStatusForException(error);
    }
    return newState;
  }

  Future<AddConsumptionPageBlocState> _updateConsumption(
      Map<String, dynamic> map) async {
    final newState = AddConsumptionPageBlocState.fromState(state);
    try {
      final RequestResponse<String> response =
      await _consumptionProvider.updateConsumption(
        consumptionId: state.lastAddedConsumption.id,
        residence: map['residence'],
        reading: map['consumption'],
        unity: map['unit'],
        tax: map['value'],
        consumptionDate: map['consumptionDate'],
      );
      newState.createStatus = LoadStatusExtension.loadStatusForRequestResponse(response);
    } catch (error) {
      print('AddConsumptionPageBloc._updateConsumption:$error');
      newState.createStatus = LoadStatusExtension.loadStatusForException(error);
    }
    return newState;
  }

  Future<AddConsumptionPageBlocState> _updateModeForDate(DateTime date) async {
    final newState = AddConsumptionPageBlocState.fromState(state);
    try {
      final RequestResponse<SingleConsumption> response =
      await _consumptionProvider.getSingleConsumptionOfPeriod(userId: userId,date: date);
      if(response.body != null) {
        SingleConsumption consumption = response.body;
        newState.mode = consumption != null ? AddConsumptionMode.update : AddConsumptionMode.create;
        newState.lastAddedConsumption = consumption;
      }
      else {
        newState.mode = AddConsumptionMode.create;
      }
    } catch (e) {
      print('AddConsumptionPageBloc._updateModeForDate: $e');
    }
    newState.modeVerifyStatus = AddConsumptionModeVerifyStatus.verifyComplete;
    return newState;
  }
}

enum AddConsumptionPageBlocEvent { _createConsumption, updateModeForDate }

class AddConsumptionPageBlocState {
  AddConsumptionPageBlocState();

  AddConsumptionPageBlocState.fromState(AddConsumptionPageBlocState state) {
    this.createStatus = state.createStatus;
    this.mode = state.mode;
    this.modeVerifyStatus = state.modeVerifyStatus;
    this.lastAddedConsumption = state.lastAddedConsumption;
  }

  AddConsumptionMode mode = AddConsumptionMode.create;
  SingleConsumption lastAddedConsumption;
  LoadStatus createStatus = LoadStatus.none;
  AddConsumptionModeVerifyStatus modeVerifyStatus = AddConsumptionModeVerifyStatus.none;
}

enum AddConsumptionModeVerifyStatus { none, verifying, verifyComplete }
enum AddConsumptionMode {
  create,
  update
}