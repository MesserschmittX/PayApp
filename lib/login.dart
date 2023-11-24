import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'user_resetPassword.dart';
import 'home.dart';
import 'user_new.dart';

import 'package:firebase_auth/firebase_auth.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  FirebaseAuth auth = FirebaseAuth.instance;

  final mailController = TextEditingController();
  final passwordController = TextEditingController();
  String _error_signIn = '';
  bool _loginEnabled = false;
  bool passwordVisible = false;

  @override
  void initState() {
    super.initState();
    passwordVisible = true;
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
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: mailController.text,
        password: passwordController.text,
      );

      // Sign in successfull -> navigate to home page
      if (userCredential.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'INVALID_LOGIN_CREDENTIALS') {
        _error_signIn = translate('login_screen.error.invalid_credentials');
      } else if (e.code == 'invalid-email') {
        _error_signIn = translate('login_screen.error.invalid_email');
      } else {
        _error_signIn = translate('login_screen.sign_in');
      }
      final snackBar = SnackBar(
        content: Text(_error_signIn),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } catch (e) {
      _error_signIn = translate('login_screen.error.sign_in');
      final snackBar = SnackBar(
        content: Text(_error_signIn),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.white,
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
                  child: Container(
                      width: 200,
                      height: 150,
                      /*decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(50.0)),*/
                      child: Image.asset('assets/images/paysnap.jpeg')),
                ),
              ),
              Padding(
                //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: TextField(
                  controller: mailController,
                  onChanged: (value) {
                    updateLoginState();
                  },
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: translate('login_screen.email_label'),
                      hintText: translate('login_screen.email_hint')),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 15, bottom: 30),
                //padding: EdgeInsets.symmetric(horizontal: 15),
                child: TextField(
                  controller: passwordController,
                  obscureText: passwordVisible,
                  onChanged: (value) {
                    updateLoginState();
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: translate('login_screen.password_label'),
                    hintText: translate('login_screen.password_hint'),
                    suffixIcon: IconButton(
                      icon: Icon(passwordVisible
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () {
                        setState(
                          () {
                            passwordVisible = !passwordVisible;
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => UserResetPassword()));
                },
                child: Text(
                  translate('login_screen.forgot_password_button'),
                  style: TextStyle(color: Colors.blue, fontSize: 15),
                ),
              ),
              Container(
                height: 50,
                width: 250,
                decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(20)),
                child: TextButton(
                  onPressed: () {
                    if (_loginEnabled) {
                      signIn();
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                        // Ändere die Farbe basierend auf dem Zustand des Buttons
                        if (_loginEnabled) {
                          return Colors.blue; // Farbe für deaktivierten Zustand
                        } else {
                          return Colors.grey;
                        } // Farbe für aktivierten Zustand
                      },
                    ),
                  ),
                  child: Text(
                    translate('login_screen.login_button'),
                    style: TextStyle(color: Colors.white, fontSize: 25),
                  ),
                ),
              ),
              SizedBox(
                height: 130,
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (_) => UserNew()));
                },
                child: Text(
                  translate('login_screen.new_user_link'),
                  style: TextStyle(color: Colors.blue, fontSize: 15),
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
      // Aktualisiere den Zustand des Buttons basierend auf der Eingabe in beiden Feldern
      _loginEnabled =
          mailController.text.isNotEmpty && passwordController.text.isNotEmpty;
    });
  }
}