import 'package:bloc/bloc.dart';
import 'package:canteiro/blocs/bloc_event.dart';
import 'package:canteiro/blocs/load_status.dart';
import 'package:canteiro/resources/login_api_provider.dart';

class RecoverPasswordPageBloc extends Bloc<
    BlocEvent<RecoverPasswordPageBlocEvent>, RecoverPasswordPageBlocState> {
  RecoverPasswordPageBloc(RecoverPasswordPageBlocState initialState)
      : super(initialState);

  final LoginApiProvider _loginApiProvider = const LoginApiProvider();

  @override
  Stream<RecoverPasswordPageBlocState> mapEventToState(
      BlocEvent<RecoverPasswordPageBlocEvent> event) async* {
    switch (event.event) {
      case RecoverPasswordPageBlocEvent.recoveryForEmail:
        final newState = RecoverPasswordPageBlocState.fromState(state);
        if (event.data is String) {
          newState.recoveryEmail = event.data;
          newState.requestCodeStatus = LoadStatus.executing;
          yield newState;
          yield await _requestCode();
        }
        break;
      case RecoverPasswordPageBlocEvent.resendCode:
        final newState = RecoverPasswordPageBlocState.fromState(state);
        newState.requestCodeStatus = LoadStatus.executing;
        yield newState;
        yield await _requestCode(goToNextStep: false);
        break;
      case RecoverPasswordPageBlocEvent.verifyCode:
        final newState = RecoverPasswordPageBlocState.fromState(state);
        if (event.data is String) {
          newState.code = event.data;
          newState.verifyCodeStatus = LoadStatus.executing;
          yield newState;
          yield await _verifyCode();
        }
        break;
      case RecoverPasswordPageBlocEvent.resetPassword:
        final newState = RecoverPasswordPageBlocState.fromState(state);
        if (event.data is String) {
          newState.resetPasswordStatus = LoadStatus.executing;
          yield newState;
          yield await _resetPassword(event.data);
        }
        break;
      case RecoverPasswordPageBlocEvent.backStep:
        final newState = RecoverPasswordPageBlocState.fromState(state);
        newState._goToPreviousStep();
        yield newState;
        break;
    }
  }

  Future<RecoverPasswordPageBlocState> _requestCode(
      {bool goToNextStep = true}) async {
    final newState = RecoverPasswordPageBlocState.fromState(state);
    try {
      final response =
          await _loginApiProvider.sendVerificationCode(newState.recoveryEmail);
      newState.requestCodeStatus =
          LoadStatusExtension.loadStatusForRequestResponse(response);
      if (response.success) {
        if (goToNextStep) {
          newState._goToNextStep();
        }
      }
    } catch (error) {
      newState.requestCodeStatus =
          LoadStatusExtension.loadStatusForException(error);
    }
    return newState;
  }

  Future<RecoverPasswordPageBlocState> _verifyCode() async {
    final newState = RecoverPasswordPageBlocState.fromState(state);
    try {
      final response = await _loginApiProvider.validateCode(
          email: newState.recoveryEmail, code: newState.code);
      if (response.success) {
        newState._goToNextStep();
      }
      newState.verifyCodeStatus = LoadStatusExtension.loadStatusForRequestResponse(response);
    } catch (error) {
      newState.verifyCodeStatus = LoadStatusExtension.loadStatusForException(error);
    }
    return newState;
  }

  Future<RecoverPasswordPageBlocState> _resetPassword(
      String newPassword) async {
    final newState = RecoverPasswordPageBlocState.fromState(state);
    try {
      final response = await _loginApiProvider.resetPassword(
        code: newState.code,
        email: newState.recoveryEmail,
        password: newPassword,
      );
      newState.resetPasswordStatus =
          LoadStatusExtension.loadStatusForRequestResponse(response);
    } catch (error) {
      newState.resetPasswordStatus =
          LoadStatusExtension.loadStatusForException(error);
    }
    return newState;
  }
}

enum RecoverPasswordPageBlocEvent {
  recoveryForEmail,
  resendCode,
  verifyCode,
  resetPassword,
  backStep,
}

class RecoverPasswordPageBlocState {
  RecoverPasswordPageBlocState();
  RecoverPasswordPageBlocState.fromState(RecoverPasswordPageBlocState state) {
    recoveryEmail = state.recoveryEmail;
    code = state.code;
    requestCodeStatus = state.requestCodeStatus;
    verifyCodeStatus = state.verifyCodeStatus;
    resetPasswordStatus = state.resetPasswordStatus;
    currentStep = state.currentStep;
  }

  String recoveryEmail;
  String code;
  LoadStatus requestCodeStatus = LoadStatus.none;
  LoadStatus verifyCodeStatus = LoadStatus.none;
  LoadStatus resetPasswordStatus = LoadStatus.none;

  final int lastStep = 2;
  int currentStep = 0;

  void _goToNextStep() {
    if (lastStep > currentStep) {
      currentStep++;
    }
  }

  void _goToPreviousStep() {
    if (0 < currentStep) {
      currentStep--;
    }
  }
}