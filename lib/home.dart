import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paysnap/licenses.dart';
import 'package:paysnap/qrcode_creator.dart';
import 'package:paysnap/styles.dart';
import 'package:uni_links/uni_links.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:paysnap/paypal_service.dart';

import 'settings.dart';
import 'about.dart';
import 'payment.dart';
import 'payment_data.dart';
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
      } on FormatException catch (e) {
        // 6
        if (!mounted) {
          return;
        }
        debugPrint('Malformed Initial URI received: ${jsonEncode(e)}');
      }
    }
  }

  void _incomingLinkHandler() {
    // 2
    uriLinkStream.listen((Uri? uri) {
      if (!mounted) {
        return;
      }
      debugPrint('Received URI: $uri');
      setState(() {
        _incomingURI = uri;
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
      });
    });
  }

  void processURI() {
    if (_incomingURI != null) {
      if (_incomingURI?.host == 'payment') {
        _uriQuery = _incomingURI!.queryParameters;
        _uid = _uriQuery['uid'].toString();
        _product = _uriQuery['product'].toString();
        _amount = double.parse(_uriQuery['amount'].toString());
        var paymentData = PaymentData(_uid, _product, _amount);
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => PaymentPage(paymentData)));
      }
    }
  }

  Future<void> onSelected(item, Function openPage) async {
    switch (item) {
      case 'settings':
        openPage(const SettingsPage());
        break;
      case 'about':
        openPage(const AboutPage());
      case 'licenses':
        openPage(const OssLicensesPage());
      case 'logout':
        await FirebaseAuth.instance.signOut();
        openPage(const Login());
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (val) => false,
      child: Scaffold(
        appBar: AppBar(
          leading: Image.asset('assets/images/paysnap.png'),
          title: Text(translate('home_screen.title')),
          actions: <Widget>[
            PopupMenuButton(
                icon: const Icon(Icons.menu),
                onSelected: (value) => onSelected(
                    value,
                    (StatelessWidget widget) => Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) => widget))),
                itemBuilder: (context) => [
                      PopupMenuItem(
                        value: "settings",
                        child: Text(
                            translate('home_screen.context_menu.settings')),
                      ),
                      PopupMenuItem(
                        value: "about",
                        child:
                            Text(translate('home_screen.context_menu.about')),
                      ),
                      PopupMenuItem(
                        value: "licenses",
                        child: Text(
                            translate('home_screen.context_menu.licenses')),
                      ),
                      PopupMenuItem(
                        value: "logout",
                        child:
                            Text(translate('home_screen.context_menu.logout')),
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
          selectedIndex: currentPageIndex,
          destinations: <Widget>[
            NavigationDestination(
              selectedIcon: const Icon(Icons.home),
              icon: const Icon(Icons.home_outlined),
              label: translate('home_screen.navigation.home'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.business),
              label: translate('home_screen.navigation.transactions'),
            ),
          ],
        ),
        body: <Widget>[
          Center(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 150.0),
                  height: Styles.buttonHeight,
                  width: Styles.buttonWidth,
                  child: FilledButton(
                    child: Text(translate('home_screen.home.scan_qr_code')),
                    onPressed: () async {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const QRScanner(),
                      ));
                    },
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 15.0),
                  height: Styles.buttonHeight,
                  width: Styles.buttonWidth,
                  child: FilledButton(
                    child: Text(translate('home_screen.home.create_qr_code')),
                    onPressed: () async {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const QRCreator(),
                      ));
                    },
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                  '${translate('home_screen.transactions.past_transactions')}:'),
              Padding(
                padding:
                    const EdgeInsets.only(top: 10.0, right: 10.0, left: 10.0),
                child: Text(PaypalService().getTransactions()),
              ),
            ],
          ),
        ][currentPageIndex],
      ),
    );
  }
}
