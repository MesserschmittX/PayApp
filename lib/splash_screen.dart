import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset('assets/images/PayApp.jpeg'),
          SizedBox(height: 20),
          CircularProgressIndicator()
        ],
      ),
    );
  }
}