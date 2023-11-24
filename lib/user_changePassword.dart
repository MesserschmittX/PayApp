import 'package:flutter/material.dart';
import 'login.dart';
import 'firebase_exceptions.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'settings.dart';

class UserChangePassword extends StatefulWidget {
  @override
  _UserChangePasswordState createState() => _UserChangePasswordState();
}

class _UserChangePasswordState extends State<UserChangePassword> {
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
    print(user.email.toString());
    try {
      await user.reauthenticateWithCredential(credential);
      // proceed with password change
      if (passwordNew1 != passwordNew2) {
        _status = AuthStatus.differentPassword;
      } else {
        await user!.updatePassword(passwordNew1).then((_) {
          _status = AuthStatus.successful;
        }).catchError((e) {
          _status = AuthExceptionHandler.handleAuthException(e);
        });
      }
    } on FirebaseAuthException catch (e) {
      _status = AuthExceptionHandler.handleAuthException(e);
      print(e);
      print(e.code);
      print("Authentifizierung mit altem Passwort fehlgeschlagen");
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Change Password"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
              padding: const EdgeInsets.only(
                  left: 15.0, right: 15.0, top: 15, bottom: 15),
              child: TextField(
                controller: passwordOldController,
                obscureText: passwordOldVisible,
                onChanged: (value) {
                  updateChangeState();
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Old password',
                  hintText: 'Enter password',
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
              //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
              padding: const EdgeInsets.only(
                  left: 15.0, right: 15.0, top: 15, bottom: 15),
              child: TextField(
                controller: passwordNew1Controller,
                obscureText: passwordNew1Visible,
                onChanged: (value) {
                  updateChangeState();
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'New password',
                  hintText: 'Enter password',
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
              //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
              padding: const EdgeInsets.only(
                  left: 15.0, right: 15.0, top: 15, bottom: 15),
              child: TextField(
                controller: passwordNew2Controller,
                obscureText: passwordNew2Visible,
                onChanged: (value) {
                  updateChangeState();
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'New password',
                  hintText: 'Enter password',
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
                final _status = await resetPassword(
                    mail: auth.currentUser!.email.toString());
                if (_status == AuthStatus.successful) {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Login(),
                    ),
                  );
                  final snackBar = SnackBar(
                    content: Text(
                        "Eine E-Mail zum Reset ihres Passworts wurde übermittelt"),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                } else {
                  final _error =
                      AuthExceptionHandler.generateErrorMessage(_status);
                  final snackBar = SnackBar(
                    content: Text(_error),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
              },
              child: Text(
                'Forgot old password',
                style: TextStyle(color: Colors.blue, fontSize: 15),
              ),
            ),
            Container(
              height: 50,
              width: 250,
              decoration: BoxDecoration(
                  color: Colors.blue, borderRadius: BorderRadius.circular(20)),
              child: TextButton(
                onPressed: () async {
                  if (_changeEnabled) {
                    final _status = await changePassword(
                        passwordOld: passwordOldController.text,
                        passwordNew1: passwordNew1Controller.text,
                        passwordNew2: passwordNew2Controller.text);
                    if (_status == AuthStatus.successful) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SettingsPage(),
                        ),
                      );
                    } else {
                      final _error =
                          AuthExceptionHandler.generateErrorMessage(_status);
                      final snackBar = SnackBar(
                        content: Text(_error),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                  }
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                      // Ändere die Farbe basierend auf dem Zustand des Buttons
                      if (_changeEnabled) {
                        return Colors.blue; // Farbe für deaktivierten Zustand
                      } else {
                        return Colors.grey;
                      } // Farbe für aktivierten Zustand
                    },
                  ),
                ),
                child: Text(
                  'Change Password',
                  style: TextStyle(color: Colors.white, fontSize: 25),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void updateChangeState() {
    setState(() {
      // Aktualisiere den Zustand des Buttons basierend auf der Eingabe in beiden Feldern
      _changeEnabled = passwordOldController.text.isNotEmpty &&
          passwordNew1Controller.text.isNotEmpty &&
          passwordNew2Controller.text.isNotEmpty;
    });
  }
}
