import 'package:canteiro/blocs/bloc_event.dart';
import 'package:canteiro/blocs/dashboard_page_bloc.dart';
import 'package:canteiro/blocs/push_notifications_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:canteiro/router.dart';
import 'package:canteiro/ui/dashboard_page/dashboard_page.dart';
import 'package:canteiro/ui/profile_page.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'dialogs/fix_permission_dialog.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final scaffoldKey = new GlobalKey<ScaffoldState>();

  ValueNotifier<int> _currentPageIndex = ValueNotifier(0);

  @override
  void initState() {
    BlocProvider.of<PushNotificationsBloc>(context)
        .add(BlocEvent(PushNotificationsBlocEvent.registerForNotifications));
    super.initState();
  }

  @override
  void dispose() {
    _currentPageIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizable = AppLocalizations.of(context);
    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          BlocListener<PushNotificationsBloc, PushNotificationsBlocState>(
            listenWhen: (oldState, newState) =>
            oldState.showFixNotifPermissionAlert !=
                newState.showFixNotifPermissionAlert,
            listener: (context, state) {
              if (state.showFixNotifPermissionAlert == true) {
                _showFixNotifPermissionAlert();
              }
            },
          ),
        ],
        child: ValueListenableBuilder(
          valueListenable: _currentPageIndex,
          builder: (context, value, child) {
            return IndexedStack(
              index: value,
              children: [
                DashboardPage(),
                ProfilePage()
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add
        ),
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: (){
          Navigator.of(context).pushNamed(AppRouter.newConsumption,arguments: BlocProvider.of<DashboardPageBloc>(context));
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: ValueListenableBuilder(
        valueListenable: _currentPageIndex,
        builder: (context, value, child) {
          return BottomNavigationBar(
            currentIndex: value,
            items: [
              BottomNavigationBarItem(
                  icon: Icon(
                    Icons.bar_chart,
                  ),
                  label: localizable.dashboard),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person), label: localizable.profile)
            ],
            onTap: (index) => _currentPageIndex.value = index,
          );
        },
      ),
    );
  }

  void _showFixNotifPermissionAlert() {
    final localizable = AppLocalizations.of(context);
    showDialog(
        context: context,
        builder: (context) {
          return FixPermissionDialog(
            title: localizable.permission_needed,
            message: localizable.notification_permissions_needed_message,
          );
        });
  }

}
