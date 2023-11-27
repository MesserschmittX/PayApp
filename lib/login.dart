import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:paysnap/styles.dart';
import 'user_reset_password.dart';
import 'home.dart';
import 'user_new.dart';

import 'package:firebase_auth/firebase_auth.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<Login> {
  FirebaseAuth auth = FirebaseAuth.instance;

  final mailController = TextEditingController();
  final passwordController = TextEditingController();
  String _signInError = '';
  bool _loginEnabled = false;
  bool _passwordVisible = false;

  @override
  void initState() {
    super.initState();
    _passwordVisible = true;
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    mailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // Sign in
  Future<void> signIn() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    navigateToPage(Widget page) => Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => page,
          ),
        );

    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: mailController.text,
        password: passwordController.text,
      );

      // Sign in successful -> navigate to home page
      if (userCredential.user != null) {
        navigateToPage(const HomePage());
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential') {
        _signInError = translate('login_screen.error.invalid_credentials');
      } else if (e.code == 'invalid-email') {
        _signInError = translate('login_screen.error.invalid_email');
      } else {
        _signInError = translate('login_screen.error.sign_in');
      }
      final snackBar = SnackBar(
        content: Text(_signInError),
      );
      scaffoldMessenger.showSnackBar(snackBar);
    } catch (e) {
      _signInError = translate('login_screen.error.sign_in');
      final snackBar = SnackBar(
        content: Text(_signInError),
      );
      scaffoldMessenger.showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (val) => false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(translate('login_screen.title')),
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 60.0),
                child: Center(
                  child: SizedBox(
                      width: 200,
                      height: 150,
                      child: Image.asset('assets/images/paysnap.png')),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: TextField(
                  controller: mailController,
                  onChanged: (value) {
                    updateLoginState();
                  },
                  decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: translate('login_screen.email_label'),
                      hintText: translate('login_screen.email_hint')),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 15, bottom: 30),
                child: TextField(
                  controller: passwordController,
                  obscureText: _passwordVisible,
                  onChanged: (value) {
                    updateLoginState();
                  },
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: translate('login_screen.password_label'),
                    hintText: translate('login_screen.password_hint'),
                    suffixIcon: IconButton(
                      icon: Icon(_passwordVisible
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () {
                        setState(
                          () {
                            _passwordVisible = !_passwordVisible;
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const UserResetPassword()));
                },
                child: Text(
                  translate('login_screen.forgot_password_button'),
                  style: Styles.linkText,
                ),
              ),
              SizedBox(
                height: Styles.buttonHeight,
                width: Styles.buttonWidth,
                child: FilledButton(
                  onPressed: !_loginEnabled ? null : () => signIn(),
                  child: Text(translate('login_screen.login_button')),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const UserNew()));
                },
                child: Text(
                  translate('login_screen.new_user_link'),
                  style: Styles.linkText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void updateLoginState() {
    setState(() {
      // Update button state based on input fields
      _loginEnabled =
          mailController.text.isNotEmpty && passwordController.text.isNotEmpty;
    });
  }
}
