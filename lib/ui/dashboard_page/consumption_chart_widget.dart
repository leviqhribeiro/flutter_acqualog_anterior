import 'package:canteiro/blocs/bloc_event.dart';
import 'package:canteiro/blocs/dashboard_page_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

const secondaryMeasureAxisId = 'secondaryMeasureAxisId';

class ConsumptionChartWidget extends StatelessWidget {

  ConsumptionChartWidget({@required this.data, Key key}):super(key: key);

  final DashboardConsumptionData data;

  @override
  Widget build(BuildContext context) {
    return _buildBarLineChart(
      context,
    );
  }

  Widget _buildBarLineChart(BuildContext context) {
    final localizable = AppLocalizations.of(context);
    final chartData = [
      charts.Series<ItemSeries, String>(
        id: localizable.consumption,
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (ItemSeries sales, _) => sales.xValue,
        measureFn: (ItemSeries sales, _) => sales.yValue,
        data: data.consumptionsData,
      ),

      charts.Series<ItemSeries, String>(
        id: localizable.contingency,
        colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
        domainFn: (ItemSeries sales, _) => sales.xValue,
        measureFn: (ItemSeries sales, _) => sales.yValue,
        data: data.contingencyData,
      )..setAttribute(charts.rendererIdKey, 'pointLineRenderer'),
      //..setAttribute(charts.measureAxisIdKey, secondaryMeasureAxisId),

      charts.Series<ItemSeries, String>(
        id: localizable.consumption_value +
            '(${NumberFormat.simpleCurrency().currencySymbol})',
        colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
        domainFn: (ItemSeries sales, _) => sales.xValue,
        measureFn: (ItemSeries sales, _) => sales.yValue,
        data: data.taxesData,
      )
        ..setAttribute(charts.measureAxisIdKey, secondaryMeasureAxisId)
        ..setAttribute(charts.rendererIdKey, 'lineRenderer')
    ];

    return charts.OrdinalComboChart(
      chartData,
      animate: true,
      domainAxis: charts.OrdinalAxisSpec(
        renderSpec: charts.SmallTickRendererSpec(
          // Tick and Label styling here.
          labelStyle: charts.TextStyleSpec(
            fontSize: 8,
          ),
          labelRotation: 45,
        ),
      ),
      secondaryMeasureAxis: charts.NumericAxisSpec(
          tickFormatterSpec:
          charts.BasicNumericTickFormatterSpec.fromNumberFormat(
            NumberFormat.compactSimpleCurrency(),
          ),
          showAxisLine: false,
          renderSpec: charts.SmallTickRendererSpec(
              lineStyle: charts.LineStyleSpec(
                  color: charts.MaterialPalette.transparent))
        // renderSpec: new charts.SmallTickRendererSpec(
        //   // Tick and Label styling here.
        //   labelStyle: charts.TextStyleSpec(
        //     fontSize: 8,
        //   ),
        // ),
      ),
      primaryMeasureAxis: new charts.NumericAxisSpec(
          renderSpec: charts.GridlineRendererSpec(
            lineStyle: charts.LineStyleSpec(
              dashPattern: [4, 4],
            ),
          )),
      defaultRenderer: new charts.BarRendererConfig(
        groupingType: charts.BarGroupingType.grouped,
      ),
      customSeriesRenderers: [
        charts.LineRendererConfig(
          // ID used to link series to this renderer.
          customRendererId: 'lineRenderer',
          includePoints: false,
        ),
        charts.LineRendererConfig(
          // ID used to link series to this renderer.
          customRendererId: 'pointLineRenderer',
          includePoints: true,
        )
      ],
      selectionModels: [
        charts.SelectionModelConfig(
          type: charts.SelectionModelType.info,
          //changedListener: (model) => _onChartItemSelected(context, model),
          updatedListener:  (model) => _onChartItemSelected(context, model),
          //listener: _onCharItemSelected,
        ),
      ],
      behaviors: [
        charts.ChartTitle(
          '${localizable.consumption_chart} ${DateFormat.y().format(DateTime.now())}',
          behaviorPosition: charts.BehaviorPosition.top,
          titleOutsideJustification: charts.OutsideJustification.middleDrawArea,
          titleStyleSpec: charts.TextStyleSpec(fontSize: 12),
          innerPadding: 15,
        ),
        charts.SeriesLegend(
          position: charts.BehaviorPosition.bottom,
          entryTextStyle: charts.TextStyleSpec(
            fontSize: 11,
          ),
          desiredMaxColumns: 2,
        ),
        charts.DomainHighlighter(),
        charts.LinePointHighlighter(
          showHorizontalFollowLine:
          charts.LinePointHighlighterFollowLineType.none,
          showVerticalFollowLine:
          charts.LinePointHighlighterFollowLineType.nearest,
        ),
        charts.SelectNearest(
          eventTrigger: charts.SelectionTrigger.tapAndDrag,
        )
      ],
    );
  }

  void _onChartItemSelected(BuildContext context, charts.SelectionModel model) {
    final localizable = AppLocalizations.of(context);
    final selectedDatum = model.selectedDatum;
    if (selectedDatum.isNotEmpty) {
      final ItemSeries itemSeries = selectedDatum.first.datum;
      final selected = ChartSelectedTooltipContent(
        month: itemSeries.xValue,
      );
      selectedDatum.forEach((charts.SeriesDatum datumPair) {
        final ItemSeries item = datumPair.datum;
        final displayName = datumPair.series.displayName;
        if (displayName == localizable.consumption) {
          selected.consumption = item.yValue;
        } else if (displayName == localizable.contingency) {
          selected.contingency = item.yValue;
        } else {
          selected.value = item.yValue;
        }
      });
      BlocProvider.of<DashboardPageBloc>(context).add(BlocEvent(
          DashboardPageBlocEvent.setSelectionContent,
          data: selected));
    } else {
      BlocProvider.of<DashboardPageBloc>(context).add(
          BlocEvent(DashboardPageBlocEvent.setSelectionContent, data: null));
    }
  }
}
