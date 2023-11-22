import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:payapp/paypal_service.dart';

import 'main.dart';
import 'transfer_success.dart';

class TransferPage extends StatelessWidget {
  double price = 7;
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Transfer'),
          automaticallyImplyLeading: false,
        ),
        body: Container(
          color: Color.fromARGB(255, 24, 26, 28),
          alignment: Alignment.center,
          child: Column(children: [
            Row(
              children: [
                Text(
                  "Empfänger/in",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                SizedBox(width: 50),
                Text(
                  "Testempfängerin",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                )
              ],
            ),
            Row(
              children: [
                Text(
                  "Grund",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                SizedBox(width: 50),
                Text(
                  "Testgrund",
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
                    price.toStringAsFixed(2),
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
                child: Text("Jetzt überweisen"),
                style: ElevatedButton.styleFrom(
                  primary: Color.fromARGB(255, 48, 228, 45),
                  elevation: 0,
                ),
                onPressed: () {
                  PaypalService().makePayment(
                      price,
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
                child: Text("Abbrechen"),
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
