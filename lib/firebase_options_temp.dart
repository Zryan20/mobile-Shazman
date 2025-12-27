// File generated for Mobile Shazman
// Firebase configuration from Firebase Console

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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyDJVRvHt_W3orjkafkzLWukAU3_1077oY8',
    appId: '1:79610966616:web:YOUR_WEB_APP_ID',
    messagingSenderId: '79610966616',
    projectId: 'mobile-shazman',
    authDomain: 'mobile-shazman.firebaseapp.com',
    storageBucket: 'mobile-shazman.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDJVRvHt_W3orjkafkzLWukAU3_1077oY8',
    appId: '1:79610966616:android:cdbc0ca71c7edc0a4e502d',
    messagingSenderId: '79610966616',
    projectId: 'mobile-shazman',
    storageBucket: 'mobile-shazman.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey:
        'YOUR_IOS_API_KEY', // TODO: Replace with iOS API key from GoogleService-Info.plist
    appId: 'YOUR_IOS_APP_ID', // TODO: Replace with iOS app ID
    messagingSenderId: '79610966616',
    projectId: 'mobile-shazman',
    storageBucket: 'mobile-shazman.firebasestorage.app',
    iosBundleId: 'com.example.shazman',
  );
}
