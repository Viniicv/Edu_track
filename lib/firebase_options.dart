import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

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
    apiKey: 'AIzaSyBjjToszg6kt4rUhmuMu771egLGcJEWB_A',
    appId: '1:543136728839:web:c6d25e882514756fb9e7a2',
    messagingSenderId: '543136728839',
    projectId: 'edutrack-edu',
    authDomain: 'edutrack-edu.firebaseapp.com',
    storageBucket: 'edutrack-edu.firebasestorage.app',
    measurementId: 'G-MRR4SYBCJ2',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyALFCqatIUyjN8WkucoiIynaEsJ1TI8QAg',
    appId: '1:543136728839:android:aed1aeec6d5ee740b9e7a2',
    messagingSenderId: '543136728839',
    projectId: 'edutrack-edu',
    storageBucket: 'edutrack-edu.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDn2P-Bi2UUBnN8fmwQLdw2uwzM7v6OIXE',
    appId: '1:543136728839:ios:2bbe302fd3a47388b9e7a2',
    messagingSenderId: '543136728839',
    projectId: 'edutrack-edu',
    storageBucket: 'edutrack-edu.firebasestorage.app',
    androidClientId: '543136728839-bc13rusf3vbl9oksu53vh2pdiq7cm9pl.apps.googleusercontent.com',
    iosClientId: '543136728839-jjk63822g6b5l39vmubhhhb24nt4ogbk.apps.googleusercontent.com',
    iosBundleId: 'com.example.eduTrack',
  );
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDn2P-Bi2UUBnN8fmwQLdw2uwzM7v6OIXE',
    appId: '1:543136728839:ios:2bbe302fd3a47388b9e7a2',
    messagingSenderId: '543136728839',
    projectId: 'edutrack-edu',
    storageBucket: 'edutrack-edu.firebasestorage.app',
    androidClientId: '543136728839-bc13rusf3vbl9oksu53vh2pdiq7cm9pl.apps.googleusercontent.com',
    iosClientId: '543136728839-jjk63822g6b5l39vmubhhhb24nt4ogbk.apps.googleusercontent.com',
    iosBundleId: 'com.example.eduTrack',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBjjToszg6kt4rUhmuMu771egLGcJEWB_A',
    appId: '1:543136728839:web:cee49b778263a478b9e7a2',
    messagingSenderId: '543136728839',
    projectId: 'edutrack-edu',
    authDomain: 'edutrack-edu.firebaseapp.com',
    storageBucket: 'edutrack-edu.firebasestorage.app',
    measurementId: 'G-348G05BJBQ',
  );
}
