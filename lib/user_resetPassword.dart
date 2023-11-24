import 'package:flutter/material.dart';
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Reset Password"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 60.0),
              child: Center(
                child: Container(
                    width: 200,
                    height: 150,
                    /*decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(50.0)),*/
                    child: Image.asset('assets/images/PayApp.jpeg')),
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
                    border: OutlineInputBorder(),
                    labelText: 'Email',
                    hintText: 'Enter email'),
              ),
            ),
            Container(
              height: 50,
              width: 250,
              decoration: BoxDecoration(
                  color: Colors.blue, borderRadius: BorderRadius.circular(20)),
              child: TextButton(
                onPressed: () async {
                  if (_resetEnabled) {
                    final _status =
                        await resetPassword(mail: mailController.text);
                    if (_status == AuthStatus.successful) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Login(),
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
                      if (_resetEnabled) {
                        return Colors.blue; // Farbe für deaktivierten Zustand
                      } else {
                        return Colors.grey;
                      } // Farbe für aktivierten Zustand
                    },
                  ),
                ),
                child: Text(
                  'Reset Password',
                  style: TextStyle(color: Colors.white, fontSize: 25),
                ),
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
