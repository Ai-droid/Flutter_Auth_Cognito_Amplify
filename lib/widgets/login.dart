import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:flutter_login/flutter_login.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  LoginData _data;
  bool _isSignedIn = false;

  Future<String> _onLogin(LoginData data) async {
    try {
      final res = await Amplify.Auth.signIn(
        username: data.name,
        password: data.password,
      );

      _isSignedIn = res.isSignedIn;
    } catch (e) {
      for (final err in e.exceptionList) {
        if (err.exception == 'NOT_AUTHORIZED') {
          return err.detail;
        }

        if (err.exception == 'INVALID_STATE') {
          if (err.detail.contains('already a user which is signed in')) {
            await Amplify.Auth.signOut();
            return 'Problem logging in. Please try again.';
          }

          return err.detail;
        }
      }

      return 'There was a problem signing up. Please try again.';
    }
  }

  Future<String> _onRecoverPassword(BuildContext context, String email) async {
    try {
      final res = await Amplify.Auth.resetPassword(username: email);

      if (res.nextStep.updateStep == 'CONFIRM_RESET_PASSWORD_WITH_CODE') {
        Navigator.of(context).pushReplacementNamed(
          '/confirm-reset',
          arguments: LoginData(name: email, password: ''),
        );
      }
    } catch (e) {
      for (final err in e.exceptionList) {
        if (err.exception == 'INVALID_PARAMETER') {
          return err.detail;
        }
      }
      return e.cause;
    }
  }

  Future<String> _onSignup(LoginData data) async {
    try {
      await Amplify.Auth.signUp(
        username: data.name,
        password: data.password,
        options: CognitoSignUpOptions(userAttributes: {
          'email': data.name,
        }),
      );

      _data = data;
    } catch (e) {
      for (final err in e.exceptionList) {
        if (err.exception == 'USERNAME_EXISTS') {
          return err.detail;
        }
      }

      return 'There was a problem signing up. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: 'Welcome to Apay',
      onLogin: _onLogin,
      onRecoverPassword: (String email) => _onRecoverPassword(context, email),
      onSignup: _onSignup,
      theme: LoginTheme(
        primaryColor: Theme.of(context).primaryColor,
      ),
      onSubmitAnimationCompleted: () {
        Navigator.of(context).pushReplacementNamed(
          _isSignedIn ? '/dashboard' : '/confirm',
          arguments: _data,
        );
      },
    );
  }
}

/*
class LoginScreen extends StatelessWidget {
  LoginScreen({Key key}) : super(key: key);

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextFormField(
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: "Phone"),
                controller: _phoneController,
                //validator: (value) =>!validateEmail(value) ? "Email is Invalid" : null,
              ),
              TextFormField(
                keyboardType: TextInputType.visiblePassword,
                decoration: InputDecoration(labelText: "Password"),
                obscureText: true,
                controller: _passwordController,
                validator: (value) =>
                value.isEmpty ? "Password is invalid" : null,
              ),
              SizedBox(
                height: 20,
              ),
              RaisedButton(
                child: Text("LOG IN"),
                onPressed: () => _onLogin(context),
                color: Theme
                    .of(context)
                    .primaryColor,
              ),
              OutlineButton(
                child: Text("Create New Account"),
                onPressed: () => _onSignup(context),
                color: Theme
                    .of(context)
                    .primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String> _onLogin(BuildContext context) async {
    if (_formKey.currentState.validate()) {
      try {
        final String withcode = "+91" + _phoneController.text;
        final res = await Amplify.Auth.signIn(
          username: withcode,
          password: _passwordController.text,
        );

        bool _isSignedIn = res.isSignedIn;
      } catch (e) {
        for (final err in e.exceptionList) {
          if (err.exception == 'NOT_AUTHORIZED') {
            return err.detail;
          }

          if (err.exception == 'INVALID_STATE') {
            if (err.detail.contains('already a user which is signed in')) {
              await Amplify.Auth.signOut();
              return 'Problem logging in. Please try again.';
            }

            return err.detail;
          }
        }

        return 'There was a problem signing up. Please try again.';
      }
    }
  }
  Future<String> _onSignup(BuildContext context) async {
    try {
      final String withcode = "+91" + _phoneController.text;
      await Amplify.Auth.signUp(
        username: withcode,
        password: _passwordController.text,
        options: CognitoSignUpOptions(userAttributes: {
          'phone_number': withcode,
        }),
      );

      _data = data;
    } catch (e) {
      for (final err in e.exceptionList) {
        if (err.exception == 'USERNAME_EXISTS') {
          return err.detail;
        }
      }

      return 'There was a problem signing up. Please try again.';
    }
  }

}*/
