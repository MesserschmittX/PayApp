import 'package:flutter/material.dart';
import 'package:paysnap/styles.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Container(
      decoration: const BoxDecoration(
          gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Styles.primaryColor,
          Colors.cyanAccent,
        ],
      )),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: SizedBox(
                width: 250,
                height: 200,
                child: Image.asset('assets/images/paysnap_loginLogo.png')),
          ),
        ],
      ),
    ));
  }
}
