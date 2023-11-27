// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // check translations for missing keys
    var de = jsonDecode(await rootBundle.loadString('assets/i18n/de.json'));
    var en = jsonDecode(await rootBundle.loadString('assets/i18n/en.json'));
    int counter = 0;
    counter = checkRecursiveMap(de, en, counter);
  });
}

int checkRecursiveMap(
    Map<String, dynamic> map, Map<String, dynamic> map2, int counter) {
  map.forEach((key, value) {
    counter++;
    expect(map2.containsKey(key), true);
    if (value is Map<String, dynamic>) {
      // Recursive call
      counter = checkRecursiveMap(map[key], map2[key], counter);
    }
  });
  return counter;
}
