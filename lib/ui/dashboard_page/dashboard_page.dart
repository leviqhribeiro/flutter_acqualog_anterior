import 'package:canteiro/blocs/bloc_event.dart';
import 'package:canteiro/blocs/dashboard_page_bloc.dart';
import 'package:canteiro/blocs/load_status.dart';
import 'package:canteiro/helpers/load_status_error_generic_feedback_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:canteiro/ui/dashboard_page/chart_selection_tooltip_widget.dart';
import 'package:canteiro/ui/dashboard_page/consumption_chart_widget.dart';
import 'package:canteiro/ui/dashboard_page/dashboard_info_widget.dart';
import 'package:canteiro/ui/widgets/load_info_widget.dart';
import 'package:canteiro/ui/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final localizable = AppLocalizations.of(context);
    return BlocConsumer<DashboardPageBloc, DashboardPageBlocState>(
      listenWhen: (oldState, newState) =>
          oldState.loadStatus != newState.loadStatus,
      buildWhen: (oldState, newState) =>
          oldState.loadStatus != newState.loadStatus,
      listener: _onLoadStatusChangeListener,
      builder: (context, state) {
        switch (state.loadStatus) {
          case LoadStatus.executing:
            return LoadingWidget(
              title: localizable.loading_data,
            );
          case LoadStatus.failed:
            return LoadInfoWidget(
              child: Icon(
                Icons.bar_chart,
                color: Colors.grey,
                size: 80,
              ),
              title: localizable.my_consumption,
              message: localizable.could_not_load_data,
              reloadButtonTitle: localizable.try_again,
              reloadAction: () {
                BlocProvider.of<DashboardPageBloc>(context)
                    .add(BlocEvent(DashboardPageBlocEvent.loadConsumption));
              },
            );
          default:
            break;
        }
        if (state.consumption == null) {
          return SizedBox.shrink();
        }
        return ListView(
          padding: EdgeInsets.symmetric(vertical: 20),
          children: [
            SizedBox(
              height: 40,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                localizable.my_consumption_formatted,
                style: Theme.of(context).textTheme.headline4.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  AspectRatio(
                    aspectRatio: 1.25,
                    child: ConsumptionChartWidget(
                      data: state.consumption,
                    ),
                  ),
                  Positioned(
                    right: 50,
                    top: 10,
                    child: ChartSelectionTooltipWidget(),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            DashboardInfoWidget(
              average: state.consumption.average,
              min: state.consumption.min,
              max: state.consumption.max,
            )
          ],
        );
      },
    );
  }

  void _onLoadStatusChangeListener(
      BuildContext context, DashboardPageBlocState state) {
    if (state.loadStatus.hasError) {
      LoadStatusErrorGenericFeedbackHelper.showSnackbarForLoadStatus(
        context: context,
        loadStatus: state.loadStatus,
      );
    }
  }
}
