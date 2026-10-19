// File generated for Firebase project borrow-e7211
// Production configuration for Doodlio
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBgNJb4uARSLXr280-4le1cBmVsEFPvDIg',
    appId: '1:78640647949:android:5273b2689053fbba856a44',
    messagingSenderId: '78640647949',
    projectId: 'borrow-e7211',
    storageBucket: 'borrow-e7211.firebasestorage.app',
    databaseURL: 'https://borrow-e7211-default-rtdb.firebaseio.com',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBgNJb4uARSLXr280-4le1cBmVsEFPvDIg',
    appId: '1:78640647949:web:5273b2689053fbba856a44',
    messagingSenderId: '78640647949',
    projectId: 'borrow-e7211',
    storageBucket: 'borrow-e7211.firebasestorage.app',
    databaseURL: 'https://borrow-e7211-default-rtdb.firebaseio.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBgNJb4uARSLXr280-4le1cBmVsEFPvDIg',
    appId: '1:78640647949:ios:5273b2689053fbba856a44',
    messagingSenderId: '78640647949',
    projectId: 'borrow-e7211',
    storageBucket: 'borrow-e7211.firebasestorage.app',
    databaseURL: 'https://borrow-e7211-default-rtdb.firebaseio.com',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBgNJb4uARSLXr280-4le1cBmVsEFPvDIg',
    appId: '1:78640647949:ios:5273b2689053fbba856a44',
    messagingSenderId: '78640647949',
    projectId: 'borrow-e7211',
    storageBucket: 'borrow-e7211.firebasestorage.app',
    databaseURL: 'https://borrow-e7211-default-rtdb.firebaseio.com',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBgNJb4uARSLXr280-4le1cBmVsEFPvDIg',
    appId: '1:78640647949:web:5273b2689053fbba856a44',
    messagingSenderId: '78640647949',
    projectId: 'borrow-e7211',
    storageBucket: 'borrow-e7211.firebasestorage.app',
    databaseURL: 'https://borrow-e7211-default-rtdb.firebaseio.com',
  );
}

