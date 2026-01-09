// lib/services/firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/course_model.dart';
import '../models/user_model.dart';
import '../models/update_model.dart';
import '../models/timetable_model.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Track Firebase initialization status
  static bool _isFirebaseInitialized = true;

  // Collection names
  static const String coursesCollection = 'courses';
  static const String usersCollection = 'users';
  static const String updatesCollection = 'weekly_updates';
  static const String timetableCollection = 'timetable_slots';
  static const String userProgressCollection = 'userProgress';

  // Get current user ID
  static String get currentUserId {
    return _auth.currentUser?.uid ?? 'demo-user-123';
  }

  // ========================================================================
  // MAIN INITIALIZATION - Call this in main.dart
  // ========================================================================

  /// Initialize ALL sample data (courses, weekly updates, timetable)
  static Future<void> initializeSampleData() async {
    try {
      print('🚀 Initializing all sample data...');
      print('=' * 60);

      // Initialize courses
      await _initializeCourses();

      // Initialize weekly updates
      await initializeWeeklyUpdates();

      // Initialize timetable sample data for authenticated users
      await _initializeTimetableSampleData();

      print('');
      print('=' * 60);
      print('✅ All sample data initialized successfully!');
    } catch (e) {
      print('❌ Error initializing sample data: $e');
    }
  }

  // ========================================================================
  // TIMETABLE INITIALIZATION
  // ========================================================================

  static Future<void> _initializeTimetableSampleData() async {
    try {
      final auth = FirebaseAuth.instance;
      final user = auth.currentUser;

      if (user == null) {
        print('👤 No authenticated user, skipping timetable initialization');
        return;
      }

      // Check if user already has timetable data
      final timetableSnapshot = await _firestore
          .collection(timetableCollection)
          .where('userId', isEqualTo: user.uid)
          .limit(1)
          .get();

      // Only create sample data if user has no timetable slots
      if (timetableSnapshot.docs.isEmpty) {
        await _createSampleTimetableSlots(user.uid);
      } else {
        print('📅 Timetable data already exists for user, skipping initialization');
      }
    } catch (e) {
      print('❌ Error initializing timetable sample data: $e');
    }
  }

  static Future<void> _createSampleTimetableSlots(String userId) async {
    try {
      final now = DateTime.now();
      final batch = _firestore.batch();

      print('🔄 Creating sample timetable slots for user: $userId');

      // Get user's enrolled courses to link timetable slots
      final enrolledCourses = await getEnrolledCourses(userId);
      final hasCourses = enrolledCourses.isNotEmpty;

      // Sample timetable slots for the next 7 days
      for (int i = 0; i < 7; i++) {
        final date = now.add(Duration(days: i));
        final dayOfWeek = date.weekday;

        // Morning study session (Every day)
        final morningSlotRef = _firestore.collection(timetableCollection).doc();
        final morningCourse = hasCourses ? enrolledCourses.first : null;

        batch.set(morningSlotRef, {
          'id': morningSlotRef.id,
          'userId': userId,
          'date': Timestamp.fromDate(date),
          'startTime': {'hour': 9, 'minute': 0},
          'endTime': {'hour': 11, 'minute': 0},
          'title': hasCourses ? '${morningCourse?.title} Study' : 'Morning Study Session',
          'description': hasCourses
              ? 'Review ${morningCourse?.category} concepts'
              : 'Focus on difficult topics when fresh',
          'courseId': hasCourses ? morningCourse?.id : '',
          'colorHex': _getColorForDay(dayOfWeek),
          'isCompleted': false,
          'isRecurring': false,
          'recurringDays': [],
          'recurringEndDate': null,
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        });

        // Afternoon review session (Weekdays only)
        if (dayOfWeek <= 5) {
          final afternoonSlotRef = _firestore.collection(timetableCollection).doc();
          final afternoonCourse = hasCourses && enrolledCourses.length > 1
              ? enrolledCourses[1]
              : null;

          batch.set(afternoonSlotRef, {
            'id': afternoonSlotRef.id,
            'userId': userId,
            'date': Timestamp.fromDate(date),
            'startTime': {'hour': 15, 'minute': 0},
            'endTime': {'hour': 16, 'minute': 30},
            'title': hasCourses ? '${afternoonCourse?.title} Review' : 'Afternoon Review',
            'description': hasCourses
                ? 'Practice ${afternoonCourse?.difficulty.toLowerCase()} exercises'
                : 'Review what you learned in the morning',
            'courseId': hasCourses ? afternoonCourse?.id : '',
            'colorHex': '#4CAF50',
            'isCompleted': false,
            'isRecurring': false,
            'recurringDays': [],
            'recurringEndDate': null,
            'createdAt': Timestamp.now(),
            'updatedAt': Timestamp.now(),
          });
        }

        // Evening practice session (Mon, Wed, Fri)
        if ([1, 3, 5].contains(dayOfWeek)) {
          final eveningSlotRef = _firestore.collection(timetableCollection).doc();
          final eveningCourse = hasCourses && enrolledCourses.length > 2
              ? enrolledCourses[2]
              : null;

          batch.set(eveningSlotRef, {
            'id': eveningSlotRef.id,
            'userId': userId,
            'date': Timestamp.fromDate(date),
            'startTime': {'hour': 19, 'minute': 0},
            'endTime': {'hour': 20, 'minute': 30},
            'title': hasCourses ? '${eveningCourse?.title} Practice' : 'Evening Practice',
            'description': hasCourses
                ? 'Work on ${eveningCourse?.category} assignments'
                : 'Practice exercises and problems',
            'courseId': hasCourses ? eveningCourse?.id : '',
            'colorHex': '#9C27B0',
            'isCompleted': false,
            'isRecurring': true,
            'recurringDays': [1, 3, 5], // Mon, Wed, Fri
            'recurringEndDate': Timestamp.fromDate(now.add(const Duration(days: 30))),
            'createdAt': Timestamp.now(),
            'updatedAt': Timestamp.now(),
          });
        }

        // Weekend project session (Sat, Sun)
        if (dayOfWeek >= 6) {
          final weekendSlotRef = _firestore.collection(timetableCollection).doc();

          batch.set(weekendSlotRef, {
            'id': weekendSlotRef.id,
            'userId': userId,
            'date': Timestamp.fromDate(date),
            'startTime': {'hour': 10, 'minute': 0},
            'endTime': {'hour': 13, 'minute': 0},
            'title': 'Weekend Project Session',
            'description': 'Work on personal projects and portfolio',
            'courseId': '',
            'colorHex': '#FF9800',
            'isCompleted': false,
            'isRecurring': true,
            'recurringDays': [6, 7], // Sat, Sun
            'recurringEndDate': Timestamp.fromDate(now.add(const Duration(days: 60))),
            'createdAt': Timestamp.now(),
            'updatedAt': Timestamp.now(),
          });
        }
      }

      await batch.commit();
      print('✅ Sample timetable slots created for user: $userId');
      print('📊 Created slots for: Morning (Daily), Afternoon (Weekdays), Evening (Mon/Wed/Fri), Weekend (Sat/Sun)');
    } catch (e) {
      print('❌ Error creating sample timetable slots: $e');
    }
  }

  static String _getColorForDay(int day) {
    final colors = [
      '#4361EE', // Monday - Blue
      '#4CAF50', // Tuesday - Green
      '#FF9800', // Wednesday - Orange
      '#F44336', // Thursday - Red
      '#9C27B0', // Friday - Purple
      '#00BCD4', // Saturday - Cyan
      '#795548', // Sunday - Brown
    ];
    return colors[(day - 1) % colors.length];
  }

  // ========================================================================
  // TIMETABLE OPERATIONS
  // ========================================================================

  /// Get timetable slots for a specific date range
  static Future<List<TimetableSlot>> getTimetableSlotsInRange(
      DateTime startDate,
      DateTime endDate,
      ) async {
    try {
      final userId = currentUserId;

      final querySnapshot = await _firestore
          .collection(timetableCollection)
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('date')
          .orderBy('startTime')
          .get();

      return querySnapshot.docs
          .map((doc) => TimetableSlot.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('❌ Error getting timetable slots in range: $e');
      return [];
    }
  }

  /// Get today's timetable slots
  static Future<List<TimetableSlot>> getTodaySlots() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return getTimetableSlotsInRange(startOfDay, endOfDay);
  }

  /// Add a new timetable slot
  static Future<TimetableSlot?> addTimetableSlot(TimetableSlot slot) async {
    try {
      final userId = currentUserId;

      // Generate a new document reference
      final docRef = _firestore.collection(timetableCollection).doc();

      // Create the final slot with ID
      final finalSlot = TimetableSlot(
        id: docRef.id,
        userId: userId,
        date: slot.date,
        startTime: slot.startTime,
        endTime: slot.endTime,
        title: slot.title,
        description: slot.description,
        courseId: slot.courseId,
        colorHex: slot.colorHex,
        isCompleted: slot.isCompleted,
        isRecurring: slot.isRecurring,
        recurringDays: slot.recurringDays,
        recurringEndDate: slot.recurringEndDate,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to Firestore
      await docRef.set(finalSlot.toFirestore());

      print('✅ Timetable slot added: ${finalSlot.title}');
      return finalSlot;
    } catch (e) {
      print('❌ Error adding timetable slot: $e');
      return null;
    }
  }

  /// Update an existing timetable slot
  static Future<bool> updateTimetableSlot(TimetableSlot slot) async {
    try {
      final updatedSlot = TimetableSlot(
        id: slot.id,
        userId: slot.userId,
        date: slot.date,
        startTime: slot.startTime,
        endTime: slot.endTime,
        title: slot.title,
        description: slot.description,
        courseId: slot.courseId,
        colorHex: slot.colorHex,
        isCompleted: slot.isCompleted,
        isRecurring: slot.isRecurring,
        recurringDays: slot.recurringDays,
        recurringEndDate: slot.recurringEndDate,
        createdAt: slot.createdAt,
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection(timetableCollection)
          .doc(slot.id)
          .update(updatedSlot.toFirestore());

      print('✅ Timetable slot updated: ${slot.title}');
      return true;
    } catch (e) {
      print('❌ Error updating timetable slot: $e');
      return false;
    }
  }

  /// Delete a timetable slot
  static Future<bool> deleteTimetableSlot(String slotId) async {
    try {
      await _firestore.collection(timetableCollection).doc(slotId).delete();
      print('✅ Timetable slot deleted: $slotId');
      return true;
    } catch (e) {
      print('❌ Error deleting timetable slot: $e');
      return false;
    }
  }

  /// Toggle slot completion status
  static Future<bool> toggleSlotCompletion(String slotId, bool isCompleted) async {
    try {
      await _firestore.collection(timetableCollection).doc(slotId).update({
        'isCompleted': isCompleted,
        'updatedAt': Timestamp.now(),
      });

      print('✅ Slot $slotId marked as ${isCompleted ? 'completed' : 'incomplete'}');
      return true;
    } catch (e) {
      print('❌ Error toggling slot completion: $e');
      return false;
    }
  }

  /// Get timetable statistics
  static Future<Map<String, dynamic>> getTimetableStats({
    int daysBack = 30,
  }) async {
    try {
      final userId = currentUserId;
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: daysBack));

      final slots = await getTimetableSlotsInRange(startDate, endDate);

      // Calculate statistics
      final totalSlots = slots.length;
      final completedSlots = slots.where((slot) => slot.isCompleted).length;

      double totalStudyMinutes = 0;
      final studyTimeByDay = <String, int>{};

      for (var slot in slots) {
        final durationMinutes = slot.duration.inMinutes;
        totalStudyMinutes += durationMinutes;

        final dayName = _getDayName(slot.date.weekday);
        studyTimeByDay[dayName] = (studyTimeByDay[dayName] ?? 0) + durationMinutes;
      }

      final totalStudyHours = totalStudyMinutes / 60;
      final averageStudyTimePerDay = totalStudyMinutes / daysBack / 60;

      return {
        'totalSlots': totalSlots,
        'completedSlots': completedSlots,
        'upcomingSlots': slots.where((slot) => slot.isUpcoming()).length,
        'totalStudyHours': totalStudyHours,
        'averageStudyTimePerDay': averageStudyTimePerDay,
        'studyTimeByDay': studyTimeByDay,
        'completionRate': totalSlots > 0 ? completedSlots / totalSlots : 0,
      };
    } catch (e) {
      print('❌ Error getting timetable stats: $e');
      return {
        'totalSlots': 0,
        'completedSlots': 0,
        'upcomingSlots': 0,
        'totalStudyHours': 0.0,
        'averageStudyTimePerDay': 0.0,
        'studyTimeByDay': {},
        'completionRate': 0.0,
      };
    }
  }

  /// Stream timetable slots for real-time updates
  static Stream<List<TimetableSlot>> streamUserTimetableSlots() {
    final userId = currentUserId;

    return _firestore
        .collection(timetableCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('date')
        .orderBy('startTime')
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => TimetableSlot.fromFirestore(doc)).toList());
  }

  /// Stream today's slots
  static Stream<List<TimetableSlot>> streamTodaySlots() {
    final userId = currentUserId;
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _firestore
        .collection(timetableCollection)
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy('date')
        .orderBy('startTime')
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => TimetableSlot.fromFirestore(doc)).toList());
  }

  /// Check for slot conflicts
  static Future<bool> hasSlotConflict(
      DateTime date,
      TimeOfDay startTime,
      TimeOfDay endTime, {
        String? excludeSlotId,
      }) async {
    try {
      final userId = currentUserId;

      final querySnapshot = await _firestore
          .collection(timetableCollection)
          .where('userId', isEqualTo: userId)
          .where('date', isEqualTo: Timestamp.fromDate(date))
          .get();

      for (var doc in querySnapshot.docs) {
        final slot = TimetableSlot.fromFirestore(doc);

        // Skip the slot we're editing
        if (excludeSlotId != null && slot.id == excludeSlotId) continue;

        // Check for time overlap
        final newStart = DateTime(date.year, date.month, date.day,
            startTime.hour, startTime.minute);
        final newEnd = DateTime(
            date.year, date.month, date.day, endTime.hour, endTime.minute);
        final existingStart = DateTime(date.year, date.month, date.day,
            slot.startTime.hour, slot.startTime.minute);
        final existingEnd = DateTime(date.year, date.month, date.day,
            slot.endTime.hour, slot.endTime.minute);

        if ((newStart.isBefore(existingEnd) && newEnd.isAfter(existingStart))) {
          return true; // Conflict found
        }
      }

      return false; // No conflicts
    } catch (e) {
      print('❌ Error checking slot conflict: $e');
      return false;
    }
  }

  /// Get slots by course ID
  static Future<List<TimetableSlot>> getSlotsByCourse(String courseId) async {
    try {
      final userId = currentUserId;

      final querySnapshot = await _firestore
          .collection(timetableCollection)
          .where('userId', isEqualTo: userId)
          .where('courseId', isEqualTo: courseId)
          .orderBy('date')
          .orderBy('startTime')
          .get();

      return querySnapshot.docs
          .map((doc) => TimetableSlot.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('❌ Error getting slots by course: $e');
      return [];
    }
  }

  /// Clear all timetable slots (for testing)
  static Future<bool> clearUserTimetable() async {
    try {
      final userId = currentUserId;

      final querySnapshot = await _firestore
          .collection(timetableCollection)
          .where('userId', isEqualTo: userId)
          .get();

      final batch = _firestore.batch();
      for (var doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('✅ Cleared timetable for user: $userId');
      return true;
    } catch (e) {
      print('❌ Error clearing timetable: $e');
      return false;
    }
  }

  // Helper method
  static String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      case 7: return 'Sunday';
      default: return '';
    }
  }

  // ========================================================================
  // COURSES INITIALIZATION (Existing - Unchanged)
  // ========================================================================

  static Future<void> _initializeCourses() async {
    try {
      // Check if courses already exist
      final coursesSnapshot = await _firestore.collection('courses').get();
      if (coursesSnapshot.docs.isNotEmpty) {
        print('Courses already exist, skipping initialization');
        return;
      }

      // Sample courses data (same as before)
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
        // ... (rest of the courses data remains the same)
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
  // WEEKLY UPDATES INITIALIZATION (Existing - Unchanged)
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
        // ... (rest of the updates data remains the same)
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
  // WEEKLY UPDATES OPERATIONS (Existing - Unchanged)
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
  // COURSE OPERATIONS (Existing - Unchanged)
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
  // USER OPERATIONS (Existing - Unchanged)
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

      // Clear enrolled courses
      final enrolledSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('enrolled_courses')
          .get();

      for (final doc in enrolledSnapshot.docs) {
        await doc.reference.delete();
      }

      // Clear progress
      final progressSnapshot = await _firestore
          .collection('userProgress')
          .doc(userId)
          .collection('courses')
          .get();

      for (final doc in progressSnapshot.docs) {
        await doc.reference.delete();
      }

      // Clear timetable slots
      await clearUserTimetable();

      print('✅ User data cleared successfully');
    } catch (e) {
      print('❌ Error clearing user data: $e');
    }
  }
}