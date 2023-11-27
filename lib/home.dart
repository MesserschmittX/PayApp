import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paysnap/licenses.dart';
import 'package:paysnap/qrcode_creator.dart';
import 'package:paysnap/styles.dart';
import 'package:uni_links/uni_links.dart';
import 'package:flutter_translate/flutter_translate.dart';

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

  FirebaseAuth auth = FirebaseAuth.instance;
  Uri? _incomingURI;
  Map<String, String> _uriQuery = {};
  String _uid = '';
  String _product = '';
  double _amount = 0.0;

  late Future<List<Map<String, dynamic>>> paymentHistory;

  @override
  void initState() {
    super.initState();
    _initURIHandler();
    _incomingLinkHandler();
    paymentHistory = getPaymentHistory(auth.currentUser!.uid);
  }

  Future<List<Map<String, dynamic>>> getPaymentHistory(String uid) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('/transfer/kevin112/history')
        .get();

    List<Map<String, dynamic>> payments = [];

    querySnapshot.docs.map((doc) {
      payments.add(doc.data() as Map<String, dynamic>);
    });

    return payments;
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
        body: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 15.0),
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
              margin: const EdgeInsets.only(top: 15.0, bottom: 15.0),
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
            const Divider(),
            Expanded(
              child: FutureBuilder(
                future: paymentHistory,
                builder: (context,
                    AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: SizedBox(
                        height: 50.0,
                        width: 50.0,
                        child: CircularProgressIndicator(),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Text(
                        '${translate('home_screen.transactions.error_loading_data')}: ${snapshot.error}');
                  } else if (snapshot.data!.isEmpty) {
                    return Text(translate(
                        'home_screen.transactions.no_transaction_history'));
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        Timestamp timestamp =
                            snapshot.data![index]['timestamp'];
                        return Card(
                            child: Column(
                          children: [
                            ListTile(
                                leading: const Icon(Icons.paid),
                                title: Text(
                                  'Receiver: ${snapshot.data![index]['receiver']}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                ),
                                subtitle: Row(children: <Widget>[
                                  Text(
                                    '${timestamp.toDate().day}.${timestamp.toDate().month}.${timestamp.toDate().year}',
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  Text(
                                    '/ - ${snapshot.data![index]['amount']} €',
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ])),
                          ],
                        ));
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
