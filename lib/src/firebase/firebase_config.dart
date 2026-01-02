// lib/config/firebase_config.dart
class FirebaseConfig {
  // Your Firebase project configuration
  // Get these from Firebase Console > Project Settings > General

  // For development/testing - you can hardcode these
  static const Map<String, dynamic> config = {
    'apiKey': "AIzaSyB6F-fEEghGd-CJzBLrMi3XHFxwiVl7Xuk",
    'authDomain': "individual-learner-app.firebaseapp.com",
    'projectId': "individual-learner-app",
    'storageBucket': "individual-learner-app.firebasestorage.app",
    'messagingSenderId': "118669659979",
    'appId': "1:118669659979:web:42288c065009f35a6aa2ce",
    'measurementId': "G-2GXEN4N4PE"
  };

  // AI Service configuration
  static const String aiModel = 'gemini-3-pro-preview';
  static const String region = 'us-central1';

  // Cloud Functions URLs
  static String get baseUrl => 'https://$region-${config['projectId']}.cloudfunctions.net';
  static String get aiAssistantUrl => '$baseUrl/aiAssistant';
  static String get healthCheckUrl => '$baseUrl/healthCheck';
  static String get guidedSolvingUrl => '$baseUrl/guidedSolving';
}