import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:paysnap/styles.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

class QRScanner extends StatefulWidget {
  const QRScanner({super.key});

  @override
  State<StatefulWidget> createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool _isDisposed = false;
  bool _isSnackbarActive = false;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(translate('qr_scanner_screen.title')),
        backgroundColor: Styles.primaryColor,
        foregroundColor: Styles.secondaryColor,
      ),
      body: Column(
        children: <Widget>[
          Expanded(flex: 4, child: _buildQrView(context)),
          Expanded(
            flex: 1,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text(translate('qr_scanner_screen.scan_qr_code')),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: IconButton(
                          icon: const Icon(
                            Icons.lightbulb,
                            color: Styles.primaryColor,
                          ),
                          onPressed: () async {
                            await controller?.toggleFlash();
                            setState(() {});
                          },
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: IconButton(
                          icon: const Icon(
                            Icons.cameraswitch,
                            color: Styles.primaryColor,
                          ),
                          onPressed: () async {
                            await controller?.flipCamera();
                            setState(() {});
                          },
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    if (_isDisposed) {
      return const Text('Disposed');
    }
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) async {
      setState(() {
        result = scanData;
      });
      if (result != null && result!.format.name != 'qrcode') {
        if (!_isSnackbarActive) {
          _isSnackbarActive = true;
          scaffoldMessenger
              .showSnackBar(
                SnackBar(
                    content: Text(translate(
                        'qr_scanner_screen.notification.wrong_code_format'))),
              )
              .closed
              .then((_) => _isSnackbarActive = false);
        }
      } else if (result != null &&
          result!.format.name == 'qrcode' &&
          (result!.code!.startsWith('paysnap://payment?') &&
              result!.code!.contains('receiverId=') &&
              result!.code!.contains('receiverName=') &&
              result!.code!.contains('product=') &&
              result!.code!.contains('amount='))) {
        try {
          Uri uri = Uri.parse(result!.code!);
          String? amountString = uri.queryParameters['amount'];
          double amount = 0.0;
          if (amountString != null) {
            amount = double.parse(amountString);
          }
          if (amount <= 0) {
            throw Exception('Amount is not valid');
          }
        } catch (e) {
          if (!_isSnackbarActive) {
            _isSnackbarActive = true;
            scaffoldMessenger
                .showSnackBar(
                  SnackBar(
                      content: Text(translate(
                          'qr_scanner_screen.notification.amount_invalid'))),
                )
                .closed
                .then((_) => _isSnackbarActive = false);
          }
          return;
        }
        launchUrl(Uri.parse(result!.code!));
        dispose();
      } else {
        if (!_isSnackbarActive) {
          _isSnackbarActive = true;
          scaffoldMessenger
              .showSnackBar(
                SnackBar(
                    content: Text(translate(
                        'qr_scanner_screen.notification.wrong_qr_content'))),
              )
              .closed
              .then((_) => _isSnackbarActive = false);
        }
      }
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                translate('qr_scanner_screen.notification.no_permission'))),
      );
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    controller?.dispose();
    super.dispose();
  }

  void handleQrCode() {}
}
