import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:paysnap/styles.dart';
import 'login.dart';
import 'firebase_exceptions.dart';

import 'package:firebase_auth/firebase_auth.dart';

class UserResetPassword extends StatefulWidget {
  @override
  _UserResetPasswordState createState() => _UserResetPasswordState();
}

class _UserResetPasswordState extends State<UserResetPassword> {
  FirebaseAuth auth = FirebaseAuth.instance;
  static late AuthStatus _status;

  final mailController = TextEditingController();
  bool _resetEnabled = false;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    mailController.dispose();
    super.dispose();
  }

  Future<AuthStatus> resetPassword({required String mail}) async {
    await auth
        .sendPasswordResetEmail(email: mail)
        .then((value) => _status = AuthStatus.successful)
        .catchError(
            (e) => _status = AuthExceptionHandler.handleAuthException(e));
    return _status;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(translate('user_resetPassword_screen.title')),
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
              //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
              padding: const EdgeInsets.only(
                  left: 15.0, right: 15.0, top: 15, bottom: 30),
              child: TextField(
                controller: mailController,
                onChanged: (value) {
                  updateResetState();
                },
                decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText:
                        translate('user_resetPassword_screen.email_label'),
                    hintText:
                        translate('user_resetPassword_screen.email_hint')),
              ),
            ),
            SizedBox(
              height: Styles.buttonHeight,
              width: Styles.buttonWidth,
              child: FilledButton(
                onPressed: !_resetEnabled
                    ? null
                    : () async {
                        if (_resetEnabled) {
                          _status =
                              await resetPassword(mail: mailController.text);
                          if (_status == AuthStatus.successful) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Login(),
                              ),
                            );
                          } else {
                            final error =
                                AuthExceptionHandler.generateErrorMessage(
                                    _status);
                            final snackBar = SnackBar(
                              content: Text(error),
                            );
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          }
                        }
                      },
                child: Text(translate(
                    'user_resetPassword_screen.reset_password_button')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void updateResetState() {
    setState(() {
      // Aktualisiere den Zustand des Buttons basierend auf der Eingabe in beiden Feldern
      _resetEnabled = mailController.text.isNotEmpty;
    });
  }
}
