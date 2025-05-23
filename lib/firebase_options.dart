// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCOYlTk0DvLT4PgB2rqIWNkjs4TU_IqREA',
    appId: '1:1020390356152:web:f2b4fe3a26af041447f04d',
    messagingSenderId: '1020390356152',
    projectId: 'shcrm-shinhan',
    authDomain: 'shcrm-shinhan.firebaseapp.com',
    storageBucket: 'shcrm-shinhan.appspot.com',
    measurementId: 'G-F54QL7TPV5',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBzhpmIpooYhHyqmVlr8W4GNQYaA3Zc2nQ',
    appId: '1:1020390356152:android:7ba04ce5e105627f47f04d',
    messagingSenderId: '1020390356152',
    projectId: 'shcrm-shinhan',
    storageBucket: 'shcrm-shinhan.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAtTal4B5PC4DmaRbYgvK0kB0DZ8eAhlKI',
    appId: '1:1020390356152:ios:ab4549891ab0e05747f04d',
    messagingSenderId: '1020390356152',
    projectId: 'shcrm-shinhan',
    storageBucket: 'shcrm-shinhan.appspot.com',
    iosBundleId: 'com.example.shcrm',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAtTal4B5PC4DmaRbYgvK0kB0DZ8eAhlKI',
    appId: '1:1020390356152:ios:ab4549891ab0e05747f04d',
    messagingSenderId: '1020390356152',
    projectId: 'shcrm-shinhan',
    storageBucket: 'shcrm-shinhan.appspot.com',
    iosBundleId: 'com.example.shcrm',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCOYlTk0DvLT4PgB2rqIWNkjs4TU_IqREA',
    appId: '1:1020390356152:web:824b45356c0e69e847f04d',
    messagingSenderId: '1020390356152',
    projectId: 'shcrm-shinhan',
    authDomain: 'shcrm-shinhan.firebaseapp.com',
    storageBucket: 'shcrm-shinhan.appspot.com',
    measurementId: 'G-LHTG080MTZ',
  );
}
