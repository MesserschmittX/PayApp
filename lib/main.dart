import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'init.dart';
import 'splash_screen.dart';
import 'login.dart';
import 'home.dart';

void main() async {
  var delegate = await LocalizationDelegate.create(
      fallbackLocale: 'de', supportedLocales: ['en', 'de']);
  runApp(LocalizedApp(delegate, MyApp()));
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final Future _initFuture = Init.initialize();

  @override
  Widget build(BuildContext context) {
    var localizationDelegate = LocalizedApp.of(context).delegate;

    return LocalizationProvider(
      state: LocalizationProvider.of(context).state,
      child: MaterialApp(
        title: translate('main_screen.init'),
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          localizationDelegate
        ],
        supportedLocales: localizationDelegate.supportedLocales,
        locale: localizationDelegate.currentLocale,
        theme: ThemeData(primarySwatch: Colors.blue),
        home: FutureBuilder(
          future: _initFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (FirebaseAuth.instance.currentUser != null) {
                // signed in
                return HomePage();
              } else {
                // signed out
                return Login();
              }
            } else {
              return SplashScreen();
            }
          },
        ),
      ),
    );
  }
}
