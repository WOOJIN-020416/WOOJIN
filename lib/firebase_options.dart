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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB_ivbHnZYS-hrVPjRQwhyMLiSEOkY7qlU',
    appId: '1:750575846616:android:f6baad520f8322c43443ad',
    messagingSenderId: '750575846616',
    projectId: 'study-b2b03',
    storageBucket: 'study-b2b03.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA33K6kNaANadqwtxPKd4KIyIYS7ilrriE',
    appId: '1:750575846616:ios:c1bfd48e156a11153443ad',
    messagingSenderId: '750575846616',
    projectId: 'study-b2b03',
    storageBucket: 'study-b2b03.firebasestorage.app',
    iosBundleId: 'com.example.personality',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCmL6B2TeaLD7jOaLSYq3bxKA-wxm1C_nM',
    appId: '1:750575846616:web:3b702ee388fa4c7c3443ad',
    messagingSenderId: '750575846616',
    projectId: 'study-b2b03',
    authDomain: 'study-b2b03.firebaseapp.com',
    storageBucket: 'study-b2b03.firebasestorage.app',
    measurementId: 'G-SQPX0VW5ZS',
  );

}