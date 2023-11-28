import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:paysnap/styles.dart';

import 'home.dart';

class SuccessPage extends StatelessWidget {
  const SuccessPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(translate("payment_success_screen.title")),
          backgroundColor: Styles.primaryColor,
          foregroundColor: Styles.secondaryColor,
          automaticallyImplyLeading: false,
        ),
        body: Container(
          alignment: Alignment.center,
          child: Column(children: [
            Container(
              margin: const EdgeInsets.all(100.0),
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    width: 6,
                    color: Colors.green,
                  )),
              child: const Icon(
                Icons.check,
                size: 80,
              ),
            ),
            SizedBox(
              height: Styles.buttonHeight,
              width: Styles.buttonWidth,
              child: FilledButton(
                child: Text(translate("payment_success_screen.close_button")),
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
