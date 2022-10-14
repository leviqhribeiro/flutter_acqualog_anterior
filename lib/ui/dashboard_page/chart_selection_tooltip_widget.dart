import 'package:canteiro/blocs/dashboard_page_bloc.dart';
import 'package:canteiro/helpers/format_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ChartSelectionTooltipWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardPageBloc,DashboardPageBlocState>(
      buildWhen: (oldState, newState) => oldState.selectionContent != newState.selectionContent,
        builder: (context, state) {
        final show = state.selectionContent != null;
          return AnimatedSwitcher(
            duration: Duration(milliseconds: 200),
            child: show ? _buildTooltipContentWidget(context, state.selectionContent) : SizedBox.shrink(),
          );
        },
    );
  }

  Widget _buildTooltipContentWidget(BuildContext context,ChartSelectedTooltipContent content){
    final textStyle = TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w600,
      color: Colors.white
    );
    return Container(
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
          color: Colors.black87,//Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 3,
              offset: Offset(0.5,1),
            )
          ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            content.month,
            style: textStyle,
          ),
          SizedBox(
            height: 5,
          ),
          Row(
            children: [
              Container(
                  width: 10,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(2)
                  )
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                _formatForM3(content.contingency),
                style: textStyle,
              ),
            ],
          ),
          Row(
            children: [
              Container(
                  width: 10,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.lightGreen,
                      borderRadius: BorderRadius.circular(2)
                  )
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                _formatCurrency(content.value),
                style: textStyle,
              ),
            ],
          ),
          Row(
            children: [
              Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(2)
                  )
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                _formatForM3(content.consumption),
                style: textStyle,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatForM3(double value) {
    final formatter = NumberFormat.decimalPattern();
    return formatter.format(value ?? 0)+'m³';
  }

  String _formatCurrency(double value) {
    return FormatHelper.currencyFormat(value);
  }
}
