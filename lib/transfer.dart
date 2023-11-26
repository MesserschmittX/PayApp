import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:paysnap/home.dart';
import 'package:paysnap/paypal_service.dart';

import 'transfer_data.dart';
import 'transfer_success.dart';

class TransferPage extends StatelessWidget {
  TransferData transferData;
  TransferPage(this.transferData);

  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(translate("transfer_screen.title")),
          automaticallyImplyLeading: false,
        ),
        body: Container(
          alignment: Alignment.center,
          child: Column(children: [
            Padding(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "${translate("transfer_screen.recipient")}: ",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(transferData.product),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "${translate("transfer_screen.description")}: ",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(transferData.product),
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
                  Text("${transferData.amount} €",
                      style: const TextStyle(fontSize: 40))
                ],
              ),
            ),
            FilledButton(
              child: Text(translate("transfer_screen.transfer_button")),
              onPressed: () {
                PaypalService().makePayment(
                    transferData.amount,
                    (String msg) => {
                          if (msg.startsWith("Order successful") ||
                              msg.startsWith("shipping change"))
                            {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => SuccessPage()))
                            }
                        });
              },
            ),
            ElevatedButton(
              child: Text(translate("transfer_screen.cancel_button")),
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => HomePage()));
              },
            ),
          ]),
        ),
      );
}
