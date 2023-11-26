import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:paysnap/styles.dart';
import 'home.dart';

import 'package:firebase_auth/firebase_auth.dart';

class UserNew extends StatefulWidget {
  @override
  _UserNewState createState() => _UserNewState();
}

class _UserNewState extends State<UserNew> {
  FirebaseAuth auth = FirebaseAuth.instance;

  final mailController = TextEditingController();
  final passwordController = TextEditingController();
  String _error_signUp = '';
  bool _signupEnabled = false;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    mailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // Sign in
  Future<void> signUp() async {
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: mailController.text,
        password: passwordController.text,
      );

      // Sign up successfull -> navigate to home page
      if (userCredential.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        _error_signUp = translate('user_new_screen.error.password_to_weak');
      } else if (e.code == 'email-already-in-use') {
        _error_signUp = translate('user_new_screen.error.already_exists');
      } else if (e.code == 'invalid-email') {
        _error_signUp = translate('user_new_screen.error.invalid_email');
      } else {
        _error_signUp = translate('user_new_screen.error.sign_up');
      }
      final snackBar = SnackBar(
        content: Text(_error_signUp),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } catch (e) {
      _error_signUp = translate('user_new_screen.error.sign_up');
      final snackBar = SnackBar(
        content: Text(_error_signUp),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(translate('user_new_screen.title')),
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
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                controller: mailController,
                onChanged: (value) {
                  updateSignupState();
                },
                decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: translate('user_new_screen.email_label'),
                    hintText: translate('user_new_screen.email_hint')),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 15.0, right: 15.0, top: 15, bottom: 30),
              //padding: EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                controller: passwordController,
                onChanged: (value) {
                  updateSignupState();
                },
                obscureText: true,
                decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: translate('user_new_screen.password_label'),
                    hintText: translate('user_new_screen.password_hint')),
              ),
            ),
            SizedBox(
              height: Styles.buttonHeight,
              width: Styles.buttonWidth,
              child: FilledButton(
                onPressed: !_signupEnabled ? null : () => signUp(),
                child: Text(translate('user_new_screen.create_account_button')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void updateSignupState() {
    setState(() {
      // Aktualisiere den Zustand des Buttons basierend auf der Eingabe in beiden Feldern
      _signupEnabled =
          mailController.text.isNotEmpty && passwordController.text.isNotEmpty;
    });
  }
}
