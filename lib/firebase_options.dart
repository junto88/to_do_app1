import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: "API_KEY",
      authDomain: "to-do-app-8c01e.firebaseapp.com",
      projectId: "to-do-app-8c01e",
      storageBucket: "to-do-app-8c01e.appspot.com",
      messagingSenderId: "SENDER_ID",
      appId: "APP_ID",
      measurementId: "MEASUREMENT_ID",
    );
  }
}