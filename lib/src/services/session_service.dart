import 'package:shared_preferences/shared_preferences.dart';
import '../models/session_model.dart';
import './firebase_service.dart';

class SessionService {
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  SessionService._internal();

  static const String _sessionKey = 'user_session';
  static const String _lastCourseKey = 'last_course';
  static const String _lastLessonKey = 'last_lesson';

  // Save session to local storage and Firebase
  Future<void> saveSession(UserSession session) async {
    try {
      // Save to local storage for quick access
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_sessionKey, session.toMap().toString());

      // Save to Firebase for cross-device sync
      await _saveSessionToFirebase(session);

      print('Session saved: ${session.lastActivityType} - ${session.lastActivityId}');
    } catch (e) {
      print('Error saving session: $e');
    }
  }

  // Load session from local storage
  Future<UserSession?> loadSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionString = prefs.getString(_sessionKey);

      if (sessionString != null) {
        final sessionMap = _parseSessionString(sessionString);
        final session = UserSession.fromMap(sessionMap);

        // Check if session is still valid
        if (session.isValid) {
          return session;
        } else {
          // Clear expired session
          await clearSession();
        }
      }

      return null;
    } catch (e) {
      print('Error loading session: $e');
      return null;
    }
  }

  // Save course progress
  Future<void> saveCourseProgress(String courseId, int lessonIndex, {Map<String, dynamic> additionalData = const {}}) async {
    final session = UserSession(
      userId: FirebaseService.currentUserId,
      lastActivityTime: DateTime.now(),
      lastActivityType: 'course',
      lastActivityId: courseId,
      lastLessonIndex: lessonIndex,
      activityData: {
        'courseProgress': additionalData,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );

    await saveSession(session);

    // Also save to local storage for quick access
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastCourseKey, courseId);
    await prefs.setInt(_lastLessonKey, lessonIndex);
  }

  // Save quiz progress
  Future<void> saveQuizProgress(String quizId, int currentQuestion, int totalQuestions) async {
    final session = UserSession(
      userId: FirebaseService.currentUserId,
      lastActivityTime: DateTime.now(),
      lastActivityType: 'quiz',
      lastActivityId: quizId,
      lastLessonIndex: currentQuestion,
      activityData: {
        'totalQuestions': totalQuestions,
        'progress': currentQuestion / totalQuestions,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );

    await saveSession(session);
  }

  // Save AI assistant session
  Future<void> saveAISession(String sessionId, String lastQuery, List<dynamic> conversationHistory) async {
    final session = UserSession(
      userId: FirebaseService.currentUserId,
      lastActivityTime: DateTime.now(),
      lastActivityType: 'ai_assistant',
      lastActivityId: sessionId,
      lastLessonIndex: 0,
      activityData: {
        'lastQuery': lastQuery,
        'conversationHistory': conversationHistory,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );

    await saveSession(session);
  }

  // Clear session
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    await prefs.remove(_lastCourseKey);
    await prefs.remove(_lastLessonKey);

    // Also clear from Firebase
    await _clearSessionFromFirebase();
  }

  // Get last course activity
  Future<Map<String, dynamic>?> getLastCourseActivity() async {
    final session = await loadSession();
    if (session != null && session.lastActivityType == 'course' && session.isValid) {
      return {
        'courseId': session.lastActivityId,
        'lessonIndex': session.lastLessonIndex,
        'activityData': session.activityData,
        'isRecent': session.isRecent,
      };
    }
    return null;
  }

  // Get last activity of any type
  Future<Map<String, dynamic>?> getLastActivity() async {
    final session = await loadSession();
    if (session != null && session.isValid) {
      return {
        'type': session.lastActivityType,
        'id': session.lastActivityId,
        'lessonIndex': session.lastLessonIndex,
        'activityData': session.activityData,
        'isRecent': session.isRecent,
        'timeAgo': _getTimeAgo(session.lastActivityTime),
      };
    }
    return null;
  }

  // Private methods
  Future<void> _saveSessionToFirebase(UserSession session) async {
    // Implementation for Firebase Firestore
    // await FirebaseFirestore.instance
    //   .collection('userSessions')
    //   .doc(session.userId)
    //   .set(session.toMap());
  }

  Future<void> _clearSessionFromFirebase() async {
    // Implementation for Firebase Firestore
    // await FirebaseFirestore.instance
    //   .collection('userSessions')
    //   .doc(FirebaseService.currentUserId)
    //   .delete();
  }

  Map<String, dynamic> _parseSessionString(String sessionString) {
    try {
      // Remove curly braces and split by commas
      final cleaned = sessionString.replaceAll('{', '').replaceAll('}', '');
      final pairs = cleaned.split(', ');

      final Map<String, dynamic> result = {};
      for (final pair in pairs) {
        final keyValue = pair.split(': ');
        if (keyValue.length == 2) {
          final key = keyValue[0].trim();
          var value = keyValue[1].trim();

          // Parse values appropriately
          if (value.startsWith("'") && value.endsWith("'")) {
            value = value.substring(1, value.length - 1);
          }

          // Handle different data types
          if (key == 'lastLessonIndex') {
            result[key] = int.tryParse(value) ?? 0;
          } else if (key == 'lastActivityTime') {
            result[key] = value;
          } else if (key == 'activityData') {
            result[key] = _parseActivityData(value);
          } else {
            result[key] = value;
          }
        }
      }
      return result;
    } catch (e) {
      print('Error parsing session string: $e');
      return {};
    }
  }

  Map<String, dynamic> _parseActivityData(String data) {
    try {
      if (data == '{}') return {};
      final cleaned = data.replaceAll('{', '').replaceAll('}', '');
      final pairs = cleaned.split(', ');

      final Map<String, dynamic> result = {};
      for (final pair in pairs) {
        final keyValue = pair.split(': ');
        if (keyValue.length == 2) {
          final key = keyValue[0].trim();
          var value = keyValue[1].trim();

          if (value.startsWith("'") && value.endsWith("'")) {
            value = value.substring(1, value.length - 1);
          }

          // Parse numeric values
          if (double.tryParse(value) != null) {
            result[key] = double.parse(value);
          } else if (int.tryParse(value) != null) {
            result[key] = int.parse(value);
          } else {
            result[key] = value;
          }
        }
      }
      return result;
    } catch (e) {
      print('Error parsing activity data: $e');
      return {};
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }
}