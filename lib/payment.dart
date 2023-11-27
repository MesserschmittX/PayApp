import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:paysnap/home.dart';
import 'package:paysnap/paypal_service.dart';
import 'package:paysnap/styles.dart';

import 'payment_data.dart';
import 'payment_success.dart';

class PaymentPage extends StatelessWidget {
  final PaymentData paymentData;
  const PaymentPage(this.paymentData, {super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(translate("payment_screen.title")),
          automaticallyImplyLeading: false,
        ),
        body: Container(
          alignment: Alignment.center,
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "${translate("payment_screen.recipient")}: ",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(paymentData.product),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "${translate("payment_screen.description")}: ",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(paymentData.product),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(
                  top: 50, left: 100, right: 100, bottom: 50),
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    width: 6,
                    color: Theme.of(context).splashColor,
                  )),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("${paymentData.amount} €",
                      style: const TextStyle(fontSize: 40))
                ],
              ),
            ),
            SizedBox(
              height: Styles.buttonHeight,
              width: Styles.buttonWidth,
              child: FilledButton(
                child: Text(translate("payment_screen.payment_button")),
                onPressed: () {
                  PaypalService().makePayment(
                      paymentData.amount,
                      (String msg) => {
                            if (msg.startsWith("Order successful") ||
                                msg.startsWith("shipping change"))
                              {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => const SuccessPage()))
                              }
                          });
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 15),
              height: Styles.buttonHeight,
              width: Styles.buttonWidth,
              child: ElevatedButton(
                child: Text(translate("payment_screen.cancel_button")),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const HomePage()));
                },
              ),
            ),
          ]),
        ),
      );
}