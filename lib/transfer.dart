import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:paysnap/home.dart';
import 'package:paysnap/paypal_service.dart';

import 'main.dart';
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
          color: Color.fromARGB(255, 24, 26, 28),
          alignment: Alignment.center,
          child: Column(children: [
            Row(
              children: [
                Text(
                  translate("transfer_screen.recipient"),
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                SizedBox(width: 50),
                Text(
                  transferData.uid,
                  style: TextStyle(color: Colors.white, fontSize: 20),
                )
              ],
            ),
            Row(
              children: [
                Text(
                  translate("transfer_screen.description"),
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                SizedBox(width: 50),
                Text(
                  transferData.product,
                  style: TextStyle(color: Colors.white, fontSize: 20),
                )
              ],
            ),
            Container(
              margin: EdgeInsets.all(100.0),
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Colors.blue,
                      Colors.red,
                    ],
                  ),
                  color: Color.fromARGB(255, 38, 186, 68),
                  shape: BoxShape.circle,
                  border: Border.all(
                    width: 6,
                    color: Colors.white,
                  )),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    transferData.amount.toString(),
                    style: TextStyle(color: Colors.white, fontSize: 30),
                  ),
                  SizedBox(width: 10),
                  Text(
                    "€",
                    style: TextStyle(color: Colors.white, fontSize: 30),
                  )
                ],
              ),
            ),
            //Image.asset('assets/images/PayPal.png'),
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                child: Text(translate("transfer_screen.transfer_button")),
                style: ElevatedButton.styleFrom(
                  primary: Color.fromARGB(255, 48, 228, 45),
                  elevation: 0,
                ),
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
            ),
            SizedBox(
              width: 160,
              height: 50,
              child: ElevatedButton(
                child: Text(translate("transfer_screen.cancel_button")),
                style: ElevatedButton.styleFrom(
                  primary: Color.fromARGB(255, 163, 157, 157),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => HomePage()));
                },
              ),
            ),
          ]),
        ),
      );
}
