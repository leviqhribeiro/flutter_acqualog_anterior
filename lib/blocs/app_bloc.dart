import 'package:bloc/bloc.dart';
import 'package:canteiro/blocs/bloc_event.dart';
import 'package:canteiro/blocs/load_status.dart';
import 'package:canteiro/helpers/jwt_helper.dart';
import 'package:canteiro/helpers/secure_storage_helper.dart';
import 'package:canteiro/models/user.dart';
import 'package:canteiro/resources/repository.dart';
import 'package:canteiro/resources/user_api_provider.dart';

class AppBloc extends Bloc<BlocEvent<AppBlocEvent>, AppBlocState> {
  AppBloc(initialState) : super(initialState) {
    add(BlocEvent(AppBlocEvent.tryToRefreshSignIn));
  }

  final _repository = const Repository();
  final _userApiProvider = const UserApiProvider();

  @override
  Stream<AppBlocState> mapEventToState(BlocEvent<AppBlocEvent> event) async* {
    switch (event.event) {
      case AppBlocEvent.tryToRefreshSignIn:
        final newState = AppBlocState.fromState(state);
        newState.refreshStatus = LoadStatus.executing;
        yield newState;
        yield await _tryToSilentlyLogin();
        break;
      case AppBlocEvent.performSignOut:
        yield performSignOut();
        break;
      case AppBlocEvent.setNewSignedInUser:
        final newState = AppBlocState.fromState(state);
        newState.user = event.data;
        yield newState;
        break;
      case AppBlocEvent.reloadUserData:
        yield await _reloadUserData();
        break;
    }
  }

  AppBlocState performSignOut() {
    final storageHelper = SecureStorageHelper();
    storageHelper.clearJWT();
    return AppBlocState.signOut();
  }

  Future<AppBlocState> _tryToSilentlyLogin() async {
    var newState = AppBlocState.fromState(state);
    final storageHelper = SecureStorageHelper();
    final jwt = await storageHelper.getJWT();
    if (jwt != null) {
      try {
        var response;
        if(JwtHelper.jwtIsExpired(jwt)) {
          response = await _repository.refresh();//always try to renew
        }

        if (response == null || response.success) {
          final userResp = await _userApiProvider.getAccount();
          newState.user = userResp.body;
          newState.refreshStatus = LoadStatusExtension.loadStatusForRequestResponse(userResp);
          _printUserInformations();
        } else {
          newState.refreshStatus = LoadStatusExtension.loadStatusForRequestResponse(response);
        }

      }
      catch(error) {
        newState.refreshStatus = LoadStatusExtension.loadStatusForException(error);
      }
    } else {
      newState.refreshStatus = LoadStatus.failed;
    }
    return newState;
  }

  Future<AppBlocState> _reloadUserData() async {
    final newState = AppBlocState.fromState(state);
    try {
      final userResp = await _userApiProvider.getAccount();
      newState.user = userResp.body;
    }
    catch(e) {}
    return newState;
  }

  void _printUserInformations() async {
    final storageHelper = SecureStorageHelper();
    print('===');
    if (state.user != null) {
      print('user id: ${state.user.id}');
    }
    final newJwt = await storageHelper.getJWT();
    print('JWT: $newJwt');
    print('===');
  }

//  Future<List<Task>> getTaskFilteredBy({int id,@required String start_date,@required String end_date, String priority, String status}) async {
//    var result = await _repository.taskFilteredBy(id, start_date, end_date, priority, status);
//    return result.tasks;
//  }
}

class AppBlocState {
  AppBlocState();
  AppBlocState.fromState(AppBlocState state) {
    this.user = user;
    this.refreshStatus = state.refreshStatus;
  }

  AppBlocState.signOut() {
    this.user = null;
    this.refreshStatus = LoadStatus.none;
  }

  User user;
  LoadStatus refreshStatus = LoadStatus.none;
}

enum AppBlocEvent {
  tryToRefreshSignIn,
  performSignOut,
  setNewSignedInUser,
  reloadUserData,
}
