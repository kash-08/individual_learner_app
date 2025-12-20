// lib/services/firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../models/course_model.dart';
import '../models/user_model.dart';
import '../models/update_model.dart';
import '../models/exam_model.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Track Firebase initialization status
  static bool _isFirebaseInitialized = true;

  // Get current user ID (for demo, use a fixed ID)
  static String get currentUserId {
    return _auth.currentUser?.uid ?? 'demo-user-123';
  }

  // ========================================================================
  // MAIN INITIALIZATION - Call this in main.dart
  // ========================================================================

  /// Initialize ALL sample data (courses, exams, weekly updates, assessments from JSON)
  static Future<void> initializeSampleData() async {
    try {
      print('🚀 Initializing all sample data...');
      print('=' * 60);

      // Initialize courses
      await _initializeCourses();

      // Initialize weekly updates
      await initializeWeeklyUpdates();

      // Initialize exams data
      await initializeExamsData();

      // NEW: Initialize assessments from JSON file
      await initializeAssessmentsFromJson();

      print('');
      print('=' * 60);
      print('✅ All sample data initialized successfully!');
    } catch (e) {
      print('❌ Error initializing sample data: $e');
    }
  }

  // ========================================================================
  // ASSESSMENTS FROM JSON FILE - NEW METHOD
  // ========================================================================

  /// Load assessments from JSON file and create in Firestore
  static Future<void> initializeAssessmentsFromJson() async {
    try {
      print('');
      print('📖 Loading assessments from JSON file...');

      // Check if assessments already exist
      final assessmentsSnapshot = await _firestore.collection('assessments').limit(1).get();
      if (assessmentsSnapshot.docs.isNotEmpty) {
        print('✅ Assessments already exist in database, skipping...');
        return;
      }

      // Load JSON file from assets
      final jsonString = await rootBundle.loadString('firebase_sample_data.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      if (!jsonData.containsKey('assessments')) {
        print('⚠️ No assessments found in JSON file');
        return;
      }

      final assessmentsMap = jsonData['assessments'] as Map<String, dynamic>;

      int successCount = 0;
      int errorCount = 0;
      int totalQuestions = 0;

      print('📝 Processing ${assessmentsMap.length} assessments from JSON...');

      for (final entry in assessmentsMap.entries) {
        final assessmentId = entry.key;
        final assessmentData = entry.value as Map<String, dynamic>;

        try {
          // Extract questions
          final questions = assessmentData['questions'] as List<dynamic>? ?? [];
          totalQuestions += questions.length;

          // Prepare assessment document (without questions)
          final docData = {
            'title': assessmentData['title'],
            'description': assessmentData['description'],
            'type': assessmentData['type'],
            'category': assessmentData['category'],
            'difficulty': assessmentData['difficulty'],
            'timeLimit': assessmentData['duration'] ?? assessmentData['timeLimit'] ?? 30,
            'totalQuestions': assessmentData['totalQuestions'] ?? questions.length,
            'passingScore': (assessmentData['passingScore'] ?? 70).toDouble(),
            'pointsPerQuestion': assessmentData['pointsPerQuestion'] ?? 10,
            'tags': assessmentData['tags'] ?? [],
            'isActive': assessmentData['isActive'] ?? true,
            'createdAt': FieldValue.serverTimestamp(),
          };

          // Add assessment document to Firestore
          final docRef = await _firestore.collection('assessments').add(docData);

          // Add questions as subcollection
          int questionOrder = 1;
          for (final question in questions) {
            final questionData = {
              'questionText': question['questionText'],
              'options': question['options'] ?? [],
              'correctAnswer': question['correctAnswerIndex'] ?? question['correctAnswer'] ?? 0,
              'explanation': question['explanation'],
              'points': question['points'] ?? 10,
              'order': questionOrder++,
              'codeTemplate': question['codeTemplate'],
              'testCases': question['testCases'] ?? [],
            };

            await docRef.collection('questions').add(questionData);
          }

          successCount++;
          print('  ✅ ${assessmentData['title']} (${questions.length} questions)');
        } catch (e) {
          errorCount++;
          print('  ❌ Error creating $assessmentId: $e');
        }
      }

      print('');
      print('📊 Assessments Summary:');
      print('   ✅ Created: $successCount assessments');
      print('   📝 Total questions: $totalQuestions');
      if (errorCount > 0) print('   ❌ Errors: $errorCount');
    } catch (e) {
      print('');
      print('❌ Error loading assessments from JSON: $e');
      print('');
      print('⚠️  TROUBLESHOOTING:');
      print('   1. Make sure firebase_sample_data.json is in your project root');
      print('   2. Add it to pubspec.yaml under assets:');
      print('      assets:');
      print('        - firebase_sample_data.json');
      print('   3. Run: flutter pub get');
      print('   4. Restart the app');
    }
  }

  // ========================================================================
  // COURSES INITIALIZATION
  // ========================================================================

  static Future<void> _initializeCourses() async {
    try {
      // Check if courses already exist
      final coursesSnapshot = await _firestore.collection('courses').get();
      if (coursesSnapshot.docs.isNotEmpty) {
        print('Courses already exist, skipping initialization');
        return;
      }

      // Sample courses data
      final sampleCourses = [
        {
          'title': 'React Native Fundamentals',
          'description': 'Build mobile apps with React Native',
          'instructor': 'John Doe',
          'category': 'Mobile Development',
          'difficulty': 'Intermediate',
          'totalLessons': 12,
          'imageUrl': 'https://via.placeholder.com/300x200/4361EE/FFFFFF?text=React+Native',
          'isActive': true,
          'createdDate': FieldValue.serverTimestamp(),
        },
        {
          'title': 'Flutter Advanced',
          'description': 'Advanced Flutter concepts and patterns',
          'instructor': 'Jane Smith',
          'category': 'Mobile Development',
          'difficulty': 'Advanced',
          'totalLessons': 10,
          'imageUrl': 'https://via.placeholder.com/300x200/3A0CA3/FFFFFF?text=Flutter',
          'isActive': true,
          'createdDate': FieldValue.serverTimestamp(),
        },
        {
          'title': 'Python for Data Science',
          'description': 'Data analysis and visualization with Python',
          'instructor': 'Mike Johnson',
          'category': 'Data Science',
          'difficulty': 'Beginner',
          'totalLessons': 8,
          'imageUrl': 'https://via.placeholder.com/300x200/7209B7/FFFFFF?text=Python',
          'isActive': true,
          'createdDate': FieldValue.serverTimestamp(),
        },
        {
          'title': 'JavaScript Mastery',
          'description': 'Complete JavaScript guide from basics to advanced',
          'instructor': 'Sarah Wilson',
          'category': 'Web Development',
          'difficulty': 'Beginner',
          'totalLessons': 15,
          'imageUrl': 'https://via.placeholder.com/300x200/4CC9F0/FFFFFF?text=JavaScript',
          'isActive': true,
          'createdDate': FieldValue.serverTimestamp(),
        },
        {
          'title': 'Machine Learning Basics',
          'description': 'Introduction to ML algorithms and concepts',
          'instructor': 'Dr. Alex Chen',
          'category': 'AI & ML',
          'difficulty': 'Intermediate',
          'totalLessons': 10,
          'imageUrl': 'https://via.placeholder.com/300x200/F72585/FFFFFF?text=ML',
          'isActive': true,
          'createdDate': FieldValue.serverTimestamp(),
        },
      ];

      // Add courses to Firestore
      for (final courseData in sampleCourses) {
        await _firestore.collection('courses').add(courseData);
      }

      print('✅ Sample courses initialized successfully!');
    } catch (e) {
      print('❌ Error initializing courses: $e');
    }
  }

  // ========================================================================
  // EXAMS INITIALIZATION
  // ========================================================================

  static Future<void> initializeExamsData() async {
    try {
      final examsSnapshot = await _firestore.collection('exams').get();
      if (examsSnapshot.docs.isNotEmpty) {
        print('Exams already exist, skipping initialization');
        return;
      }

      // Sample exams data
      final sampleExams = [
        {
          'title': 'JavaScript Fundamentals Quiz',
          'description': 'Test your knowledge of JavaScript basics',
          'category': 'Web Development',
          'difficulty': 'Beginner',
          'totalQuestions': 10,
          'timeLimit': 15,
          'passingScore': 70.0,
          'tags': ['javascript', 'basics', 'quiz'],
          'isActive': true,
          'examType': 'quiz',
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'title': 'React Native Certification Mock',
          'description': 'Practice exam for React Native certification',
          'category': 'Mobile Development',
          'difficulty': 'Intermediate',
          'totalQuestions': 25,
          'timeLimit': 60,
          'passingScore': 75.0,
          'tags': ['react-native', 'mobile', 'certification'],
          'isActive': true,
          'examType': 'mock_exam',
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'title': 'Data Structures & Algorithms Quiz',
          'description': 'Advanced algorithms and data structures questions',
          'category': 'Computer Science',
          'difficulty': 'Advanced',
          'totalQuestions': 20,
          'timeLimit': 45,
          'passingScore': 80.0,
          'tags': ['algorithms', 'data-structures', 'cs'],
          'isActive': true,
          'examType': 'quiz',
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'title': 'Flutter Widgets Quiz',
          'description': 'Test your Flutter widget knowledge',
          'category': 'Mobile Development',
          'difficulty': 'Intermediate',
          'totalQuestions': 15,
          'timeLimit': 20,
          'passingScore': 70.0,
          'tags': ['flutter', 'widgets', 'ui'],
          'isActive': true,
          'examType': 'quiz',
          'createdAt': FieldValue.serverTimestamp(),
        },
      ];

      // Add exams to Firestore
      for (final examData in sampleExams) {
        await _firestore.collection('exams').add(examData);
      }

      print('✅ Sample exams initialized successfully!');
    } catch (e) {
      print('❌ Error initializing exams data: $e');
    }
  }

  // ========================================================================
  // WEEKLY UPDATES INITIALIZATION
  // ========================================================================

  static Future<void> initializeWeeklyUpdates() async {
    try {
      final updatesSnapshot = await _firestore.collection('weekly_updates').get();
      if (updatesSnapshot.docs.isNotEmpty) {
        print('Weekly updates already exist, skipping initialization');
        return;
      }

      final sampleUpdates = [
        {
          'title': 'New Flutter Course: Advanced State Management',
          'description': 'Learn advanced state management techniques with Riverpod and Bloc',
          'type': 'course',
          'imageUrl': 'https://via.placeholder.com/300x200/4361EE/FFFFFF?text=Flutter+Advanced',
          'publishDate': FieldValue.serverTimestamp(),
          'category': 'Mobile Development',
          'author': 'Jane Smith',
          'readTime': '8 hours',
          'isNew': true,
          'isActive': true,
          'metadata': {
            'courseId': 'flutter-advanced-2024',
            'difficulty': 'Advanced',
            'enrollmentCount': 1247,
          },
        },
        {
          'title': 'The Future of AI in Mobile Development',
          'description': 'Exploring how AI is transforming mobile app development',
          'type': 'article',
          'imageUrl': 'https://via.placeholder.com/300x200/3A0CA3/FFFFFF?text=AI+Future',
          'publishDate': FieldValue.serverTimestamp(),
          'category': 'AI & ML',
          'author': 'Dr. Alex Chen',
          'readTime': '8 min',
          'isNew': true,
          'isActive': true,
        },
        {
          'title': 'React Native 2024 Updates',
          'description': 'Major updates and new features in the latest React Native release',
          'type': 'news',
          'imageUrl': 'https://via.placeholder.com/300x200/7209B7/FFFFFF?text=React+Native',
          'publishDate': FieldValue.serverTimestamp(),
          'category': 'Mobile Development',
          'author': 'John Doe',
          'readTime': '5 min',
          'isNew': true,
          'isActive': true,
        },
      ];

      for (final updateData in sampleUpdates) {
        await _firestore.collection('weekly_updates').add(updateData);
      }

      print('✅ Weekly updates initialized successfully!');
    } catch (e) {
      print('❌ Error initializing weekly updates: $e');
    }
  }

  // ========================================================================
  // EXAM OPERATIONS
  // ========================================================================

  static Future<List<Exam>> getAllExams() async {
    try {
      if (!_isFirebaseInitialized) {
        return [];
      }

      final snapshot = await _firestore
          .collection('exams')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        final tags = List<String>.from(data['tags'] ?? []);
        final createdAt = data['createdAt'] != null
            ? (data['createdAt'] as Timestamp).toDate()
            : DateTime.now();

        return Exam(
          id: doc.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          category: data['category'] ?? '',
          difficulty: data['difficulty'] ?? 'Beginner',
          totalQuestions: data['totalQuestions'] ?? 10,
          timeLimit: data['timeLimit'] ?? 30,
          passingScore: (data['passingScore'] ?? 70.0).toDouble(),
          createdAt: createdAt,
          tags: tags,
          isActive: data['isActive'] ?? true,
          examType: data['examType'] ?? 'quiz',
        );
      }).toList();
    } catch (e) {
      print('Error getting exams: $e');
      return [];
    }
  }

  static Future<void> saveExamResult(ExamResult result) async {
    try {
      if (!_isFirebaseInitialized) {
        print('Firebase not initialized, skipping exam result save');
        return;
      }

      final userId = currentUserId;
      if (userId.isEmpty) {
        print('No user ID found, cannot save exam result');
        return;
      }

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('examResults')
          .doc(result.id)
          .set({
        'userId': result.userId,
        'examId': result.examId,
        'examTitle': result.examTitle,
        'completedAt': Timestamp.fromDate(result.completedAt),
        'totalQuestions': result.totalQuestions,
        'correctAnswers': result.correctAnswers,
        'scorePercentage': result.scorePercentage,
        'timeTaken': result.timeTaken,
        'passed': result.passed,
        'detailedResults': result.detailedResults,
        'examType': result.examType,
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('Exam result saved to Firebase: ${result.examTitle}');
      await _updateUserExamStats(userId, result);
    } catch (e) {
      print('Error saving exam result to Firebase: $e');
    }
  }

  static Future<void> _updateUserExamStats(String userId, ExamResult result) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);
      final statsRef = userRef.collection('stats').doc('exams');

      final statsDoc = await statsRef.get();
      Map<String, dynamic> currentStats = {};

      if (statsDoc.exists) {
        currentStats = statsDoc.data() as Map<String, dynamic>;
      }

      final totalExams = (currentStats['totalExams'] ?? 0) + 1;
      final totalPassed = (currentStats['totalPassed'] ?? 0) + (result.passed ? 1 : 0);
      final totalScore = (currentStats['totalScore'] ?? 0.0) + result.scorePercentage;
      final avgScore = totalScore / totalExams;

      final bestScore = currentStats['bestScore'] ?? 0.0;
      final newBestScore = result.scorePercentage > bestScore ? result.scorePercentage : bestScore;

      await statsRef.set({
        'totalExams': totalExams,
        'totalPassed': totalPassed,
        'totalFailed': totalExams - totalPassed,
        'totalScore': totalScore,
        'averageScore': avgScore,
        'bestScore': newBestScore,
        'lastExam': result.examTitle,
        'lastExamScore': result.scorePercentage,
        'lastExamDate': Timestamp.fromDate(result.completedAt),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error updating user exam stats: $e');
    }
  }

  static Future<List<ExamResult>> getUserExamResults(String userId) async {
    try {
      if (!_isFirebaseInitialized || userId.isEmpty) {
        return [];
      }

      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('examResults')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        final completedAt = data['completedAt'] != null
            ? (data['completedAt'] as Timestamp).toDate()
            : DateTime.now();

        return ExamResult(
          id: doc.id,
          userId: data['userId'] ?? '',
          examId: data['examId'] ?? '',
          examTitle: data['examTitle'] ?? '',
          completedAt: completedAt,
          totalQuestions: data['totalQuestions'] ?? 0,
          correctAnswers: data['correctAnswers'] ?? 0,
          scorePercentage: (data['scorePercentage'] ?? 0).toDouble(),
          timeTaken: data['timeTaken'] ?? 0,
          passed: data['passed'] ?? false,
          detailedResults: Map<String, dynamic>.from(data['detailedResults'] ?? {}),
          examType: data['examType'] ?? 'quiz',
        );
      }).toList();
    } catch (e) {
      print('Error getting user exam results: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> getUserExamStatistics(String userId) async {
    try {
      if (!_isFirebaseInitialized || userId.isEmpty) {
        return {
          'totalExamsTaken': 0,
          'passedExams': 0,
          'failedExams': 0,
          'averageScore': 0,
          'bestScore': 0,
        };
      }

      final statsRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('stats')
          .doc('exams');

      final statsDoc = await statsRef.get();

      if (statsDoc.exists) {
        final data = statsDoc.data() as Map<String, dynamic>;
        return {
          'totalExamsTaken': data['totalExams'] ?? 0,
          'passedExams': data['totalPassed'] ?? 0,
          'failedExams': data['totalFailed'] ?? 0,
          'averageScore': (data['averageScore'] ?? 0).toDouble(),
          'bestScore': (data['bestScore'] ?? 0).toDouble(),
        };
      }

      return {
        'totalExamsTaken': 0,
        'passedExams': 0,
        'failedExams': 0,
        'averageScore': 0,
        'bestScore': 0,
      };
    } catch (e) {
      print('Error getting user exam statistics: $e');
      return {
        'totalExamsTaken': 0,
        'passedExams': 0,
        'failedExams': 0,
        'averageScore': 0,
        'bestScore': 0,
      };
    }
  }

  static Future<List<Question>> getExamQuestions(String examId) async {
    try {
      if (!_isFirebaseInitialized || examId.isEmpty) {
        return [];
      }

      final querySnapshot = await _firestore
          .collection('exams')
          .doc(examId)
          .collection('questions')
          .orderBy('order')
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        final options = List<String>.from(data['options'] ?? []);

        return Question(
          id: doc.id,
          examId: examId,
          questionText: data['questionText'] ?? '',
          questionType: data['questionType'] ?? 'multiple_choice',
          options: options,
          correctOptionIndex: data['correctOptionIndex'] ?? -1,
          correctCode: data['correctCode'],
          codingLanguage: data['codingLanguage'],
          hint: data['hint'],
          points: data['points'] ?? 10,
        );
      }).toList();
    } catch (e) {
      print('Error getting exam questions: $e');
      return [];
    }
  }

  // ========================================================================
  // WEEKLY UPDATES OPERATIONS
  // ========================================================================

  static Future<List<Update>> getWeeklyUpdates() async {
    try {
      final snapshot = await _firestore
          .collection('weekly_updates')
          .where('isActive', isEqualTo: true)
          .where('publishDate', isGreaterThan:
      Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 7))))
          .orderBy('publishDate', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Update(
          id: doc.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          type: data['type'] ?? 'news',
          imageUrl: data['imageUrl'],
          publishDate: data['publishDate'] != null
              ? (data['publishDate'] as Timestamp).toDate()
              : DateTime.now(),
          category: data['category'],
          author: data['author'],
          readTime: data['readTime'],
          isNew: data['isNew'] ?? true,
          metadata: data['metadata'] != null
              ? Map<String, dynamic>.from(data['metadata'])
              : null,
        );
      }).toList();
    } catch (e) {
      print('Error getting weekly updates: $e');
      return [];
    }
  }

  // ========================================================================
  // COURSE OPERATIONS
  // ========================================================================

  static Future<List<Course>> getAllCourses() async {
    try {
      final snapshot = await _firestore
          .collection('courses')
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Course(
          id: doc.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          currentLesson: 0,
          totalLessons: data['totalLessons'] ?? 0,
          progress: 0.0,
          category: data['category'] ?? '',
          instructor: data['instructor'] ?? '',
          imageUrl: data['imageUrl'] ?? '',
          isEnrolled: false,
          enrolledDate: DateTime.now(),
          difficulty: data['difficulty'] ?? 'Beginner',
        );
      }).toList();
    } catch (e) {
      print('Error getting courses: $e');
      return [];
    }
  }

  static Future<List<Course>> getEnrolledCourses(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        await _firestore.collection('users').doc(userId).set({
          'name': 'Alex',
          'email': 'alex@example.com',
          'xpPoints': 1247,
          'dayStreak': 7,
          'studyTimeThisWeek': 2.5,
          'enrolledCourses': [],
          'createdAt': FieldValue.serverTimestamp(),
        });
        return [];
      }

      final userData = userDoc.data()!;
      final enrolledCourseIds = List<String>.from(userData['enrolledCourses'] ?? []);

      if (enrolledCourseIds.isEmpty) return [];

      final enrolledCourses = <Course>[];

      for (final courseId in enrolledCourseIds) {
        final courseDoc = await _firestore.collection('courses').doc(courseId).get();
        if (courseDoc.exists) {
          final courseData = courseDoc.data()!;
          final progressDoc = await _firestore
              .collection('userProgress')
              .doc(userId)
              .collection('courses')
              .doc(courseId)
              .get();

          final progressData = progressDoc.data() ?? {};

          enrolledCourses.add(Course(
            id: courseId,
            title: courseData['title'],
            description: courseData['description'],
            currentLesson: progressData['currentLesson'] ?? 0,
            totalLessons: courseData['totalLessons'],
            progress: progressData['progress']?.toDouble() ?? 0.0,
            category: courseData['category'],
            instructor: courseData['instructor'],
            imageUrl: courseData['imageUrl'],
            isEnrolled: true,
            enrolledDate: progressData['enrolledDate']?.toDate() ?? DateTime.now(),
            difficulty: courseData['difficulty'],
          ));
        }
      }

      return enrolledCourses;
    } catch (e) {
      print('Error getting enrolled courses: $e');
      return [];
    }
  }

  static Future<void> enrollInCourse(String userId, String courseId) async {
    try {
      final batch = _firestore.batch();

      final userRef = _firestore.collection('users').doc(userId);
      batch.update(userRef, {
        'enrolledCourses': FieldValue.arrayUnion([courseId])
      });

      final progressRef = _firestore
          .collection('userProgress')
          .doc(userId)
          .collection('courses')
          .doc(courseId);

      batch.set(progressRef, {
        'currentLesson': 0,
        'progress': 0.0,
        'enrolledDate': FieldValue.serverTimestamp(),
        'lastAccessed': FieldValue.serverTimestamp(),
        'completedLessons': [],
      });

      await batch.commit();
      print('Successfully enrolled in course: $courseId');
    } catch (e) {
      print('Error enrolling in course: $e');
      rethrow;
    }
  }

  static Future<void> unenrollFromCourse(String userId, String courseId) async {
    try {
      final batch = _firestore.batch();

      final userRef = _firestore.collection('users').doc(userId);
      batch.update(userRef, {
        'enrolledCourses': FieldValue.arrayRemove([courseId])
      });

      final progressRef = _firestore
          .collection('userProgress')
          .doc(userId)
          .collection('courses')
          .doc(courseId);
      batch.delete(progressRef);

      await batch.commit();
      print('Successfully unenrolled from course: $courseId');
    } catch (e) {
      print('Error unenrolling from course: $e');
      rethrow;
    }
  }

  static Future<void> updateCourseProgress(
      String userId,
      String courseId,
      int currentLesson,
      double progress,
      ) async {
    try {
      await _firestore
          .collection('userProgress')
          .doc(userId)
          .collection('courses')
          .doc(courseId)
          .update({
        'currentLesson': currentLesson,
        'progress': progress,
        'lastAccessed': FieldValue.serverTimestamp(),
        'completedLessons': FieldValue.arrayUnion([currentLesson]),
      });

      print('Progress updated for course: $courseId');
    } catch (e) {
      print('Error updating progress: $e');
      rethrow;
    }
  }

  // ========================================================================
  // USER OPERATIONS
  // ========================================================================

  static Future<void> ensureUserDocument(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        await _firestore.collection('users').doc(userId).set({
          'name': 'Alex',
          'email': 'alex@example.com',
          'xpPoints': 1247,
          'dayStreak': 7,
          'studyTimeThisWeek': 2.5,
          'createdAt': FieldValue.serverTimestamp(),
          'lastUpdated': FieldValue.serverTimestamp(),
        });
        print('✅ Created user document for: $userId');
      } else {
        await _firestore.collection('users').doc(userId).update({
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('❌ Error ensuring user document: $e');
    }
  }

  static Future<void> clearUserData(String userId) async {
    try {
      print('🧹 Clearing all user data for: $userId');

      final enrolledSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('enrolled_courses')
          .get();

      for (final doc in enrolledSnapshot.docs) {
        await doc.reference.delete();
      }

      final progressSnapshot = await _firestore
          .collection('userProgress')
          .doc(userId)
          .collection('courses')
          .get();

      for (final doc in progressSnapshot.docs) {
        await doc.reference.delete();
      }

      print('✅ User data cleared successfully');
    } catch (e) {
      print('❌ Error clearing user data: $e');
    }
  }

  // ========================================================================
  // TESTING/DEBUGGING METHODS
  // ========================================================================

  static Future<void> clearAllAssessments() async {
    try {
      print('🧹 Clearing all assessment data...');

      final assessments = await _firestore.collection('assessments').get();
      for (final doc in assessments.docs) {
        final questions = await doc.reference.collection('questions').get();
        for (final questionDoc in questions.docs) {
          await questionDoc.reference.delete();
        }
        await doc.reference.delete();
      }

      print('✅ All assessment data cleared');
    } catch (e) {
      print('❌ Error clearing assessment data: $e');
    }
  }

  static Future<void> forceReinitialize() async {
    print('🔄 Forcing re-initialization...');
    await clearAllAssessments();
    await initializeAssessmentsFromJson();
  }
}
