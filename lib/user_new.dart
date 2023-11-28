import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:paysnap/styles.dart';
import 'home.dart';

import 'package:firebase_auth/firebase_auth.dart';

class UserNew extends StatefulWidget {
  const UserNew({super.key});

  @override
  UserNewState createState() => UserNewState();
}

class UserNewState extends State<UserNew> {
  FirebaseAuth auth = FirebaseAuth.instance;

  final mailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  String _signUpError = '';
  bool _signUpEnabled = false;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    mailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  // Sign in
  Future<void> signUp() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    navigateToPage(Widget page) => Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => page,
          ),
        );
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: mailController.text,
        password: passwordController.text,
      );
      userCredential.user?.updateDisplayName(nameController.text);

      // Sign up successful -> navigate to home page
      if (userCredential.user != null) {
        navigateToPage(const HomePage());
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        _signUpError = translate('user_new_screen.error.password_to_weak');
      } else if (e.code == 'email-already-in-use') {
        _signUpError = translate('user_new_screen.error.already_exists');
      } else if (e.code == 'invalid-email') {
        _signUpError = translate('user_new_screen.error.invalid_email');
      } else {
        _signUpError = translate('user_new_screen.error.sign_up');
      }
      final snackBar = SnackBar(
        content: Text(_signUpError),
      );
      scaffoldMessenger.showSnackBar(snackBar);
    } catch (e) {
      _signUpError = translate('user_new_screen.error.sign_up');
      final snackBar = SnackBar(
        content: Text(_signUpError),
      );
      scaffoldMessenger.showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(translate('user_new_screen.title')),
        backgroundColor: Styles.primaryColor,
        foregroundColor: Styles.secondaryColor,
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
                    child: Image.asset('assets/images/paysnap_loginLogo.png')),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 15),
              child: TextField(
                controller: nameController,
                onChanged: (value) {
                  updateSignUpState();
                },
                decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: translate('user_new_screen.name_label'),
                    hintText: translate('user_new_screen.name_hint')),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 15),
              child: TextField(
                controller: mailController,
                onChanged: (value) {
                  updateSignUpState();
                },
                decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: translate('user_new_screen.email_label'),
                    hintText: translate('user_new_screen.email_hint')),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 30),
              child: TextField(
                controller: passwordController,
                onChanged: (value) {
                  updateSignUpState();
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
                onPressed: !_signUpEnabled ? null : () => signUp(),
                child: Text(translate('user_new_screen.create_account_button')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void updateSignUpState() {
    setState(() {
      // Update button state based on input fields
      _signUpEnabled = mailController.text.isNotEmpty &&
          passwordController.text.isNotEmpty &&
          nameController.text.isNotEmpty;
    });
  }
}
