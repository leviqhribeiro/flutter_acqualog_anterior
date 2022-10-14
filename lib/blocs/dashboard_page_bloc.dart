import 'package:bloc/bloc.dart';
import 'package:canteiro/blocs/bloc_event.dart';
import 'package:canteiro/models/consumption.dart';
import 'package:canteiro/resources/consumption_api_provider.dart';
import 'package:canteiro/resources/repository.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import 'load_status.dart';

class DashboardPageBloc
    extends Bloc<BlocEvent<DashboardPageBlocEvent>, DashboardPageBlocState> {
  DashboardPageBloc(DashboardPageBlocState initialState,
      {@required this.userId})
      : super(initialState) {
    add(BlocEvent(DashboardPageBlocEvent.loadConsumption));
  }

  final _dashboardProvider = const ConsumptionApiProvider();
  final int userId;

  @override
  Stream<DashboardPageBlocState> mapEventToState(
      BlocEvent<DashboardPageBlocEvent> event) async* {
    switch (event.event) {
      case DashboardPageBlocEvent.loadConsumption:
        final newState = DashboardPageBlocState.fromState(state);
        newState.loadStatus = LoadStatus.executing;
        yield newState;
        yield await _loadConsumption();
        break;
      case DashboardPageBlocEvent.reloadConsumption:
        break;
      case DashboardPageBlocEvent.setSelectionContent:
        final newState = DashboardPageBlocState.fromState(state);
        newState.selectionContent = event.data;
        yield newState;
        break;
    }
  }

  Future<DashboardPageBlocState> _loadConsumption() async {
    final newState = DashboardPageBlocState.fromState(state);
    try {
      final RequestResponse<Consumption> response =
          await _dashboardProvider.getConsumption(userId: userId);
      if (response.body?.data != null) {
        newState.consumption =
            await compute(_createOrdinalComboChartSampleData, response.body);
      }
      newState.loadStatus =
          LoadStatusExtension.loadStatusForRequestResponse(response);
    } catch (error) {
      print('DashboardPageBloc._loadConsumption: $error');
      newState.loadStatus = LoadStatusExtension.loadStatusForException(error);
    }
    return newState;
  }
}

enum DashboardPageBlocEvent {
  loadConsumption,
  reloadConsumption,
  setSelectionContent
}

class DashboardPageBlocState {
  DashboardPageBlocState();
  DashboardPageBlocState.fromState(DashboardPageBlocState state) {
    this.loadStatus = state.loadStatus;
    this.consumption = state.consumption;
    this.selectionContent = state.selectionContent;
  }

  DashboardConsumptionData consumption;
  LoadStatus loadStatus = LoadStatus.none;
  ChartSelectedTooltipContent selectionContent;
}

class DashboardConsumptionData {
  DashboardConsumptionData({
    @required this.consumptionsData,
    @required this.taxesData,
    @required this.contingencyData,
    @required this.max,
    @required this.min,
    @required this.average,
  });
  List<ItemSeries> consumptionsData = [];
  List<ItemSeries> taxesData = [];
  List<ItemSeries> contingencyData = [];
  ConsumptionInfo max;
  ConsumptionInfo min;
  AverageInfo average;
}

class ConsumptionInfo {
  ConsumptionInfo({
    @required this.month,
    @required this.consumption,
    @required this.tax,
  });
  String month;
  double consumption;
  double tax;
}

class AverageInfo {
  AverageInfo(
      {@required this.consumption, @required this.tax, @required this.year});
  double consumption;
  double tax;
  String year;
}

DashboardConsumptionData _createOrdinalComboChartSampleData(
    Consumption consumption) {
  List<ItemSeries> consumptionsData = [];
  List<ItemSeries> taxesData = [];
  List<ItemSeries> contingencyData = [];

  int minIndex = 0;
  int maxIndex = 0;
  final consumptions = consumption.data.consumptions;
  double consumptionsSum = 0;
  double taxesSum = 0;
  for (int index = 0; index < consumption.data.months.length; index++) {
    final month = consumption.data.months[index];
    final double consum = consumptions[index];
    final double tax = consumption.data.outlays[index];
    final contingency = consumption.data.contigengy[index];

    consumptionsData.add(ItemSeries(month, consum));
    taxesData.add(ItemSeries(month, tax));
    contingencyData.add(ItemSeries(month, contingency));

    if (consumptions[minIndex] > consumptions[index]) {
      minIndex = index;
    }
    if (consumptions[maxIndex] < consumptions[index]) {
      maxIndex = index;
    }

    consumptionsSum += consum;
    taxesSum += tax;
  }

  return DashboardConsumptionData(
      consumptionsData: consumptionsData,
      contingencyData: contingencyData,
      taxesData: taxesData,
      min: ConsumptionInfo(
          consumption: consumptions[minIndex],
          tax: consumption.data.outlays[minIndex],
          month: consumption.data.months[minIndex]),
      max: ConsumptionInfo(
          consumption: consumptions[maxIndex],
          tax: consumption.data.outlays[maxIndex],
          month: consumption.data.months[maxIndex]),
      average: AverageInfo(
        consumption: consumptionsSum / consumptions.length,
        tax: taxesSum / consumption.data.outlays.length,
        year: DateFormat.y().format(DateTime.now()),
      ));
}

class ItemSeries {
  ItemSeries(this.xValue, this.yValue);
  final String xValue;
  final double yValue;
}

class ChartSelectedTooltipContent {
  ChartSelectedTooltipContent({
    this.month,
    this.consumption,
    this.contingency,
    this.value,
  });
  String month;
  double consumption;
  double contingency;
  double value;
}
