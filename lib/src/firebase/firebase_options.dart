import 'package:firebase_core/firebase_core.dart';
import 'firebase_constants.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: FirebaseConstants.androidApiKey,
      appId: FirebaseConstants.androidAppId,
      messagingSenderId: FirebaseConstants.messagingSenderId,
      projectId: FirebaseConstants.projectId,
    );
  }
}