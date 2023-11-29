import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:path_provider/path_provider.dart';
import 'package:paysnap/styles.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_image_generator/qr_image_generator.dart';

class QRCreator extends StatefulWidget {
  const QRCreator({super.key});

  @override
  State<StatefulWidget> createState() => _QRCreatorState();
}

class _QRCreatorState extends State<QRCreator> {
  Uint8List? qrBytes;
  final amountController = TextEditingController();
  final productController = TextEditingController();
  bool _createEnabled = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(translate('qr_creator_screen.title')),
        backgroundColor: Styles.primaryColor,
        foregroundColor: Styles.secondaryColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                  left: 15.0, right: 15.0, top: 20, bottom: 10),
              child: TextField(
                maxLength: 50,
                controller: productController,
                onChanged: (value) {
                  updateCreateState();
                },
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: translate('qr_creator_screen.product_label'),
                  hintText: translate('qr_creator_screen.product_hint'),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 15.0),
              child: TextField(
                maxLength: 7,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                controller: amountController,
                onChanged: (value) {
                  updateCreateState();
                },
                decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    suffixIcon: const Icon(Icons.euro),
                    labelText: translate('qr_creator_screen.amount_label'),
                    hintText: translate('qr_creator_screen.amount_hint')),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 15.0, right: 15.0, top: 2, bottom: 10),
              child: SizedBox(
                height: Styles.buttonHeight,
                width: Styles.buttonWidth,
                child: FilledButton(
                  onPressed: !_createEnabled
                      ? null
                      : () async => await _createQRCode(),
                  child:
                      Text(translate('qr_creator_screen.create_code_button')),
                ),
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
    double? amount =
        double.tryParse(amountController.text.replaceAll(',', '.'));
    String product = productController.text;

    String? errorMessage = _validateInput();

    if (errorMessage == null) {
      generator
          .generate(
        data:
            "paysnap://payment?receiverId=${user!.uid}&receiverName=${user.displayName}&product=$product&amount=$amount",
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
    String amountInputFormatted = amountController.text.replaceAll(',', '.');
    double? amount = double.tryParse(amountInputFormatted);

    if (user == null) {
      return translate('qr_creator_screen.error.no_user');
    }

    if (amount == null) {
      return translate('qr_creator_screen.error.invalid_amount');
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
      return Column(children: [
        Padding(
            padding: const EdgeInsets.only(
                left: 15.0, right: 15.0, top: 10, bottom: 10),
            child: Image.memory(qrBytes!, scale: .8)),
        Padding(
          padding: const EdgeInsets.only(
              left: 15.0, right: 15.0, top: 10, bottom: 10),
          child: SizedBox(
            height: Styles.buttonHeight,
            width: Styles.buttonWidth,
            child: ElevatedButton(
              child: Text(translate('qr_creator_screen.print_code_button')),
              onPressed: () async {
                final doc = pw.Document();
                final qrImage = pw.MemoryImage(qrBytes!);
                final paypalLogo =
                    await rootBundle.load('assets/images/PayPal.png');
                final paysnapLogo = await rootBundle
                    .load('assets/images/paysnap_loginLogo.png');
                final imageBytesPayPal = paypalLogo.buffer.asUint8List();
                final paypalLogoImage = pw.MemoryImage(imageBytesPayPal);
                final imageBytesPaySnap = paysnapLogo.buffer.asUint8List();
                final paysnapLogoImage = pw.MemoryImage(imageBytesPaySnap);
                const pw.TextStyle textStyle =
                    pw.TextStyle(fontSize: 10, color: PdfColors.white);

                doc.addPage(pw.Page(
                    pageFormat: PdfPageFormat.a6,
                    theme: pw.ThemeData.withFont(
                      base: await PdfGoogleFonts.openSansRegular(),
                      bold: await PdfGoogleFonts.openSansBold(),
                      icons: await PdfGoogleFonts.materialIcons(),
                    ),
                    build: (pw.Context context) {
                      return pw.Container(
                        decoration: pw.BoxDecoration(
                          gradient: pw.LinearGradient(
                            begin: pw.Alignment.topCenter,
                            end: pw.Alignment.bottomCenter,
                            colors: [
                              PdfColor.fromRYB(1, 32, 89),
                              PdfColor.fromRYB(5, 221, 249)
                            ],
                          ),
                        ),
                        child: pw.Padding(
                          padding: const pw.EdgeInsets.only(
                              left: 15, right: 15, top: 15),
                          child: pw.Column(children: [
                            pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.end,
                              children: [
                                pw.Align(
                                    alignment: pw.Alignment.centerRight,
                                    child:
                                        pw.Image(paysnapLogoImage, width: 100)),
                              ],
                            ),
                            pw.Column(
                                mainAxisAlignment: pw.MainAxisAlignment.start,
                                children: [
                                  pw.Align(
                                    alignment: pw.Alignment.centerLeft,
                                    child: pw.Text(
                                        '${translate('qr_creator_screen.product_label')}:',
                                        style: textStyle),
                                  ),
                                  pw.Align(
                                    alignment: pw.Alignment.centerLeft,
                                    child: pw.Text(productController.text,
                                        style: textStyle),
                                  ),
                                  pw.Align(
                                    alignment: pw.Alignment.centerLeft,
                                    child: pw.Text(
                                        '${translate('qr_creator_screen.amount_label')}:',
                                        style: textStyle),
                                  ),
                                  pw.Align(
                                    alignment: pw.Alignment.centerLeft,
                                    child: pw.Text('${amountController.text} €',
                                        style: textStyle),
                                  ),
                                ]),
                            pw.Padding(
                                padding: const pw.EdgeInsets.only(top: 40),
                                child:
                                    pw.Image(qrImage, width: 100, height: 100)),
                            pw.Padding(
                                padding: const pw.EdgeInsets.only(top: 40),
                                child: pw.Image(paypalLogoImage, width: 100))
                          ]),
                        ),
                      ); // Center
                    })); // Page
                await Printing.layoutPdf(
                    onLayout: (PdfPageFormat format) async => doc.save());
              },
            ),
          ),
        ),
      ]);
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

  void updateCreateState() {
    setState(() {
      // Update button state based on input fields
      _createEnabled =
          amountController.text.isNotEmpty && productController.text.isNotEmpty;
    });
  }
}
