import 'dart:async'; // ADD THIS FOR Timer
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/exam_model.dart';
import '../services/firebase_service.dart';
import '../services/session_service.dart';

class ExamProvider with ChangeNotifier {
  List<Exam> _availableExams = [];
  List<Exam> _completedExams = [];
  List<CodingChallenge> _codingChallenges = [];
  List<UserChallengeProgress> _challengeProgress = [];
  List<ExamResult> _examResults = [];
  bool _isLoading = false;
  String? _error;
  Exam? _currentExam;
  List<Question> _currentQuestions = [];
  int _currentQuestionIndex = 0;
  Map<String, dynamic> _currentAnswers = {};
  Stopwatch _examStopwatch = Stopwatch();
  Timer? _examTimer; // ADD THIS FOR EXAM TIMER

  // Getter for current user ID
  String get currentUserId => FirebaseService.currentUserId;

  List<Exam> get availableExams => _availableExams;
  List<Exam> get completedExams => _completedExams;
  List<CodingChallenge> get codingChallenges => _codingChallenges;
  List<ExamResult> get examResults => _examResults;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Exam? get currentExam => _currentExam;
  List<Question> get currentQuestions => _currentQuestions;
  int get currentQuestionIndex => _currentQuestionIndex;
  int get totalQuestions => _currentQuestions.length;
  Map<String, dynamic> get currentAnswers => _currentAnswers;
  int get elapsedTime => _examStopwatch.elapsed.inSeconds;

  // Statistics
  Map<String, dynamic> get statistics {
    final completed = examResults.length;
    final passed = examResults.where((r) => r.passed).length;
    final avgScore = examResults.isEmpty ? 0 :
    examResults.map((r) => r.scorePercentage).reduce((a, b) => a + b) / examResults.length;

    return {
      'totalCompleted': completed,
      'passedExams': passed,
      'failedExams': completed - passed,
      'averageScore': avgScore,
      'totalTimeSpent': examResults.fold(0, (sum, r) => sum + r.timeTaken),
      'challengesCompleted': _challengeProgress.where((p) => p.completed).length,
      'totalChallenges': _codingChallenges.length,
    };
  }

  // ADD THIS METHOD: Save exam result (called from exam_taking_screen)
  Future<void> saveExamResult(ExamResult result) async {
    try {
      // Add to local list
      _examResults.insert(0, result);

      // Save to local storage
      await SessionService().saveExamResult(result);

      // Save to Firebase
      try {
        await FirebaseService.saveExamResult(result);
      } catch (e) {
        print('Failed to save to Firebase: $e');
      }

      notifyListeners();
      print('Exam result saved: ${result.examTitle}');
    } catch (e) {
      print('Error saving exam result: $e');
      rethrow;
    }
  }

  // ADD THIS METHOD: Get exam questions
  Future<List<Question>> getExamQuestions(String examId) async {
    try {
      print('Loading questions for exam: $examId');

      // Try Firebase first
      try {
        final questions = await FirebaseService.getExamQuestions(examId);
        if (questions.isNotEmpty) {
          print('Loaded ${questions.length} questions from Firebase');
          return questions;
        }
      } catch (e) {
        print('Failed to load from Firebase: $e');
      }

      // Fallback to mock questions
      return await _loadQuestionsForExam(examId);
    } catch (e) {
      print('Error getting exam questions: $e');
      return [];
    }
  }

  Future<void> loadExams() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('Loading exams and challenges...');

      // Try to load from Firebase
      try {
        await _loadFromFirebase();
      } catch (e) {
        print('Firebase loading failed: $e, loading mock data...');
        _loadMockData();
      }

      // Load user progress
      await _loadUserProgress();

    } catch (e) {
      _error = 'Failed to load exams: $e';
      print('Error loading exams: $e');
      _loadMockData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadFromFirebase() async {
    // Load exams from Firebase
    _availableExams = await FirebaseService.getAllExams();
    _examResults = await FirebaseService.getUserExamResults(currentUserId);

    print('Loaded ${_availableExams.length} exams and ${_examResults.length} results from Firebase');
  }

  void _loadMockData() {
    print('Loading mock exams and challenges...');

    // Mock Exams
    _availableExams = [
      Exam(
        id: 'exam_1',
        title: 'JavaScript Fundamentals Quiz',
        description: 'Test your knowledge of JavaScript basics',
        category: 'Web Development',
        difficulty: 'Beginner',
        totalQuestions: 10,
        timeLimit: 15,
        passingScore: 70.0,
        createdAt: DateTime(2024, 1, 1),
        tags: ['javascript', 'basics', 'quiz'],
        isActive: true,
        examType: 'quiz',
      ),
      Exam(
        id: 'exam_2',
        title: 'React Native Certification Mock',
        description: 'Practice exam for React Native certification',
        category: 'Mobile Development',
        difficulty: 'Intermediate',
        totalQuestions: 25,
        timeLimit: 60,
        passingScore: 75.0,
        createdAt: DateTime(2024, 1, 15),
        tags: ['react-native', 'mobile', 'certification'],
        isActive: true,
        examType: 'mock_exam',
      ),
      Exam(
        id: 'exam_3',
        title: 'Data Structures & Algorithms',
        description: 'Advanced algorithms and data structures questions',
        category: 'Computer Science',
        difficulty: 'Advanced',
        totalQuestions: 20,
        timeLimit: 45,
        passingScore: 80.0,
        createdAt: DateTime(2024, 2, 1),
        tags: ['algorithms', 'data-structures', 'cs'],
        isActive: true,
        examType: 'quiz',
      ),
      Exam(
        id: 'exam_4',
        title: 'Flutter Widgets Quiz',
        description: 'Test your Flutter widget knowledge',
        category: 'Mobile Development',
        difficulty: 'Intermediate',
        totalQuestions: 15,
        timeLimit: 20,
        passingScore: 70.0,
        createdAt: DateTime(2024, 2, 10),
        tags: ['flutter', 'widgets', 'ui'],
        isActive: true,
        examType: 'quiz',
      ),
    ];

    // Mock Coding Challenges
    _codingChallenges = [
      CodingChallenge(
        id: 'challenge_1',
        title: 'Reverse String',
        description: 'Write a function that reverses a string',
        difficulty: 'Easy',
        language: 'javascript',
        starterCode: 'function reverseString(str) {\n  // Your code here\n  return str;\n}',
        testCases: [
          TestCase(input: '"hello"', expectedOutput: '"olleh"'),
          TestCase(input: '"world"', expectedOutput: '"dlrow"'),
          TestCase(input: '"12345"', expectedOutput: '"54321"', isHidden: true),
        ],
        solution: 'function reverseString(str) {\n  return str.split("").reverse().join("");\n}',
        timeLimit: 10,
        points: 100,
        tags: ['strings', 'algorithms', 'easy'],
      ),
      CodingChallenge(
        id: 'challenge_2',
        title: 'Fibonacci Sequence',
        description: 'Generate the nth Fibonacci number',
        difficulty: 'Medium',
        language: 'python',
        starterCode: 'def fibonacci(n):\n    # Your code here\n    return 0',
        testCases: [
          TestCase(input: '5', expectedOutput: '5'),
          TestCase(input: '10', expectedOutput: '55'),
          TestCase(input: '20', expectedOutput: '6765', isHidden: true),
        ],
        solution: 'def fibonacci(n):\n    if n <= 1:\n        return n\n    return fibonacci(n-1) + fibonacci(n-2)',
        timeLimit: 15,
        points: 200,
        tags: ['recursion', 'math', 'medium'],
      ),
      CodingChallenge(
        id: 'challenge_3',
        title: 'Validate Parentheses',
        description: 'Check if a string of parentheses is valid',
        difficulty: 'Medium',
        language: 'javascript',
        starterCode: 'function isValidParentheses(s) {\n  // Your code here\n  return false;\n}',
        testCases: [
          TestCase(input: '"()"', expectedOutput: 'true'),
          TestCase(input: '"()[]{}"', expectedOutput: 'true'),
          TestCase(input: '"(]"', expectedOutput: 'false'),
          TestCase(input: '"([)]"', expectedOutput: 'false', isHidden: true),
        ],
        solution: 'function isValidParentheses(s) {\n  const stack = [];\n  const map = {\n    ")": "(",\n    "]": "[",\n    "}": "{"\n  };\n  \n  for (let char of s) {\n    if (!map[char]) {\n      stack.push(char);\n    } else if (stack.pop() !== map[char]) {\n      return false;\n    }\n  }\n  return stack.length === 0;\n}',
        timeLimit: 20,
        points: 250,
        tags: ['stack', 'strings', 'medium'],
      ),
    ];

    print('Mock data loaded: ${_availableExams.length} exams, ${_codingChallenges.length} challenges');
  }

  Future<void> _loadUserProgress() async {
    try {
      // Load from local storage
      final progressData = await SessionService().getUserExamProgress();
      if (progressData != null) {
        // Parse progress data
        // This would be your implementation
      }
    } catch (e) {
      print('Error loading user progress: $e');
    }
  }

  // Start an exam
  Future<void> startExam(String examId) async {
    try {
      _currentExam = _availableExams.firstWhere((exam) => exam.id == examId);
      _currentQuestions = await getExamQuestions(examId); // UPDATED: Use getExamQuestions method
      _currentQuestionIndex = 0;
      _currentAnswers.clear();
      _examStopwatch.reset();
      _examStopwatch.start();

      // Start exam timer
      _startExamTimer();

      notifyListeners();
    } catch (e) {
      _error = 'Failed to start exam: $e';
      notifyListeners();
      rethrow;
    }
  }

  // ADD THIS METHOD: Start exam timer
  void _startExamTimer() {
    _examTimer?.cancel();
    _examTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_examStopwatch.elapsed.inSeconds >= (_currentExam?.timeLimit ?? 60) * 60) {
        // Time's up, auto-submit
        timer.cancel();
        _autoSubmitExam();
      }
      notifyListeners();
    });
  }

  // ADD THIS METHOD: Auto-submit exam when timer expires
  void _autoSubmitExam() async {
    if (_currentExam == null || _currentQuestions.isEmpty) return;

    try {
      print('Auto-submitting exam: ${_currentExam!.title}');

      // Submit the exam using the existing submitExam method
      final result = await submitExam();

      print('Exam auto-submitted. Score: ${result.scorePercentage}%');

      // Show notification or handle auto-submission
      _error = 'Time\'s up! Exam has been auto-submitted.';
      notifyListeners();

    } catch (e) {
      print('Error auto-submitting exam: $e');
      _error = 'Error auto-submitting exam: $e';
      notifyListeners();
    }
  }

  Future<List<Question>> _loadQuestionsForExam(String examId) async {
    // Mock questions for now
    if (examId == 'exam_1') {
      return [
        Question(
          id: 'q1',
          examId: examId,
          questionText: 'What does "DOM" stand for in JavaScript?',
          questionType: 'multiple_choice',
          options: [
            'Document Object Model',
            'Data Object Management',
            'Digital Output Module',
            'Document Order Method',
          ],
          correctOptionIndex: 0,
          points: 10,
        ),
        Question(
          id: 'q2',
          examId: examId,
          questionText: 'Which keyword is used to declare a variable in JavaScript?',
          questionType: 'multiple_choice',
          options: [
            'var',
            'let',
            'const',
            'All of the above',
          ],
          correctOptionIndex: 3,
          points: 10,
        ),
        // Add more questions...
      ];
    }
    return [];
  }

  // Submit answer for current question
  void submitAnswer(dynamic answer) {
    final questionId = _currentQuestions[_currentQuestionIndex].id;
    _currentAnswers[questionId] = {
      'answer': answer,
      'timeSpent': _examStopwatch.elapsed.inSeconds,
    };

    if (_currentQuestionIndex < _currentQuestions.length - 1) {
      _currentQuestionIndex++;
    }

    notifyListeners();
  }

  // Navigate to specific question
  void goToQuestion(int index) {
    if (index >= 0 && index < _currentQuestions.length) {
      _currentQuestionIndex = index;
      notifyListeners();
    }
  }

  // Submit entire exam
  Future<ExamResult> submitExam() async {
    _examStopwatch.stop();
    _examTimer?.cancel(); // ADD THIS: Stop the timer

    try {
      // Calculate results
      final totalQuestions = _currentQuestions.length;
      int correctAnswers = 0;
      final Map<String, dynamic> detailedResults = {};

      for (final question in _currentQuestions) {
        final userAnswer = _currentAnswers[question.id];
        bool isCorrect = false;

        if (question.questionType == 'multiple_choice') {
          isCorrect = userAnswer?['answer'] == question.correctOptionIndex;
        } else if (question.questionType == 'coding') {
          // Evaluate code (simplified)
          isCorrect = await _evaluateCode(userAnswer?['answer'] ?? '', question.correctCode ?? '');
        }

        if (isCorrect) correctAnswers++;

        detailedResults[question.id] = {
          'question': question.questionText,
          'userAnswer': userAnswer?['answer'],
          'correctAnswer': question.correctOptionIndex,
          'isCorrect': isCorrect,
          'timeSpent': userAnswer?['timeSpent'] ?? 0,
        };
      }

      final scorePercentage = (correctAnswers / totalQuestions) * 100;
      final passed = scorePercentage >= (_currentExam?.passingScore ?? 70);

      // Create result
      final result = ExamResult(
        id: 'result_${DateTime.now().millisecondsSinceEpoch}',
        userId: currentUserId,
        examId: _currentExam?.id ?? '',
        examTitle: _currentExam?.title ?? '',
        completedAt: DateTime.now(),
        totalQuestions: totalQuestions,
        correctAnswers: correctAnswers,
        scorePercentage: scorePercentage,
        timeTaken: _examStopwatch.elapsed.inSeconds,
        passed: passed,
        detailedResults: detailedResults,
        examType: _currentExam?.examType ?? 'quiz',
      );

      // Save result using the new method
      await saveExamResult(result);

      // Reset exam state
      _currentExam = null;
      _currentQuestions.clear();
      _currentAnswers.clear();
      _examStopwatch.reset();

      notifyListeners();
      return result;

    } catch (e) {
      _error = 'Failed to submit exam: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> _evaluateCode(String userCode, String correctCode) async {
    // Simplified evaluation - in real app, use a code runner service
    // For now, just check if code is not empty
    return userCode.trim().isNotEmpty;
  }

  // Submit coding challenge
  Future<Map<String, dynamic>> submitCodingChallenge(
      String challengeId,
      String userCode,
      ) async {
    try {
      final challenge = _codingChallenges.firstWhere((c) => c.id == challengeId);

      // Run tests
      int passedTests = 0;
      int totalTests = challenge.testCases.length;
      final List<Map<String, dynamic>> testResults = [];

      for (final testCase in challenge.testCases) {
        // In real app, this would execute the code in a sandbox
        final passed = _runTest(userCode, testCase, challenge.language);
        if (passed) passedTests++;

        testResults.add({
          'input': testCase.input,
          'expected': testCase.expectedOutput,
          'passed': passed,
          'isHidden': testCase.isHidden,
        });
      }

      final score = (passedTests / totalTests) * 100;
      final passed = score >= 80; // 80% to pass

      // Update progress
      final progressIndex = _challengeProgress.indexWhere((p) => p.challengeId == challengeId);
      if (progressIndex >= 0) {
        final progress = _challengeProgress[progressIndex];
        _challengeProgress[progressIndex] = UserChallengeProgress(
          userId: progress.userId,
          challengeId: progress.challengeId,
          lastSubmittedCode: userCode,
          completed: passed || progress.completed,
          attempts: progress.attempts + 1,
          completedAt: passed && !progress.completed ? DateTime.now() : progress.completedAt,
          bestScore: score > progress.bestScore ? score : progress.bestScore,
          attemptHistory: [...progress.attemptHistory, DateTime.now()],
        );
      } else {
        _challengeProgress.add(UserChallengeProgress(
          userId: currentUserId,
          challengeId: challengeId,
          lastSubmittedCode: userCode,
          completed: passed,
          attempts: 1,
          completedAt: passed ? DateTime.now() : null,
          bestScore: score,
          attemptHistory: [DateTime.now()],
        ));
      }

      // Save progress
      await SessionService().saveChallengeProgress(_challengeProgress.last);

      notifyListeners();

      return {
        'passed': passed,
        'score': score,
        'passedTests': passedTests,
        'totalTests': totalTests,
        'testResults': testResults,
        'message': passed ? 'Challenge completed!' : 'Some tests failed. Try again!',
      };

    } catch (e) {
      _error = 'Failed to submit challenge: $e';
      notifyListeners();
      rethrow;
    }
  }

  bool _runTest(String userCode, TestCase testCase, String language) {
    // Simplified test runner
    // In real app, use a proper code execution service
    try {
      // Mock implementation
      if (language == 'javascript') {
        if (testCase.input == '"hello"' && testCase.expectedOutput == '"olleh"') {
          return userCode.contains('reverse');
        }
      } else if (language == 'python') {
        if (testCase.input == '5' && testCase.expectedOutput == '5') {
          return userCode.contains('fibonacci');
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Get user progress for a challenge
  UserChallengeProgress? getChallengeProgress(String challengeId) {
    try {
      return _challengeProgress.firstWhere((p) => p.challengeId == challengeId);
    } catch (e) {
      return null;
    }
  }

  // Get exam result by ID
  ExamResult? getExamResult(String examId) {
    try {
      return _examResults.firstWhere((r) => r.examId == examId);
    } catch (e) {
      return null;
    }
  }

  // Get leaderboard for an exam
  Future<List<Map<String, dynamic>>> getExamLeaderboard(String examId) async {
    // Mock leaderboard
    return [
      {
        'rank': 1,
        'name': 'Alex Johnson',
        'score': 98.5,
        'timeTaken': 425,
        'completedAt': DateTime.now().subtract(Duration(days: 1)),
      },
      {
        'rank': 2,
        'name': 'Sarah Chen',
        'score': 95.0,
        'timeTaken': 512,
        'completedAt': DateTime.now().subtract(Duration(days: 2)),
      },
      {
        'rank': 3,
        'name': 'You',
        'score': 88.0,
        'timeTaken': 680,
        'completedAt': DateTime.now().subtract(Duration(hours: 5)),
      },
    ];
  }

  // Reset provider state
  void reset() {
    _currentExam = null;
    _currentQuestions.clear();
    _currentAnswers.clear();
    _examStopwatch.reset();
    _examTimer?.cancel();
    notifyListeners();
  }

  // Clean up resources
  @override
  void dispose() {
    _examTimer?.cancel();
    super.dispose();
  }
}