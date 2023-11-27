import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:paysnap/styles.dart';

import 'init.dart';
import 'splash_screen.dart';
import 'login.dart';
import 'home.dart';

void main() async {
  var delegate = await LocalizationDelegate.create(
      fallbackLocale: 'de', supportedLocales: ['en', 'de']);
  runApp(LocalizedApp(delegate, const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  final Future _initFuture = Init.initialize();

  Brightness _brightness = Brightness.light;

  void _changeBrightness(Brightness newBrightness) {
    setState(() {
      _brightness = newBrightness;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //PASSING THE FUNCTION AS PARAMETER
      Styles.changeBrightness = _changeBrightness;
    });
  }

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
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Styles.primaryColor,
            brightness: _brightness,
          ),
          textTheme: const TextTheme(
            displayLarge: TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.bold,
            ),
            titleLarge: TextStyle(
              fontSize: 30,
            ),
            bodyMedium: TextStyle(
              fontSize: 22,
            ),
            displaySmall: TextStyle(
              fontSize: 16,
            ),
          ),
        ),
        home: FutureBuilder(
          future: _initFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (FirebaseAuth.instance.currentUser != null) {
                // signed in
                return const HomePage();
              } else {
                // signed out
                return const Login();
              }
            } else {
              return const SplashScreen();
            }
          },
        ),
      ),
    );
  }
}
