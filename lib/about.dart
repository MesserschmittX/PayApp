import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

class AboutPage extends StatelessWidget {
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: Text(translate("about_screen.title"))),
      body: Column(
        children: [Text(translate('about_screen.description'))],
      ));
}
