import 'package:bloc/bloc.dart';
import 'package:canteiro/blocs/bloc_event.dart';
import 'package:canteiro/models/address.dart';
import 'package:canteiro/models/manager.dart';
import 'package:canteiro/resources/repository.dart';
import 'package:canteiro/resources/user_api_provider.dart';

import 'load_status.dart';

class SignUpEditProfileBloc extends Bloc<BlocEvent<SignUpEditProfileBlocEvent>,
    SignUpEditProfileBlocState> {
  SignUpEditProfileBloc(SignUpEditProfileBlocState initialState, {this.userId})
      : assert(
            (initialState.mode == SignUpEditProfileBlocMode.editProfile &&
                    userId != null) ||
                initialState.mode == SignUpEditProfileBlocMode.signUp,
            'When in EditProfile mode userId must not be null or empty'),
        super(initialState);

  final int userId;

  final _userApiProvider = const UserApiProvider();

  @override
  Stream<SignUpEditProfileBlocState> mapEventToState(
      BlocEvent<SignUpEditProfileBlocEvent> event) async* {
    switch (event.event) {
      case SignUpEditProfileBlocEvent.addName:
        if (event.data is String) {
          final newState = SignUpEditProfileBlocState.fromState(state);
          newState.name = event.data;
          newState._goToNextStep();
          yield newState;
        }
        break;
      case SignUpEditProfileBlocEvent.validateAndAddEmail:
        if (event.data is String) {
          final newState = SignUpEditProfileBlocState.fromState(state);
          newState.emailStatus = LoadStatus.executing;
          yield newState;
          yield await _verifyEmailAvailability(event.data);
        }
        break;
      case SignUpEditProfileBlocEvent.addPassword:
        if (event.data is String) {
          final newState = SignUpEditProfileBlocState.fromState(state);
          newState.password = event.data;
          newState._goToNextStep();
          yield newState;
        }
        break;
      case SignUpEditProfileBlocEvent.addAddress:
        if (event.data is Address) {
          final newState = SignUpEditProfileBlocState.fromState(state);
          newState.address = event.data;
          newState._goToNextStep();
          yield newState;
        }
        break;
      case SignUpEditProfileBlocEvent.addAddressByCEP:
        if (event.data is Address) {
          final newState = SignUpEditProfileBlocState.fromState(state);
          newState.address = event.data;
          yield newState;
        }
        break;
      case SignUpEditProfileBlocEvent.addManager:
        if (event.data is Manager) {
          final newState = SignUpEditProfileBlocState.fromState(state);
          newState.manager = event.data;
          newState._goToNextStep();
          yield newState;
        }
        break;
      case SignUpEditProfileBlocEvent.addResidentCount:
        if (event.data is int) {
          final newState = SignUpEditProfileBlocState.fromState(state);
          newState.residentsCount = event.data;
          newState._goToNextStep();
          yield newState;
        }
        break;
      case SignUpEditProfileBlocEvent.signUp:
        final newState = SignUpEditProfileBlocState.fromState(state);
        newState.loadStatus = LoadStatus.executing;
        yield newState;
        yield await _performSignUp();
        break;
      case SignUpEditProfileBlocEvent.editProfile:
        final newState = SignUpEditProfileBlocState.fromState(state);
        newState.loadStatus = LoadStatus.executing;
        yield newState;
        yield await _performEditProfile();
        break;
      case SignUpEditProfileBlocEvent.backStep:
        final newState = SignUpEditProfileBlocState.fromState(state);
        newState._goToPreviousStep();
        yield newState;
        break;
      case SignUpEditProfileBlocEvent.editStep:
        if (event.data != null && event.data is SignUpEditProfileStep) {
          final newState = SignUpEditProfileBlocState.fromState(state);
          newState._editStep(event.data);
          yield newState;
        }
        break;
    }
  }

  Future<SignUpEditProfileBlocState> _verifyEmailAvailability(
      String email) async {
    final newState = SignUpEditProfileBlocState.fromState(state);
    bool isAvailable = false;
    try {
      final RequestResponse<bool> response =
          await _userApiProvider.verifyEmailAvailability(email: email);
      isAvailable = response.body != null && response.body;
      newState.emailStatus = isAvailable
          ? response.statusCode == 400
              ? LoadStatus.success
              : LoadStatusExtension.loadStatusForRequestResponse(response)
          : LoadStatus.emailUnavailable;
    } catch (error) {
      print('SignUpPageBloc._verifyEmailAvailability:$error');
      newState.emailStatus = LoadStatusExtension.loadStatusForException(error);
    }

    if (isAvailable) {
      newState.email = email;
      newState._goToNextStep();
    }
    return newState;
  }

  Future<SignUpEditProfileBlocState> _performSignUp() async {
    final newState = SignUpEditProfileBlocState.fromState(state);
    try {
      final RequestResponse<Map<String, dynamic>> response =
          await _userApiProvider.signUpUser(
        name: state.name,
        email: state.email,
        password: state.password,
        managerId: state.manager.id,
        residentsCount: state.residentsCount,
        address: state.address,
      );
      newState.loadStatus = LoadStatusExtension.loadStatusForRequestResponse(
        response,
      );
    } catch (error) {
      newState.loadStatus = LoadStatusExtension.loadStatusForRequestResponse(
        error,
      );
    }
    return newState;
  }

  Future<SignUpEditProfileBlocState> _performEditProfile() async {
    final newState = SignUpEditProfileBlocState.fromState(state);
    try {
      final RequestResponse<Map<String, dynamic>> response =
          await _userApiProvider.editProfile(
        userId: userId,
        name: state.name,
        email: state.email,
        managerId: state.manager.id,
        residentsCount: state.residentsCount,
        address: state.address,
      );
      newState.loadStatus = LoadStatusExtension.loadStatusForRequestResponse(
        response,
      );
    } catch (error) {
      newState.loadStatus = LoadStatusExtension.loadStatusForException(
        error,
      );
    }
    return newState;
  }
}

enum SignUpEditProfileBlocEvent {
  addName,
  validateAndAddEmail,
  addPassword,
  addAddress,
  addAddressByCEP,
  addManager,
  addResidentCount,
  signUp,
  editProfile,
  backStep,
  editStep
}

class SignUpEditProfileBlocState {
  SignUpEditProfileBlocState(
    this.mode, {
    this.name,
    this.address,
    this.email,
    this.residentsCount = 0,
    this.manager,
  }) {
    emailStatus = LoadStatus.success;
    if (mode == SignUpEditProfileBlocMode.editProfile) {
      editMode = true;
      currentStep = lastStep - 1;
    }
  }

  SignUpEditProfileBlocState.fromState(SignUpEditProfileBlocState state) {
    this.mode = state.mode;
    name = state.name;
    address = state.address;
    email = state.email;
    password = state.password;
    emailStatus = state.emailStatus;
    residentsCount = state.residentsCount;
    manager = state.manager;
    currentStep = state.currentStep;
    editMode = state.editMode;
  }

  SignUpEditProfileBlocMode mode;
  String name;
  Address address;
  String email;
  int residentsCount = 0;
  Manager manager;
  String password;

  bool get addressIsDefined => address != null;

  LoadStatus emailStatus = LoadStatus.none;
  LoadStatus loadStatus = LoadStatus.none;

  int get lastStep => mode == SignUpEditProfileBlocMode.signUp ? 7 : 6;
  int currentStep = 0;
  bool editMode = false;

  void _goToNextStep() {
    if (editMode) {
      currentStep = lastStep - 1;
      editMode = false;
    } else {
      currentStep++;
    }
  }

  void _goToPreviousStep() {
    currentStep--;
  }

  void _editStep(SignUpEditProfileStep step) {
    editMode = true;
    switch (step) {
      case SignUpEditProfileStep.name:
        currentStep = 0;
        break;
      case SignUpEditProfileStep.address:
        currentStep = 1;
        break;
      case SignUpEditProfileStep.residentCount:
        currentStep = 2;
        break;
      case SignUpEditProfileStep.manager:
        currentStep = 3;
        break;
      case SignUpEditProfileStep.email:
        currentStep = 4;
        break;
      case SignUpEditProfileStep.password:
        currentStep = 5;
        break;
    }
  }
}

enum SignUpEditProfileStep {
  name,
  email,
  address,
  manager,
  residentCount,
  password
}

enum SignUpEditProfileBlocMode { signUp, editProfile }
