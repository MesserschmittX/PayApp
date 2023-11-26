import 'package:flutter/material.dart';

class Styles {
  static TextStyle linkText = const TextStyle(
      color: Colors.blue, fontSize: 15, decoration: TextDecoration.underline);

  static Color primaryColor = Colors.blue;

  static Brightness currentBrightness = Brightness.light;
  static Function? changeBrightness;
}
