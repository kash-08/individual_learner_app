import 'package:firebase_core/firebase_core.dart';
import 'firebase_constants.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // This will automatically work when built on iOS
    // For now, it defaults to Android
    return android;
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: FirebaseConstants.androidApiKey,
    appId: FirebaseConstants.androidAppId,
    messagingSenderId: FirebaseConstants.messagingSenderId,
    projectId: FirebaseConstants.projectId,
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: FirebaseConstants.iosApiKey,
    appId: FirebaseConstants.iosAppId,
    messagingSenderId: FirebaseConstants.messagingSenderId,
    projectId: FirebaseConstants.projectId,
    iosBundleId: FirebaseConstants.iosBundleId,
    iosClientId: FirebaseConstants.iosClientId,
  );
}