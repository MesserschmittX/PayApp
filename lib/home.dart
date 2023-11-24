import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uni_links/uni_links.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:payapp/paypal_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'settings.dart';
import 'about.dart';
import 'transfer.dart';
import 'transfer_data.dart';
import 'qrcode_scanner.dart';
import 'login.dart';

bool _initialURILinkHandled = false;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentPageIndex = 0;

  StreamSubscription? _streamSubscription;
  Object? _err;
  Uri? _incomingURI;
  Map<String, String> _uriQuery = {};
  String _uid = '';
  String _product = '';
  double _amount = 0.0;

  @override
  void initState() {
    super.initState();
    _initURIHandler();
    _incomingLinkHandler();
  }

  Future<void> _initURIHandler() async {
    // 1
    if (!_initialURILinkHandled) {
      _initialURILinkHandled = true;
      try {
        // 3
        final initialURI = await getInitialUri();
        // 4
        if (initialURI != null) {
          debugPrint("Initial URI received $initialURI");
          if (!mounted) {
            return;
          }
          setState(() {
            _incomingURI = initialURI;
          });
          processURI();
        } else {
          debugPrint("Null Initial URI received");
        }
      } on PlatformException {
        // 5
        debugPrint("Failed to receive initial uri");
      } on FormatException catch (err) {
        // 6
        if (!mounted) {
          return;
        }
        debugPrint('Malformed Initial URI received');
      }
    }
  }

  void _incomingLinkHandler() {
    // 2
    _streamSubscription = uriLinkStream.listen((Uri? uri) {
      if (!mounted) {
        return;
      }
      debugPrint('Received URI: $uri');
      setState(() {
        _incomingURI = uri;
        _err = null;
        processURI();
      });
      // 3
    }, onError: (Object err) {
      if (!mounted) {
        return;
      }
      debugPrint('Error occurred: $err');
      setState(() {
        _incomingURI = null;
        if (err is FormatException) {
          _err = err;
        } else {
          _err = null;
        }
      });
    });
  }

  void processURI() {
    print('process URI');
    if (_incomingURI != null) {
      if (_incomingURI?.host == 'transfer') {
        _uriQuery = _incomingURI!.queryParameters;
        _uid = _uriQuery['uid'].toString();
        _product = _uriQuery['product'].toString();
        _amount = double.parse(_uriQuery['amount'].toString());
        var transferData = TransferData(_uid, _product, _amount);
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => TransferPage(transferData)));
      }
    }
  }

  Future<void> onSelected(BuildContext context, item) async {
    switch (item) {
      case 'settings':
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => SettingsPage()));
        break;
      case 'about':
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => AboutPage()));
      case 'logout':
        await FirebaseAuth.instance.signOut();
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => Login()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
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
                      ),
                      PopupMenuItem(
                        value: "logout",
                        child: Text('Logout'),
                      ),
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
              child: Text("Scan QR-Code"),
              style: ElevatedButton.styleFrom(
                primary: Color.fromARGB(255, 163, 157, 157),
                elevation: 0,
                alignment: Alignment.center,
              ),
              onPressed: () async {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const QRScanner(),
                ));
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
      ),
    );
  }
}
