import 'package:canteiro/blocs/dashboard_page_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DashboardInfoWidget extends StatelessWidget {

  DashboardInfoWidget({
    @required this.max,
    @required this.min,
    @required this.average,
    Key key,
}):super(key: key);

  final ConsumptionInfo max;
  final ConsumptionInfo min;
  final AverageInfo average;

  @override
  Widget build(BuildContext context) {
    final localizable = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 10),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildLargeInfoItemWidget(
            context,
            title: localizable.maximum,
           comsumption: formatConsumption(max.consumption),
            price: formatTax(max.tax),
            time: max.month,
            color: Colors.redAccent,
            iconData: Icons.arrow_upward,
          ),
          const SizedBox(
            width: 10,
          ),
          _buildLargeInfoItemWidget(
            context,
            title: localizable.average,
            comsumption: formatConsumption(average.consumption),
            price: formatTax(average.tax),
            time: average.year,
            color: Colors.indigoAccent,
            iconData: Icons.show_chart,
          ),
          const SizedBox(
            width: 10,
          ),
          _buildLargeInfoItemWidget(
            context,
            title: localizable.minimum,
            comsumption: formatConsumption(min.consumption),
            price: formatTax(min.tax),
            time: min.month,
            color:  Theme.of(context).primaryColor,
            iconData: Icons.arrow_downward,
          ),
        ],
      ),
    );
  }

  Widget _buildLargeInfoItemWidget(BuildContext context,
      {@required String title,
        @required String comsumption,
        @required String price,
        String time,
        @required Color color,
        @required IconData iconData}) {

    final localizable = AppLocalizations.of(context);
    return Container(
      alignment: Alignment.center,
      decoration:
      BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.grey[200]),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                iconData,
                color: Colors.black38,
              ),
             SizedBox(
               width: 10,
             ),
             Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text(
                   title,
                   style: TextStyle(
                       fontSize: 15,
                       fontWeight: FontWeight.w600
                   ),
                 ),
                 Text(
                   time,
                   style: Theme.of(context).textTheme.caption,
                 )
               ],
             ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 10,),
                  Text(
                    localizable.consumption_abreviated_plus_unity,
                    style: Theme.of(context).textTheme.caption,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    comsumption,
                    style:TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600

                    ),
                  ),
                ],
              ),
              SizedBox(
                width: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 10,),
                  Text(
                    localizable.consumption_value+'(${NumberFormat.simpleCurrency().currencySymbol})',
                    style: Theme.of(context).textTheme.caption,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    price,
                    style:TextStyle(
                      fontSize: 15,
                        fontWeight: FontWeight.w600
                    ),
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }


  String formatConsumption(double value) {
    final formatter = NumberFormat.decimalPattern();
    return formatter.format(value);
  }

  String formatTax(double value) {
    final formatter = NumberFormat.simpleCurrency();
    return formatter.format(value).replaceAll(formatter.currencySymbol, '');
  }

}
