import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:paysnap/styles.dart';
import 'login.dart';
import 'firebase_exceptions.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'settings.dart';

class UserChangePassword extends StatefulWidget {
  const UserChangePassword({super.key});

  @override
  UserChangePasswordState createState() => UserChangePasswordState();
}

class UserChangePasswordState extends State<UserChangePassword> {
  FirebaseAuth auth = FirebaseAuth.instance;
  static late AuthStatus _status;

  final passwordOldController = TextEditingController();
  final passwordNew1Controller = TextEditingController();
  final passwordNew2Controller = TextEditingController();
  bool _changeEnabled = false;
  bool passwordOldVisible = false;
  bool passwordNew1Visible = false;
  bool passwordNew2Visible = false;

  @override
  void initState() {
    super.initState();
    passwordOldVisible = true;
    passwordNew1Visible = true;
    passwordNew2Visible = true;
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    passwordOldController.dispose();
    passwordNew1Controller.dispose();
    passwordNew2Controller.dispose();
    super.dispose();
  }

  Future<AuthStatus> changePassword(
      {required String passwordOld,
      required passwordNew1,
      required passwordNew2}) async {
    final user = auth.currentUser;
    final credential = EmailAuthProvider.credential(
        email: user!.email.toString(), password: passwordOld);
    try {
      await user.reauthenticateWithCredential(credential);
      // proceed with password change
      if (passwordNew1 != passwordNew2) {
        _status = AuthStatus.differentPassword;
      } else {
        await user.updatePassword(passwordNew1).then((_) {
          _status = AuthStatus.successful;
        }).catchError((e) {
          _status = AuthExceptionHandler.handleAuthException(e);
        });
      }
    } on FirebaseAuthException catch (e) {
      _status = AuthExceptionHandler.handleAuthException(e);
    }

    return _status;
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
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    navigateToPage(Widget page) => Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => page,
          ),
        );

    return Scaffold(
      appBar: AppBar(
        title: Text(translate('user_changePassword_screen.title')),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                  left: 15.0, right: 15.0, top: 15, bottom: 15),
              child: TextField(
                controller: passwordOldController,
                obscureText: passwordOldVisible,
                onChanged: (value) {
                  updateChangeState();
                },
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: translate(
                      'user_changePassword_screen.old_password_label'),
                  hintText:
                      translate('user_changePassword_screen.old_password_hint'),
                  suffixIcon: IconButton(
                    icon: Icon(passwordOldVisible
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () {
                      setState(
                        () {
                          passwordOldVisible = !passwordOldVisible;
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 15.0, right: 15.0, top: 15, bottom: 15),
              child: TextField(
                controller: passwordNew1Controller,
                obscureText: passwordNew1Visible,
                onChanged: (value) {
                  updateChangeState();
                },
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: translate(
                      'user_changePassword_screen.new_password_label'),
                  hintText:
                      translate('user_changePassword_screen.new_password_hint'),
                  suffixIcon: IconButton(
                    icon: Icon(passwordNew1Visible
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () {
                      setState(
                        () {
                          passwordNew1Visible = !passwordNew1Visible;
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 15.0, right: 15.0, top: 15, bottom: 15),
              child: TextField(
                controller: passwordNew2Controller,
                obscureText: passwordNew2Visible,
                onChanged: (value) {
                  updateChangeState();
                },
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: translate(
                      'user_changePassword_screen.new_password_label'),
                  hintText:
                      translate('user_changePassword_screen.new_password_hint'),
                  suffixIcon: IconButton(
                    icon: Icon(passwordNew2Visible
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () {
                      setState(
                        () {
                          passwordNew2Visible = !passwordNew2Visible;
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                final status0 = await resetPassword(
                    mail: auth.currentUser!.email.toString());
                if (status0 == AuthStatus.successful) {
                  await FirebaseAuth.instance.signOut();
                  navigateToPage(const Login());
                  final snackBar = SnackBar(
                    content: Text(translate(
                        'user_changePassword_screen.reset_mail_sent')),
                  );
                  scaffoldMessenger.showSnackBar(snackBar);
                } else {
                  final error =
                      AuthExceptionHandler.generateErrorMessage(status0);
                  final snackBar = SnackBar(
                    content: Text(error),
                  );
                  scaffoldMessenger.showSnackBar(snackBar);
                }
              },
              child: Text(
                translate('user_changePassword_screen.forgot_password'),
                style: Styles.linkText,
              ),
            ),
            SizedBox(
              height: Styles.buttonHeight,
              width: Styles.buttonWidth,
              child: FilledButton(
                onPressed: !_changeEnabled
                    ? null
                    : () async {
                        final status = await changePassword(
                            passwordOld: passwordOldController.text,
                            passwordNew1: passwordNew1Controller.text,
                            passwordNew2: passwordNew2Controller.text);
                        if (status == AuthStatus.successful) {
                          navigateToPage(const SettingsPage());
                        } else {
                          final error =
                              AuthExceptionHandler.generateErrorMessage(status);
                          final snackBar = SnackBar(
                            content: Text(error),
                          );
                          scaffoldMessenger.showSnackBar(snackBar);
                        }
                      },
                child: Text(translate(
                    'user_changePassword_screen.change_password_button')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void updateChangeState() {
    setState(() {
      // Update button state based on input fields
      _changeEnabled = passwordOldController.text.isNotEmpty &&
          passwordNew1Controller.text.isNotEmpty &&
          passwordNew2Controller.text.isNotEmpty;
    });
  }
}
