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

  // Initialize mock data
  Future<void> initializeMockData() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _assessmentService.initializeMockData();
      await loadQuizzes();

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
    required int timeSpent, required int totalQuestions, int? totalPoints,
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
      );

      // Refresh results
      await loadUserResults();

      _error = null;
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

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}