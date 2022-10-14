import 'package:canteiro/blocs/app_bloc.dart';
import 'package:canteiro/blocs/dashboard_page_bloc.dart';
import 'package:canteiro/ui/add_consumption_page/add_consumption_page.dart';
import 'package:canteiro/ui/home_page.dart';
import 'package:canteiro/ui/recover_password_page/recover_password_page.dart';
import 'package:canteiro/ui/sign_up_editprofile/editprofile_page.dart';
import 'package:canteiro/ui/sign_up_editprofile/sign_up_page.dart';
import 'package:flutter/material.dart';
import 'package:canteiro/ui/login/login_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class Router {
  Route<dynamic> generateRoute(RouteSettings settings);
}

class AppRouter extends Router {
  static const login = "/login";
  static const recoverPassword = "/recoverPassword";
  static const signUp = "/signUp";
  static const editProfile = "/editProfile";
  static const home = "/homePage";
  static const newConsumption = "/newConsumption";

  @override
  Route generateRoute(RouteSettings settings) {
    WidgetBuilder builder;
    bool modal = false;
    switch (settings.name) {
      case login:
        builder = (BuildContext _) => LoginPage();
        break;
      case signUp:
        builder = (BuildContext _) => SignUpPage();
        modal = true;
        break;
      case editProfile:
        builder = (BuildContext _) => EditProfilePage();
        modal = true;
        break;
      case home:
        builder = (BuildContext _) => BlocProvider(
              create: (context) => DashboardPageBloc(DashboardPageBlocState(),userId: BlocProvider.of<AppBloc>(context).state.user.id),
              child: HomePage(),
            );
        break;
      case recoverPassword:
        builder = (BuildContext _) => RecoverPasswordPage();
        modal = true;
        break;
      case newConsumption:
        builder = (BuildContext context) => BlocProvider.value(
              value: settings.arguments as DashboardPageBloc,
              child: AddConsumptionPage(),
            );
        break;
      default:
        throw Exception('Invalid route: ${settings.name}');
    }
    return MaterialPageRoute(builder: builder, settings: settings,fullscreenDialog: modal);
  }
}
