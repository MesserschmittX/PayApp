import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'main.dart';

class SuccessPage extends StatelessWidget {
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Transfer'),
          automaticallyImplyLeading: false,
        ),
        body: Container(
          color: Color.fromARGB(255, 24, 26, 28),
          alignment: Alignment.center,
          child: Column(children: [
            Container(
              margin: EdgeInsets.all(100.0),
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                  color: Color.fromARGB(255, 38, 186, 68),
                  shape: BoxShape.circle,
                  border: Border.all(
                    width: 6,
                    color: Colors.white,
                  )),
              child: const Icon(
                Icons.check,
                size: 80,
                color: Colors.white,
              ),
            ),
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                child: Text("Zurück zu Home"),
                style: ElevatedButton.styleFrom(
                  primary: Color.fromARGB(255, 58, 127, 230),
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
