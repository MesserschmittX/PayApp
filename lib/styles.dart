import 'package:flutter/material.dart';

class Styles {
  static TextStyle linkText = const TextStyle(
      color: Styles.primaryColor,
      fontSize: 15,
      decoration: TextDecoration.underline);

  static TextStyle aboutHeadline =
      const TextStyle(fontSize: 25, fontWeight: FontWeight.bold);
  static TextStyle aboutText =
      const TextStyle(fontSize: 17, color: Colors.grey);

  static const Color primaryColor = Color.fromARGB(255, 5, 221, 249);
  static const Color secondaryColor = Color.fromARGB(255, 1, 49, 89);

  static double buttonHeight = 50;
  static double buttonWidth = 250;

  static Brightness currentBrightness = Brightness.light;
  static Function? changeBrightness;
}
