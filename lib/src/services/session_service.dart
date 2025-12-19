import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/session_model.dart';
import '../models/exam_model.dart'; // ADD THIS IMPORT
import './firebase_service.dart';

class SessionService {
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  SessionService._internal();

  static const String _sessionKey = 'user_session';
  static const String _lastCourseKey = 'last_course';
  static const String _lastLessonKey = 'last_lesson';
  static const String _examResultsKey = 'exam_results'; // NEW
  static const String _challengeProgressKey = 'challenge_progress'; // NEW

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

  // NEW: Save exam result
  Future<void> saveExamResult(ExamResult result) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final examResultsKey = '${_examResultsKey}_${result.userId}';

      // Get existing results
      final existingResultsJson = prefs.getString(examResultsKey) ?? '[]';
      final existingResults = jsonDecode(existingResultsJson) as List;

      // Add new result
      final resultMap = {
        'id': result.id,
        'userId': result.userId,
        'examId': result.examId,
        'examTitle': result.examTitle,
        'completedAt': result.completedAt.toIso8601String(),
        'totalQuestions': result.totalQuestions,
        'correctAnswers': result.correctAnswers,
        'scorePercentage': result.scorePercentage,
        'timeTaken': result.timeTaken,
        'passed': result.passed,
        'detailedResults': result.detailedResults,
        'examType': result.examType,
      };

      existingResults.add(resultMap);

      // Save updated results (limit to last 50 results)
      final limitedResults = existingResults.length > 50
          ? existingResults.sublist(existingResults.length - 50)
          : existingResults;

      await prefs.setString(examResultsKey, jsonEncode(limitedResults));

      print('Exam result saved: ${result.examTitle} (${result.scorePercentage}%)');
    } catch (e) {
      print('Error saving exam result: $e');
      throw Exception('Failed to save exam result: $e');
    }
  }

  // NEW: Get user exam progress
  Future<List<Map<String, dynamic>>?> getUserExamProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = FirebaseService.currentUserId;
      final examResultsKey = '${_examResultsKey}_$userId';

      final resultsJson = prefs.getString(examResultsKey);
      if (resultsJson == null) return null;

      final results = jsonDecode(resultsJson) as List;
      return List<Map<String, dynamic>>.from(results);
    } catch (e) {
      print('Error getting user exam progress: $e');
      return null;
    }
  }

  // NEW: Save challenge progress
  Future<void> saveChallengeProgress(UserChallengeProgress progress) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final challengeProgressKey = '${_challengeProgressKey}_${progress.userId}';

      // Get existing progress
      final existingProgressJson = prefs.getString(challengeProgressKey) ?? '{}';
      final existingProgress = jsonDecode(existingProgressJson) as Map<String, dynamic>;

      // Update or add progress for this challenge
      existingProgress[progress.challengeId] = {
        'userId': progress.userId,
        'challengeId': progress.challengeId,
        'lastSubmittedCode': progress.lastSubmittedCode,
        'completed': progress.completed,
        'attempts': progress.attempts,
        'completedAt': progress.completedAt?.toIso8601String(),
        'bestScore': progress.bestScore,
        'attemptHistory': progress.attemptHistory.map((d) => d.toIso8601String()).toList(),
      };

      // Save updated progress
      await prefs.setString(challengeProgressKey, jsonEncode(existingProgress));

      print('Challenge progress saved for: ${progress.challengeId}');
    } catch (e) {
      print('Error saving challenge progress: $e');
      throw Exception('Failed to save challenge progress: $e');
    }
  }

  // NEW: Get challenge progress
  Future<Map<String, dynamic>?> getChallengeProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = FirebaseService.currentUserId;
      final challengeProgressKey = '${_challengeProgressKey}_$userId';

      final progressJson = prefs.getString(challengeProgressKey);
      if (progressJson == null) return null;

      final progress = jsonDecode(progressJson) as Map<String, dynamic>;
      return progress;
    } catch (e) {
      print('Error getting challenge progress: $e');
      return null;
    }
  }

  // NEW: Get specific challenge progress
  Future<Map<String, dynamic>?> getChallengeProgressById(String challengeId) async {
    try {
      final allProgress = await getChallengeProgress();
      if (allProgress == null || !allProgress.containsKey(challengeId)) {
        return null;
      }

      return allProgress[challengeId] as Map<String, dynamic>;
    } catch (e) {
      print('Error getting challenge progress by ID: $e');
      return null;
    }
  }

  // NEW: Get exam result by ID
  Future<Map<String, dynamic>?> getExamResultById(String examId) async {
    try {
      final allResults = await getUserExamProgress();
      if (allResults == null) return null;
      try {
        return allResults.cast<Map<String, dynamic>>().firstWhere(
              (result) => result['examId'] == examId,
        );
      } catch (e) {
        return null;
      }
    } catch (e) {
      print('Error getting exam result by ID: $e');
      return null;
    }
  }

  // NEW: Clear all exam data (for debugging)
  Future<void> clearExamData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = FirebaseService.currentUserId;

      await prefs.remove('${_examResultsKey}_$userId');
      await prefs.remove('${_challengeProgressKey}_$userId');

      print('All exam data cleared for user: $userId');
    } catch (e) {
      print('Error clearing exam data: $e');
    }
  }

  // NEW: Get user statistics
  Future<Map<String, dynamic>> getUserExamStatistics() async {
    try {
      final examResults = await getUserExamProgress() ?? [];
      final challengeProgress = await getChallengeProgress() ?? {};

      final completedExams = examResults.length;
      final passedExams = examResults.where((r) => r['passed'] == true).length;
      final avgScore = examResults.isEmpty ? 0 :
      examResults.map((r) => r['scorePercentage'] as double).fold(0.0, (sum, score) => sum + score) / completedExams;

      final completedChallenges = challengeProgress.values
          .where((p) => p['completed'] == true)
          .length;

      return {
        'totalExamsTaken': completedExams,
        'passedExams': passedExams,
        'failedExams': completedExams - passedExams,
        'averageScore': avgScore,
        'challengesCompleted': completedChallenges,
        'totalChallenges': challengeProgress.length,
      };
    } catch (e) {
      print('Error getting user exam statistics: $e');
      return {
        'totalExamsTaken': 0,
        'passedExams': 0,
        'failedExams': 0,
        'averageScore': 0,
        'challengesCompleted': 0,
        'totalChallenges': 0,
      };
    }
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
    try {
      // Comment out for now if not implemented
      // await FirebaseFirestore.instance
      //   .collection('userSessions')
      //   .doc(session.userId)
      //   .set(session.toMap());
    } catch (e) {
      print('Firebase session save error: $e');
    }
  }

  Future<void> _clearSessionFromFirebase() async {
    // Implementation for Firebase Firestore
    try {
      // await FirebaseFirestore.instance
      //   .collection('userSessions')
      //   .doc(FirebaseService.currentUserId)
      //   .delete();
    } catch (e) {
      print('Firebase session clear error: $e');
    }
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