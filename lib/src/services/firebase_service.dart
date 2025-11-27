import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/course_model.dart';
import '../models/user_model.dart';
import '../models/update_model.dart'; // Add this import

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID (for demo, use a fixed ID)
  static String get currentUserId {
    return _auth.currentUser?.uid ?? 'demo-user-123';
  }

  // Initialize sample data (run this once)
  static Future<void> initializeSampleData() async {
    try {
      // Check if courses already exist
      final coursesSnapshot = await _firestore.collection('courses').get();
      if (coursesSnapshot.docs.isNotEmpty) {
        print('Courses already exist, skipping initialization');

        // Initialize weekly updates even if courses exist
        await initializeWeeklyUpdates();
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

      // Initialize weekly updates
      await initializeWeeklyUpdates();

      print('Sample courses and weekly updates initialized successfully!');
    } catch (e) {
      print('Error initializing sample data: $e');
    }
  }

  // NEW: Weekly Updates Methods
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
          'description': 'Exploring how AI is transforming mobile app development and user experiences',
          'type': 'article',
          'imageUrl': 'https://via.placeholder.com/300x200/3A0CA3/FFFFFF?text=AI+Future',
          'publishDate': FieldValue.serverTimestamp(),
          'category': 'AI & ML',
          'author': 'Dr. Alex Chen',
          'readTime': '8 min',
          'isNew': true,
          'isActive': true,
          'metadata': {
            'readCount': 2843,
            'likes': 156,
          },
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
        {
          'title': 'Python for Machine Learning: Complete Guide',
          'description': 'Comprehensive guide to machine learning with Python and TensorFlow',
          'type': 'course',
          'imageUrl': 'https://via.placeholder.com/300x200/4CC9F0/FFFFFF?text=Python+ML',
          'publishDate': FieldValue.serverTimestamp(),
          'category': 'AI & ML',
          'author': 'Mike Johnson',
          'readTime': '12 hours',
          'isNew': false,
          'isActive': true,
          'metadata': {
            'courseId': 'python-ml-2024',
            'difficulty': 'Intermediate',
            'enrollmentCount': 3562,
          },
        },
        {
          'title': 'Web Development Trends 2024',
          'description': 'Top web development trends and technologies to watch this year',
          'type': 'article',
          'imageUrl': 'https://via.placeholder.com/300x200/F72585/FFFFFF?text=Web+Trends',
          'publishDate': FieldValue.serverTimestamp(),
          'category': 'Web Development',
          'author': 'Sarah Wilson',
          'readTime': '10 min',
          'isNew': true,
          'isActive': true,
        },
      ];

      for (final updateData in sampleUpdates) {
        await _firestore.collection('weekly_updates').add(updateData);
      }

      print('Weekly updates initialized successfully!');
    } catch (e) {
      print('Error initializing weekly updates: $e');
    }
  }

  // Course Operations
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
      // Get user document
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        // Create user document if it doesn't exist
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

      // Get enrolled courses
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

      // Add to user's enrolled courses
      final userRef = _firestore.collection('users').doc(userId);
      batch.update(userRef, {
        'enrolledCourses': FieldValue.arrayUnion([courseId])
      });

      // Create progress document
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

      // Remove from user's enrolled courses
      final userRef = _firestore.collection('users').doc(userId);
      batch.update(userRef, {
        'enrolledCourses': FieldValue.arrayRemove([courseId])
      });

      // Remove progress document
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

  // Helper method to ensure user document exists
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
        // Update last accessed time
        await _firestore.collection('users').doc(userId).update({
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('❌ Error ensuring user document: $e');
    }
  }

  // Method to clear all data and start fresh (for testing)
  static Future<void> clearUserData(String userId) async {
    try {
      print('🧹 Clearing all user data for: $userId');

      // Delete enrolled courses
      final enrolledSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('enrolled_courses')
          .get();

      for (final doc in enrolledSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete progress data
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
}