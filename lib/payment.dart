import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:paysnap/home.dart';
import 'package:paysnap/paypal_service.dart';
import 'package:paysnap/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'payment_data.dart';
import 'payment_success.dart';

class PaymentPage extends StatelessWidget {
  final PaymentData paymentData;
  PaymentPage(this.paymentData, {super.key});
  final FirebaseAuth auth = FirebaseAuth.instance;

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
                    child: Text(paymentData.receiverName),
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
                  Text("${paymentData.amount.toStringAsFixed(2)} €",
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
                  Map<String, dynamic> firestoreData = {
                    "receiverId": paymentData.receiverId,
                    "receiverName": paymentData.receiverName,
                    "senderId": auth.currentUser!.uid,
                    "senderName": auth.currentUser!.displayName,
                    "product": paymentData.product,
                    "amount": paymentData.amount,
                    "timestamp": DateTime.now(),
                  };
                  PaypalService().makePayment(paymentData.amount, (String msg) {
                    if (msg.startsWith("Order successful") ||
                        msg.startsWith("shipping change")) {
                      firestoreData['amount'] *= -1;
                      FirebaseFirestore.instance
                          .collection(
                              "/transfer/${auth.currentUser!.uid}/history")
                          .add(firestoreData)
                          .then((_) {})
                          .catchError((_) {
                        print(
                            "an error occurred while saving data to firestore");
                      });
                      firestoreData['amount'] *= -1;
                      FirebaseFirestore.instance
                          .collection(
                              "/transfer/${paymentData.receiverId}/history")
                          .add(firestoreData)
                          .then((_) {
                        print("makepayment then");
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const SuccessPage()));
                      }).catchError((_) {
                        debugPrint(
                            "an error occurred while saving data to firestore");
                      });
                      print("makepayment after");
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
