import 'package:flutter/material.dart';
import 'package:payapp/paypal_service.dart';

import 'settings.dart';
import 'about.dart';
import 'transfer.dart';
import 'init.dart';
import 'splash_screen.dart';

/// Flutter code sample for [NavigationBar].

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final Future _initFuture = Init.initialize();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Initialization',
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
        title: const Text('Pay App'),
        actions: <Widget>[
          PopupMenuButton(
              icon: Icon(Icons.menu),
              onSelected: (value) => onSelected(context, value),
              itemBuilder: (context) => [
                    PopupMenuItem(
                      value: "settings",
                      child: Text('Settings'),
                    ),
                    PopupMenuItem(
                      value: "about",
                      child: Text('About'),
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
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.business),
            label: 'Transaktionen',
          ),
        ],
      ),
      body: <Widget>[
        Container(
          color: Color.fromARGB(255, 24, 26, 28),
          alignment: Alignment.center,
          child: ElevatedButton(
            child: Text("Transfer"),
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
            Text('Bisherige Transaktionen:'),
            Text(PaypalService().getTransactions()),
          ],
        ),
      ][currentPageIndex],
    );
  }
}
