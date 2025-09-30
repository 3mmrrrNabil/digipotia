import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // ⚡ Android (من google-services.json)
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyDJw2DNaNZWehnXau_-KyMGTRStQHWzQKU",
    appId: "1:879020852601:android:1fc938862288fbd1091ba8",
    messagingSenderId: "879020852601",
    projectId: "digitopia-b73a7",
    storageBucket: "digitopia-b73a7.firebasestorage.app",
  );

  // ⚡ Web (محتاج تجيب config من Firebase Console > Web app)
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "ضع هنا الـ apiKey بتاع Web",
    appId: "ضع هنا الـ appId بتاع Web",
    messagingSenderId: "ضع هنا الـ messagingSenderId بتاع Web",
    projectId: "digitopia-b73a7",
    authDomain: "digitopia-b73a7.firebaseapp.com",
    storageBucket: "digitopia-b73a7.firebasestorage.app",
    measurementId: "ضع هنا الـ measurementId لو متاح",
  );
}