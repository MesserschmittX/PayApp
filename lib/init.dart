import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

class Init {
  static Future initialize() async {
    await _registerServices();
    await _loadSettings();
    await _initFirebase();
  }

  static _registerServices() async {
    print("starting registering services");
    await Future.delayed(Duration(seconds: 1));
    print("finished registering services");
  }

  static _loadSettings() async {
    print("starting loading settings");
    await Future.delayed(Duration(seconds: 1));
    print("finished loading settings");
  }

  static _initFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}
