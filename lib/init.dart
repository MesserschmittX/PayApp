import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

class Init {
  static Future initialize() async {
    await _registerServices();
    await _loadSettings();
    await _initFirebase();
  }

  static _registerServices() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  static _loadSettings() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  static _initFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}
