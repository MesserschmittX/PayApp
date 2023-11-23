import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:payapp/paypal_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'settings.dart';
import 'about.dart';
import 'transfer.dart';
import 'init.dart';
import 'splash_screen.dart';

/// Flutter code sample for [NavigationBar].

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
        title: translate('home_screen.init'),
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
              return HomePage();
            } else {
              return SplashScreen();
            }
          },
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentPageIndex = 0;

  void onSelected(BuildContext context, item) {
    switch (item) {
      case 'settings':
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => SettingsPage()));
        break;
      case 'about':
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => AboutPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Image.asset('assets/images/PayApp.jpeg'),
        title: Text(translate('home_screen.title')),
        actions: <Widget>[
          PopupMenuButton(
              icon: Icon(Icons.menu),
              onSelected: (value) => onSelected(context, value),
              itemBuilder: (context) => [
                    PopupMenuItem(
                      value: "settings",
                      child: Text(translate('home_screen.settings')),
                    ),
                    PopupMenuItem(
                      value: "about",
                      child: Text(translate('home_screen.about')),
                    )
                  ])
        ],
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Color.fromARGB(255, 207, 194, 194),
        selectedIndex: currentPageIndex,
        destinations: <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: translate('home_screen.navigation.home'),
          ),
          NavigationDestination(
            icon: Icon(Icons.business),
            label: translate('home_screen.navigation.transactions'),
          ),
        ],
      ),
      body: <Widget>[
        Container(
          color: Color.fromARGB(255, 24, 26, 28),
          alignment: Alignment.center,
          child: ElevatedButton(
            child: Text(translate("home_screen.transfer")),
            style: ElevatedButton.styleFrom(
              primary: Color.fromARGB(255, 163, 157, 157),
              elevation: 0,
              alignment: Alignment.center,
            ),
            onPressed: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => TransferPage()));
            },
          ),
        ),
        Column(
          children: [
            Text('${translate("home_screen.transactions")}:'),
            Text(PaypalService().getTransactions()),
          ],
        ),
      ][currentPageIndex],
    );
  }
}
