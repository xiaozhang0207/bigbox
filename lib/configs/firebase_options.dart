import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
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
    apiKey: 'AIzaSyAcyPUW54x-4HnTlOHcWq0aSChSKn2172k',
    appId: '1:332285402769:android:52b79760211c21a8c76930',
    messagingSenderId: '332285402769',
    projectId: 'bigbox-f23f9',
    storageBucket: 'bigbox-f23f9.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA3ijPprrPjMRMZ_AOJ5mhIUfWB1-YsoMo',
    appId: '1:332285402769:ios:486b344eb0c16490c76930',
    messagingSenderId: '332285402769',
    projectId: 'bigbox-f23f9',
    storageBucket: 'bigbox-f23f9.appspot.com',
    androidClientId:
        '332285402769-1irjg84oli6f5iafplqak6gqfvkjri7b.apps.googleusercontent.com',
    iosBundleId: 'app.bigbox.infitech',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA3ijPprrPjMRMZ_AOJ5mhIUfWB1-YsoMo',
    appId: '1:332285402769:ios:486b344eb0c16490c76930',
    messagingSenderId: '332285402769',
    projectId: 'bigbox-f23f9',
    storageBucket: 'bigbox-f23f9.appspot.com',
    androidClientId:
        '332285402769-1irjg84oli6f5iafplqak6gqfvkjri7b.apps.googleusercontent.com',
    iosBundleId: 'app.bigbox.infitech',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDznDlIlQfg3o5woGHRRX1lKlbqvrvwtr8',
    appId: '1:332285402769:web:c622d43f05ab5384235f17',
    messagingSenderId: '332285402769',
    projectId: 'bigbox-f23f9',
    storageBucket: 'bigbox-f23f9.appspot.com',
    androidClientId:
        '332285402769-1irjg84oli6f5iafplqak6gqfvkjri7b.apps.googleusercontent.com',
    iosBundleId: 'app.bigbox.infitech',
    authDomain: 'bigbox-f23f9.firebaseapp.com',
  );
}
