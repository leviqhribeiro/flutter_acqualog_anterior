import 'package:bloc/bloc.dart';
import 'package:canteiro/blocs/bloc_event.dart';
import 'package:canteiro/blocs/load_status.dart';
import 'package:canteiro/models/user.dart';
import 'package:canteiro/resources/login_api_provider.dart';
import 'package:flutter/cupertino.dart';

class LoginPageBloc extends Bloc<BlocEvent<LoginPageBlocEvent>, LoginPageBlocState>{
  LoginPageBloc(LoginPageBlocState initialState) : super(initialState);

  final _loginApiProvider = LoginApiProvider();

  @override
  Stream<LoginPageBlocState> mapEventToState(BlocEvent<LoginPageBlocEvent> event) async* {
    switch(event.event) {

      case LoginPageBlocEvent.performSignIn:
        final newState = LoginPageBlocState.fromState(state);
        newState.loginStatus = LoadStatus.executing;
        yield newState;
        yield await _performSignIn(
          email: event.data['email'],
          password: event.data['password'],
        );
        break;
      case LoginPageBlocEvent.toggleObscurePassword:
        final newState = LoginPageBlocState.fromState(state);
        newState.obscurePassword = !newState.obscurePassword;
        yield newState;
        break;
    }
  }

  Future<LoginPageBlocState> _performSignIn({@required String email, @required String password}) async {
    final newState = LoginPageBlocState.fromState(state);
    try {
      final result = await _loginApiProvider.login(email, password);
      newState.loginStatus = LoadStatusExtension.loadStatusForRequestResponse(result);
      newState.user = result.body;
    }
    catch(error) {
      print('LoginPageBloc.performSignIn:$error');
      newState.loginStatus = LoadStatusExtension.loadStatusForException(error);
    }
    return newState;
  }



}

enum LoginPageBlocEvent {
  performSignIn,
  toggleObscurePassword
}

class LoginPageBlocState {
  LoginPageBlocState();
  LoginPageBlocState.fromState(LoginPageBlocState state) {
    obscurePassword = state.obscurePassword;
    loginStatus = state.loginStatus;
    user = state.user;
  }
  bool obscurePassword = true;
  LoadStatus loginStatus = LoadStatus.none;
  User user;
}

