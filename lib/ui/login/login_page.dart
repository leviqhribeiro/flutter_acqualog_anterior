import 'package:canteiro/blocs/app_bloc.dart';
import 'package:canteiro/blocs/bloc_event.dart';
import 'package:canteiro/blocs/load_status.dart';
import 'package:canteiro/blocs/login_page_bloc.dart';
import 'package:canteiro/helpers/load_status_error_generic_feedback_helper.dart';
import 'package:canteiro/helpers/mask_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:canteiro/router.dart';
import 'package:canteiro/ui/widgets/load_action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailFormField = GlobalKey<FormFieldState>();
  final _passwordFormField = GlobalKey<FormFieldState>();

  final _emailTFController = TextEditingController();
  final _passwordTFController = TextEditingController();
  final _emailConfirmationTFController = TextEditingController();

  final scaffoldKey = new GlobalKey<ScaffoldState>();

  FocusNode _emailNode;
  FocusNode _passwordNode;

  LoginPageBloc _bloc;

  @override
  void initState() {
    super.initState();
    _emailNode = FocusNode();
    _passwordNode = FocusNode();
    _bloc = LoginPageBloc(LoginPageBlocState());
//    _emailTFController.text = 'carloscruz@nucleus.eti.br';
//    _passwordTFController.text = 'secret';
  }

  @override
  void dispose() {
    _emailNode.dispose();
    _passwordNode.dispose();
    _emailTFController.dispose();
    _passwordTFController.dispose();
    _emailConfirmationTFController.dispose();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // systemOverlayStyle: SystemUiOverlayStyle.light,
        brightness: Brightness.light,
      ),
      body: BlocListener<LoginPageBloc, LoginPageBlocState>(
        bloc: _bloc,
        listenWhen: (oldState, newState) =>
            oldState.loginStatus != newState.loginStatus,
        listener: (context, state) {
          switch (state.loginStatus) {
            case LoadStatus.success:
              BlocProvider.of<AppBloc>(context).add(
                  BlocEvent(AppBlocEvent.setNewSignedInUser, data: state.user));
              _goToHomePage();
              break;
            case LoadStatus.failed:
            case LoadStatus.unauthorized:
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                AppLocalizations.of(context).login_failed_verify_credentials,
              )));
              break;
            default:
              if (state.loginStatus.hasError) {
                LoadStatusErrorGenericFeedbackHelper.showSnackbarForLoadStatus(
                  context: context,
                  loadStatus: state.loginStatus,
                );
              }
              break;
          }
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: double.infinity,
              height: double.infinity,
            ),
            SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Hero(
                    tag: 'logo',
                    child: ConstrainedBox(
                      constraints: BoxConstraints.loose(Size.fromWidth(200)),
                      child: Image.asset(
                        "assets/images/logo.png",
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 32, right: 32, bottom: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _buildCredentialsWidget(),
                        SizedBox(height: 16),
                        _buildSignInWidget(),
                        SizedBox(height: 30),
                        _buildForgotPasswordButton(),
                        _buildSignUpButton(),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  InputDecoration loginTFInputDecoration(
      {String hint, Widget prefixIcon, Widget suffixIcon}) {
    return InputDecoration(
      isDense: true,
      hintText: hint,
      suffixIcon: suffixIcon,
      prefixIcon: prefixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
      ),
    );
  }

  //Email and password fields
  Widget _buildCredentialsWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        TextFormField(
          controller: _emailTFController,
          key: _emailFormField,
          decoration: loginTFInputDecoration(
              hint: AppLocalizations.of(context).email,
              prefixIcon: Icon(Icons.person)),
          focusNode: _emailNode,
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.emailAddress,
          validator: _validateEmail,
          onFieldSubmitted: (_) {
            FocusScope.of(context).requestFocus(_passwordNode);
          },
        ),
        SizedBox(
          height: 16,
        ),
        BlocBuilder<LoginPageBloc, LoginPageBlocState>(
            bloc: _bloc,
            buildWhen: (oldState, newState) =>
                oldState.obscurePassword != newState.obscurePassword,
            builder: (context, state) {
              return TextFormField(
                controller: _passwordTFController,
                key: _passwordFormField,
                decoration: loginTFInputDecoration(
                  hint: AppLocalizations.of(context).password,
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: _buildSeePasswordWidget(state.obscurePassword),
                ),
                focusNode: _passwordNode,
                textInputAction: TextInputAction.go,
                obscureText: state.obscurePassword,
                validator: _validatePassword,
                onFieldSubmitted: (_) {
                  _onSignInButtonPressed();
                },
              );
            }),
      ],
    );
  }

  Widget _buildSeePasswordWidget(bool obscurePassword) {
    return IconButton(
      icon: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: obscurePassword
            ? Icon(
                Icons.visibility_off,
                key: ValueKey(1),
              )
            : Icon(
                Icons.visibility,
                key: ValueKey(2),
              ),
      ),
      onPressed: () {
        _bloc.add(BlocEvent(LoginPageBlocEvent.toggleObscurePassword));
      },
    );
  }

  //Sign in widget, has the animation to show loading.
  Widget _buildSignInWidget() {
    return BlocBuilder<LoginPageBloc, LoginPageBlocState>(
      bloc: _bloc,
      buildWhen: (oldState, newState) =>
          oldState.loginStatus != newState.loginStatus,
      builder: (context, state) {
        return LoadActionButton(
          child: Text(
            AppLocalizations.of(context).signIn,
          ),
          isLoading: state.loginStatus == LoadStatus.executing,
          onPressed: _onSignInButtonPressed,
        );
      },
    );
  }

  //Forget Password button
  Widget _buildForgotPasswordButton() {
    return MaterialButton(
      child: Container(
        child: Container(
          decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey))),
          child: Text(
            AppLocalizations.of(context).forgot_password,
          ),
        ),
      ),
      onPressed: () {
        Navigator.of(context).pushNamed(AppRouter.recoverPassword);
      },
    );
  }

  Widget _buildSignUpButton() {
    return MaterialButton(
      child: Container(
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey))),
        child: Text(
          AppLocalizations.of(context).sign_up_here,
        ),
      ),
      onPressed: () {
        Navigator.of(context).pushNamed(AppRouter.signUp);
      },
    );
  }

  String _validateEmail(String value) {
    if (value != null &&
        value.isNotEmpty &&
        ValidatorHelper.isAValidEmail(value.trim())) {
      return null;
    }
    return AppLocalizations.of(context).invalidEmail;
  }

  String _validatePassword(String value) {
    if (value != null && value.isNotEmpty) {
      return null;
    }
    return AppLocalizations.of(context).obligatedField;
  }

  void _onSignInButtonPressed() {
    final emailValid = _emailFormField.currentState.validate();
    final passwordValid = _passwordFormField.currentState.validate();
    if (emailValid && passwordValid) {
      _performSignIn(
          email: _emailTFController.text, password: _passwordTFController.text);
    }
  }

  void _performSignIn(
      {@required String email, @required String password}) async {
    _bloc.add(BlocEvent(LoginPageBlocEvent.performSignIn, data: {
      'email': email,
      'password': password,
    }));
  }

  void _goToHomePage() {
    Navigator.of(context).pushReplacementNamed(AppRouter.home);
  }
}
