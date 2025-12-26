// lib/services/assessment_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/exam_model.dart';

class AssessmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Check authentication before any operation
  Future<void> _checkAuthentication() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Authentication required. Please log in to access assessments.');
    }
  }

  // Get current user ID with authentication check
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  // Get current user with authentication check
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Generate mock questions
  static List<QuizQuestion> _generateMockQuestions() {
    return [
      // Programming Quizzes
      QuizQuestion(
        id: 'q1',
        question: 'What is the time complexity of binary search?',
        options: ['O(1)', 'O(log n)', 'O(n)', 'O(n²)'],
        correctAnswerIndex: 1,
        explanation: 'Binary search divides the search interval in half each time, resulting in O(log n) time complexity.',
        category: 'Algorithms',
        points: 10,
        type: 'quiz',
      ),
      QuizQuestion(
        id: 'q2',
        question: 'Which data structure uses LIFO (Last In First Out) principle?',
        options: ['Queue', 'Stack', 'Array', 'Linked List'],
        correctAnswerIndex: 1,
        explanation: 'Stack follows LIFO principle where the last element added is the first one to be removed.',
        category: 'Data Structures',
        points: 10,
        type: 'quiz',
      ),
      QuizQuestion(
        id: 'q3',
        question: 'What does HTTP stand for?',
        options: [
          'Hyper Text Transfer Protocol',
          'High Transfer Text Protocol',
          'Hyper Transfer Text Protocol',
          'High Text Transfer Protocol'
        ],
        correctAnswerIndex: 0,
        explanation: 'HTTP stands for Hyper Text Transfer Protocol, the foundation of data communication on the web.',
        category: 'Web Development',
        points: 10,
        type: 'quiz',
      ),

      // Coding Challenges
      QuizQuestion(
        id: 'cc1',
        question: 'Write a function to reverse a string in Dart.',
        options: [
          'Use built-in reverse() method',
          'Iterate from end to start',
          'Use split, reverse, join',
          'All of the above'
        ],
        correctAnswerIndex: 3,
        explanation: 'In Dart, you can use "string".split("").reversed.join("") or implement your own reversal logic.',
        category: 'Dart Programming',
        points: 15,
        type: 'coding',
        codeSnippet: 'String reverseString(String input) {\n  return input.split("").reversed.join("");\n}',
      ),
      QuizQuestion(
        id: 'cc2',
        question: 'What is the output of: print(5 ~/ 2); in Dart?',
        options: ['2.5', '2', '3', '2.0'],
        correctAnswerIndex: 1,
        explanation: 'The ~/ operator performs integer division, returning an integer result (2).',
        category: 'Dart Programming',
        points: 15,
        type: 'coding',
      ),

      // Mock Exam Questions
      QuizQuestion(
        id: 'me1',
        question: 'Which widget is used for responsive layouts in Flutter?',
        options: ['Container', 'Column', 'Row', 'All of the above'],
        correctAnswerIndex: 3,
        explanation: 'Flutter uses Container, Column, Row, and other layout widgets to create responsive UIs.',
        category: 'Flutter',
        points: 20,
        type: 'exam',
      ),
      QuizQuestion(
        id: 'me2',
        question: 'What is the purpose of pubspec.yaml in Flutter?',
        options: [
          'Define app dependencies',
          'Configure app metadata',
          'Both A and B',
          'Define app routes'
        ],
        correctAnswerIndex: 2,
        explanation: 'pubspec.yaml contains app metadata, dependencies, assets, and other configuration.',
        category: 'Flutter',
        points: 20,
        type: 'exam',
      ),
      QuizQuestion(
        id: 'me3',
        question: 'What is a StatefulWidget in Flutter?',
        options: [
          'A widget that never changes',
          'A widget with mutable state',
          'A widget for navigation',
          'A widget for HTTP requests'
        ],
        correctAnswerIndex: 1,
        explanation: 'StatefulWidget can change its state during runtime, unlike StatelessWidget.',
        category: 'Flutter',
        points: 20,
        type: 'exam',
      ),
      QuizQuestion(
        id: 'me4',
        question: 'How do you handle user input in Flutter?',
        options: [
          'Using TextField with controller',
          'Using GestureDetector',
          'Using Form widgets',
          'All of the above'
        ],
        correctAnswerIndex: 3,
        explanation: 'Flutter provides multiple ways to handle user input including TextField, GestureDetector, and Form widgets.',
        category: 'Flutter',
        points: 20,
        type: 'exam',
      ),
    ];
  }

  // Generate quiz sets
  static Map<String, dynamic> _generateQuizSets() {
    return {
      'programming_basics': {
        'id': 'quiz1',
        'name': 'Programming Basics Quiz',
        'type': 'quiz',
        'description': 'Test your programming fundamentals knowledge',
        'totalPoints': 100,
        'timeLimit': 600, // 10 minutes
        'questionIds': ['q1', 'q2', 'q3'],
        'category': 'Programming',
        'difficulty': 'Beginner',
      },
      'dart_challenges': {
        'id': 'quiz2',
        'name': 'Dart Coding Challenges',
        'type': 'coding',
        'description': 'Practice your Dart programming skills with real coding problems',
        'totalPoints': 150,
        'timeLimit': 900, // 15 minutes
        'questionIds': ['cc1', 'cc2'],
        'category': 'Dart',
        'difficulty': 'Intermediate',
      },
      'flutter_mock_exam': {
        'id': 'quiz3',
        'name': 'Flutter Certification Mock Exam',
        'type': 'exam',
        'description': 'Full-length Flutter certification practice test with timed questions',
        'totalPoints': 200,
        'timeLimit': 3600, // 60 minutes
        'questionIds': ['me1', 'me2', 'me3', 'me4'],
        'category': 'Flutter',
        'difficulty': 'Advanced',
      },
    };
  }

  // Initialize mock data in Firebase
  Future<void> initializeMockData() async {
    try {
      await _checkAuthentication();

      final questions = _generateMockQuestions();
      final quizzes = _generateQuizSets();

      // Upload questions to Firestore
      for (var question in questions) {
        await _firestore
            .collection('quiz_questions')
            .doc(question.id)
            .set(question.toMap());
      }

      // Upload quiz sets
      for (var quiz in quizzes.values) {
        await _firestore.collection('quizzes').doc(quiz['id']).set(quiz);
      }

      print('✅ Mock assessment data initialized successfully!');
    } catch (e) {
      print('❌ Error initializing mock data: $e');
      rethrow;
    }
  }

  // Get available quizzes (with authentication)
  Future<List<Map<String, dynamic>>> getAvailableQuizzes() async {
    try {
      await _checkAuthentication();

      final querySnapshot = await _firestore
          .collection('quizzes')
          .orderBy('difficulty')
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting quizzes: $e');
      return [];
    }
  }

  // Get quizzes by type (Stream version) - with authentication check
  Stream<List<Map<String, dynamic>>> getAssessmentsByType(String type) {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return Stream.value([]);
      }

      return _firestore
          .collection('quizzes')
          .where('type', isEqualTo: type)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
      });
    } catch (e) {
      print('Error in getAssessmentsByType stream: $e');
      return Stream.value([]);
    }
  }

  // Get quizzes by type (Future version) - with authentication
  Future<List<Map<String, dynamic>>> getQuizzesByType(String type) async {
    try {
      await _checkAuthentication();

      final querySnapshot = await _firestore
          .collection('quizzes')
          .where('type', isEqualTo: type)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting quizzes by type: $e');
      return [];
    }
  }

  // Get quiz questions (with authentication)
  Future<List<QuizQuestion>> getQuizQuestions(List<String> questionIds) async {
    try {
      await _checkAuthentication();

      List<QuizQuestion> questions = [];

      for (var id in questionIds) {
        final doc = await _firestore.collection('quiz_questions').doc(id).get();
        if (doc.exists) {
          questions.add(QuizQuestion.fromMap(doc.data()!));
        }
      }

      return questions;
    } catch (e) {
      print('Error getting questions: $e');
      return [];
    }
  }

  // Submit quiz result (FIXED - matches YOUR QuizResult model)
  Future<QuizResult> submitQuizResult({
    required String quizId,
    required String quizName,
    required String quizType,
    required List<Map<String, dynamic>> userAnswers,
    required int timeSpent, required int totalQuestions, String? userId, Map<String, dynamic>? details, List<Map<String, dynamic>>? questionResults,
  }) async {
    try {
      await _checkAuthentication();

      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Get quiz details
      final quizDoc = await _firestore.collection('quizzes').doc(quizId).get();
      if (!quizDoc.exists) {
        throw Exception('Quiz not found');
      }

      final quizData = quizDoc.data()!;
      final questionIds = List<String>.from(quizData['questionIds'] ?? []);

      // Get questions to validate answers
      final questions = await getQuizQuestions(questionIds);

      // Calculate score
      int correctAnswers = 0;
      int totalScore = 0;
      List<Map<String, dynamic>> questionResults = [];

      for (var i = 0; i < questions.length; i++) {
        final question = questions[i];
        final userAnswer = i < userAnswers.length ? userAnswers[i] : null;
        final isCorrect = userAnswer?['selectedIndex'] == question.correctAnswerIndex;

        if (isCorrect) {
          correctAnswers++;
          totalScore += question.points;
        }

        questionResults.add({
          'questionId': question.id,
          'question': question.question,
          'userAnswer': userAnswer?['selectedIndex'],
          'correctAnswer': question.correctAnswerIndex,
          'isCorrect': isCorrect,
          'points': question.points,
          'explanation': question.explanation,
        });
      }

      // Create result - EXACTLY matches YOUR QuizResult constructor
      final resultId = _firestore.collection('quiz_results').doc().id;
      final result = QuizResult(
        id: resultId,
        userId: user.uid,
        quizId: quizId,
        quizName: quizName,
        quizType: quizType,
        score: totalScore,
        totalQuestions: questions.length,
        correctAnswers: correctAnswers,
        timeSpent: timeSpent,
        completedAt: DateTime.now(),
        questionResults: questionResults,
      );

      // Save to Firestore in a batch operation
      final batch = _firestore.batch();

      // Save quiz result
      batch.set(
        _firestore.collection('quiz_results').doc(resultId),
        result.toMap(),
      );

      // Update user's completed quizzes
      final userRef = _firestore.collection('users').doc(user.uid);
      batch.update(userRef, {
        'completedQuizzes': FieldValue.arrayUnion([quizId]),
        'totalXP': FieldValue.increment(totalScore),
        'lastAssessmentDate': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      return result;
    } catch (e) {
      print('Error submitting quiz result: $e');
      rethrow;
    }
  }

  // Get user results for current user (Future version)
  Future<List<QuizResult>> getUserResults() async {
    try {
      await _checkAuthentication();

      final user = _auth.currentUser;
      if (user == null) return [];

      final querySnapshot = await _firestore
          .collection('quiz_results')
          .where('userId', isEqualTo: user.uid)
          .orderBy('completedAt', descending: true)
          .limit(50) // Limit to 50 most recent results
          .get();

      return querySnapshot.docs
          .map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return QuizResult.fromMap(data);
      })
          .toList();
    } catch (e) {
      print('Error getting user results: $e');
      return [];
    }
  }

  // Get user results for current user (Stream version)
  Stream<List<QuizResult>> getUserResultsStream() {
    try {
      final user = _auth.currentUser;
      if (user == null) return Stream.value([]);

      return _firestore
          .collection('quiz_results')
          .where('userId', isEqualTo: user.uid)
          .orderBy('completedAt', descending: true)
          .limit(20) // Stream only last 20 results for performance
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return QuizResult.fromMap(data);
        })
            .toList();
      });
    } catch (e) {
      print('Error in getUserResultsStream: $e');
      return Stream.value([]);
    }
  }

  // Get user results by userId (Stream version) - For admin/teacher view
  Stream<List<QuizResult>> getUserResultsByUserId(String userId) {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return Stream.value([]);

      return _firestore
          .collection('quiz_results')
          .where('userId', isEqualTo: userId)
          .orderBy('completedAt', descending: true)
          .limit(50)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return QuizResult.fromMap(data);
        })
            .toList();
      });
    } catch (e) {
      print('Error in getUserResultsByUserId: $e');
      return Stream.value([]);
    }
  }

  // Get quiz by ID (with authentication)
  Future<Map<String, dynamic>?> getQuizById(String quizId) async {
    try {
      await _checkAuthentication();

      final doc = await _firestore.collection('quizzes').doc(quizId).get();
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return data;
      }
      return null;
    } catch (e) {
      print('Error getting quiz by ID: $e');
      return null;
    }
  }

  // Check if user has completed a quiz
  Future<bool> hasUserCompletedQuiz(String quizId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final querySnapshot = await _firestore
          .collection('quiz_results')
          .where('userId', isEqualTo: user.uid)
          .where('quizId', isEqualTo: quizId)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking quiz completion: $e');
      return false;
    }
  }

  // Get user's best score for a quiz
  Future<int?> getUserBestScore(String quizId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final querySnapshot = await _firestore
          .collection('quiz_results')
          .where('userId', isEqualTo: user.uid)
          .where('quizId', isEqualTo: quizId)
          .orderBy('score', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.data()['score'];
      }
      return null;
    } catch (e) {
      print('Error getting best score: $e');
      return null;
    }
  }

  // Get leaderboard for a quiz
  Stream<List<Map<String, dynamic>>> getQuizLeaderboard(String quizId, {int limit = 10}) {
    try {
      return _firestore
          .collection('quiz_results')
          .where('quizId', isEqualTo: quizId)
          .orderBy('score', descending: true)
          .limit(limit)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'userId': data['userId'],
            'score': data['score'],
            'timeSpent': data['timeSpent'],
            'completedAt': data['completedAt'],
          };
        }).toList();
      });
    } catch (e) {
      print('Error getting leaderboard: $e');
      return Stream.value([]);
    }
  }
}