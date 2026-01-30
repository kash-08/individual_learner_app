import 'package:flutter/material.dart';
import '../services/assesment_service.dart';
import '../models/exam_model.dart';

class ExamProvider extends ChangeNotifier {
  final AssessmentService _assessmentService = AssessmentService();

  List<Map<String, dynamic>> _quizzes = [];
  List<QuizResult> _userResults = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get quizzes => _quizzes;
  List<QuizResult> get userResults => _userResults;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Method to get completed assessments in Map format
  List<Map<String, dynamic>> getCompletedAssessments() {
    return _userResults.map((result) {
      return {
        'quizId': result.quizId,
        'quizName': result.quizName,
        'quizType': result.quizType,
        'score': result.score,
        'percentage': result.percentage,
        'timeSpent': result.timeSpent,
        'completedAt': result.completedAt.toIso8601String(),
        'totalQuestions': result.totalQuestions,
        'correctAnswers': result.correctAnswers,
        'wrongAnswers': result.totalQuestions - result.correctAnswers, // Calculate wrong answers
        'totalPoints': result.totalQuestions * 10, // Assuming 10 points per question
        'grade': result.grade,
        'userId': result.userId,
      };
    }).toList();
  }

  // Get completed count for statistics
  int getCompletedCount() {
    return _userResults.length;
  }

  // Get average score
  double getAverageScore() {
    if (_userResults.isEmpty) return 0.0;
    final totalScore = _userResults.fold<double>(0.0, (sum, result) => sum + result.percentage);
    return totalScore / _userResults.length;
  }

  // Get average grade
  String getAverageGrade() {
    if (_userResults.isEmpty) return 'N/A';
    final avgScore = getAverageScore();
    if (avgScore >= 90) return 'A';
    if (avgScore >= 80) return 'B';
    if (avgScore >= 70) return 'C';
    if (avgScore >= 60) return 'D';
    return 'F';
  }

  // Initialize mock data
  Future<void> initializeMockData() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _assessmentService.initializeMockData();
      await loadQuizzes();
      await loadUserResults();

      _error = null;
    } catch (e) {
      _error = 'Failed to initialize mock data: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load available quizzes
  Future<void> loadQuizzes() async {
    try {
      _isLoading = true;
      notifyListeners();

      _quizzes = await _assessmentService.getAvailableQuizzes();
      _error = null;
    } catch (e) {
      _error = 'Failed to load quizzes: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load quizzes by type
  Future<List<Map<String, dynamic>>> loadQuizzesByType(String type) async {
    try {
      return await _assessmentService.getQuizzesByType(type);
    } catch (e) {
      print('Error loading quizzes by type: $e');
      return [];
    }
  }

  // Get quiz questions
  Future<List<QuizQuestion>> getQuizQuestions(String quizId) async {
    try {
      final quiz = await _assessmentService.getQuizById(quizId);
      if (quiz != null && quiz['questionIds'] != null) {
        return await _assessmentService.getQuizQuestions(
          List<String>.from(quiz['questionIds']),
        );
      }
      return [];
    } catch (e) {
      print('Error getting quiz questions: $e');
      return [];
    }
  }

  // Submit quiz
  Future<QuizResult> submitQuiz({
    required String quizId,
    required String quizName,
    required String quizType,
    required List<Map<String, dynamic>> userAnswers,
    required int timeSpent,
    required int totalQuestions,
    String? userId,
    Map<String, dynamic>? details,
    List<Map<String, dynamic>>? questionResults, int? totalPoints, required String difficulty,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await _assessmentService.submitQuizResult(
        quizId: quizId,
        quizName: quizName,
        quizType: quizType,
        userAnswers: userAnswers,
        timeSpent: timeSpent,
        totalQuestions: totalQuestions,
        userId: userId,
        details: details,
        questionResults: questionResults,
      );

      // Add to local results
      _userResults.add(result);
      _userResults.sort((a, b) => b.completedAt.compareTo(a.completedAt));

      _error = null;
      notifyListeners();
      return result;
    } catch (e) {
      _error = 'Failed to submit quiz: $e';
      print(_error);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load user results
  Future<void> loadUserResults() async {
    try {
      _isLoading = true;
      notifyListeners();

      _userResults = await _assessmentService.getUserResults();
      _userResults.sort((a, b) => b.completedAt.compareTo(a.completedAt));

      _error = null;
    } catch (e) {
      _error = 'Failed to load results: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get quiz by ID
  Future<Map<String, dynamic>?> getQuizById(String quizId) async {
    return await _assessmentService.getQuizById(quizId);
  }

  // Get result by quiz ID
  QuizResult? getResultByQuizId(String quizId) {
    try {
      return _userResults.firstWhere(
            (result) => result.quizId == quizId,
      );
    } catch (e) {
      return null;
    }
  }

  // Check if quiz is completed
  bool isQuizCompleted(String quizId) {
    return _userResults.any((result) => result.quizId == quizId);
  }

  // Get latest results (limit to recent ones)
  List<QuizResult> getLatestResults({int limit = 5}) {
    return _userResults.take(limit).toList();
  }

  // Get results by type
  List<QuizResult> getResultsByType(String type) {
    return _userResults
        .where((result) => result.quizType.toLowerCase() == type.toLowerCase())
        .toList();
  }

  // Get results by date range
  List<QuizResult> getResultsByDateRange(DateTime startDate, DateTime endDate) {
    return _userResults
        .where((result) =>
    result.completedAt.isAfter(startDate) &&
        result.completedAt.isBefore(endDate)
    )
        .toList();
  }

  // Get today's results
  List<QuizResult> getTodaysResults() {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final tomorrowStart = todayStart.add(const Duration(days: 1));

    return getResultsByDateRange(todayStart, tomorrowStart);
  }

  // Get this week's results
  List<QuizResult> getThisWeeksResults() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final endDate = startDate.add(const Duration(days: 7));

    return getResultsByDateRange(startDate, endDate);
  }

  // Calculate performance statistics
  Map<String, dynamic> getPerformanceStats() {
    if (_userResults.isEmpty) {
      return {
        'totalAssessments': 0,
        'averageScore': 0.0,
        'averageGrade': 'N/A',
        'totalTimeSpent': 0,
        'totalCorrect': 0,
        'totalQuestions': 0,
        'successRate': 0.0,
      };
    }

    final totalTimeSpent = _userResults.fold(0, (sum, result) => sum + result.timeSpent);
    final totalCorrect = _userResults.fold(0, (sum, result) => sum + result.correctAnswers);
    final totalQuestions = _userResults.fold(0, (sum, result) => sum + result.totalQuestions);
    final successRate = totalQuestions > 0 ? (totalCorrect / totalQuestions) * 100 : 0.0;

    return {
      'totalAssessments': _userResults.length,
      'averageScore': getAverageScore(),
      'averageGrade': getAverageGrade(),
      'totalTimeSpent': totalTimeSpent,
      'totalCorrect': totalCorrect,
      'totalQuestions': totalQuestions,
      'successRate': successRate,
    };
  }

  // Clear all results (for testing)
  Future<void> clearResults() async {
    _userResults.clear();
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}