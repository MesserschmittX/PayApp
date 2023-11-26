import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_image_generator/qr_image_generator.dart';

class QRCreator extends StatefulWidget {
  const QRCreator({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRCreatorState();
}

class _QRCreatorState extends State<QRCreator> {
  Uint8List? qrBytes;
  final amountController = TextEditingController();
  final productController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(translate('qr_creator_screen.title'))),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 15),
              child: TextField(
                maxLength: 7,
                keyboardType: TextInputType.number,
                controller: amountController,
                onChanged: (value) async {},
                decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    suffixIcon: Icon(Icons.euro),
                    labelText: translate('qr_creator_screen.amount_label'),
                    hintText: translate('qr_creator_screen.amount_hint')),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 15),
              child: TextField(
                maxLength: 50,
                controller: productController,
                onChanged: (value) async {},
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: translate('qr_creator_screen.product_label'),
                  hintText: translate('qr_creator_screen.product_hint'),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 15.0, right: 15.0, top: 5, bottom: 10),
              child: FilledButton(
                child: Text(translate('qr_creator_screen.create_code_button')),
                onPressed: () async {
                  await _createQRCode();
                },
              ),
            ),
            _buildQrView(),
          ],
        ),
      ),
    );
  }

  Future _createQRCode() async {
    final generator = QRGenerator();

    String appDocPath = (await getApplicationDocumentsDirectory()).path;

    User? user = FirebaseAuth.instance.currentUser;
    double? amount = double.tryParse(amountController.text);
    String product = productController.text;

    String? errorMessage = _validateInput();

    if (errorMessage == null) {
      generator
          .generate(
        data:
            "paysnap://transfer?amount=$amount&product=$product&uid=${user!.uid}",
        filePath: '$appDocPath/qr.png',
      )
          .then((value) {
        setState(() {
          qrBytes = value;
        });
      });
    } else {
      _showSnackBar(errorMessage);
    }
  }

  String? _validateInput() {
    User? user = FirebaseAuth.instance.currentUser;
    double? amount = double.tryParse(amountController.text);
    String product = productController.text;

    if (user == null) {
      return translate('qr_creator_screen.error.no_user');
    }

    if (amountController.text.isEmpty) {
      return translate('qr_creator_screen.error.amount_empty');
    }

    if (amount == null) {
      return translate('qr_creator_screen.error.invalid_amount');
    }

    if (product.isEmpty) {
      return translate('qr_creator_screen.error.product_empty');
    }
    return null;
  }

  void _showSnackBar(String message) {
    final snackBar = SnackBar(
      content: Text(message),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Widget _buildQrView() {
    if (qrBytes != null && qrBytes!.isNotEmpty) {
      return Image.memory(qrBytes!, scale: .7);
    }
    return const Text("");
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    amountController.dispose();
    productController.dispose();
    super.dispose();
  }
}
