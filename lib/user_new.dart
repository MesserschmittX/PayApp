import 'package:flutter/material.dart';
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
        _error_signUp = 'The password provided is too weak';
      } else if (e.code == 'email-already-in-use') {
        _error_signUp = 'An account already exists for that email';
      } else if (e.code == 'invalid-email') {
        _error_signUp = 'Invalid e-mail address';
      } else {
        _error_signUp = 'Error at sign up';
      }
      final snackBar = SnackBar(
        content: Text(e.code),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } catch (e) {
      _error_signUp = 'Error at sign up';
      final snackBar = SnackBar(
        content: Text(_error_signUp),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Useranlage"),
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
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                controller: mailController,
                onChanged: (value) {
                  updateSignupState();
                },
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Email',
                    hintText: 'Enter email'),
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
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                    hintText: 'Enter password'),
              ),
            ),
            Container(
              height: 50,
              width: 250,
              decoration: BoxDecoration(
                  color: Colors.blue, borderRadius: BorderRadius.circular(20)),
              child: TextButton(
                onPressed: () {
                  if (_signupEnabled) {
                    signUp();
                  }
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                      // Ändere die Farbe basierend auf dem Zustand des Buttons
                      if (_signupEnabled) {
                        return Colors.blue; // Farbe für deaktivierten Zustand
                      } else {
                        return Colors.grey;
                      } // Farbe für aktivierten Zustand
                    },
                  ),
                ),
                child: Text(
                  'User anlegen',
                  style: TextStyle(color: Colors.white, fontSize: 25),
                ),
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
