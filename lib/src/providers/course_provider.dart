import 'package:flutter/foundation.dart';
import '../models/course_model.dart';
import '../models/session_model.dart';
import '../services/firebase_service.dart';
import '../services/session_service.dart';

class CourseProvider with ChangeNotifier {
  List<Course> _enrolledCourses = [];
  List<Course> _availableCourses = [];
  // ADD THIS METHOD
  List<String> getAllCategories() {
    // Get unique categories from all courses
    final categories = <String>{};

    // Add categories from enrolled courses
    for (final course in _enrolledCourses) {
      categories.add(course.category);
    }

    // Add categories from available courses
    for (final course in _availableCourses) {
      categories.add(course.category);
    }

    // If no categories found, return default categories
    if (categories.isEmpty) {
      return [
        'Technology',
        'Science',
        'Mathematics',
        'Business',
        'Arts',
        'Languages',
        'Health',
        'Social Sciences'
      ];
    }

    return categories.toList()..sort();
  }
  bool _isLoading = false;
  String? _error;

  // Track initialization state
  bool _isInitialized = false;

  // Session management properties
  UserSession? _lastSession;
  UserSession? get lastSession => _lastSession;
  bool _hasLoadedSession = false;

  List<Course> get enrolledCourses => _enrolledCourses;
  List<Course> get availableCourses => _availableCourses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Session management getters
  bool get hasValidSession => _lastSession != null && _lastSession!.isValid;
  bool get hasRecentSession => _lastSession != null && _lastSession!.isRecent;
  Course? get resumeCourse => _getCourseForResume();

  // Constructor to initialize with data
  CourseProvider() {
    // Initialize immediately with mock data
    _initializeWithMockData();
  }

  Future<void> loadCourses() async {
    // Don't reload if already loading
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('=== CourseProvider: Loading courses ===');

      // Always ensure we have data even if Firebase fails
      if (_availableCourses.isEmpty) {
        print('No courses available, loading mock data first...');
        loadMockData();
      }

      try {
        // Try to initialize Firebase sample data
        await FirebaseService.initializeSampleData();

        // Load courses from Firebase using helper method
        final firebaseResult = await _loadCoursesFromFirebase();

        if (firebaseResult['success']) {
          final firebaseCourses = firebaseResult['availableCourses'] as List<Course>;
          final firebaseEnrolled = firebaseResult['enrolledCourses'] as List<Course>;

          print('Firebase courses loaded: ${firebaseCourses.length} available, ${firebaseEnrolled.length} enrolled');

          // Merge Firebase data with existing data
          if (firebaseCourses.isNotEmpty) {
            _availableCourses = firebaseCourses;
          }

          if (firebaseEnrolled.isNotEmpty) {
            _enrolledCourses = firebaseEnrolled;
          }
        } else {
          print('Firebase loading failed, using local data');
          _error = 'Firebase unavailable, using local data';
        }

      } catch (firebaseError) {
        print('Firebase loading failed: $firebaseError');
        // Keep existing mock data
        _error = 'Firebase unavailable, using local data';
      }

      // Load last session after courses are loaded
      if (!_hasLoadedSession) {
        await _loadLastSession();
        _hasLoadedSession = true;
      }

      print('Total courses now: ${_availableCourses.length} available, ${_enrolledCourses.length} enrolled');

    } catch (e) {
      _error = 'Failed to load courses: $e';
      print('Error loading courses: $e');

      // Ensure we have data even on error
      if (_availableCourses.isEmpty) {
        print('Loading mock data after error...');
        loadMockData();
      }

      if (!_hasLoadedSession) {
        await _loadLastSession();
        _hasLoadedSession = true;
      }
    } finally {
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
    }
  }

  // NEW: Helper method to safely load courses from Firebase
  Future<Map<String, dynamic>> _loadCoursesFromFirebase() async {
    try {
      List<Course> firebaseCourses = [];
      List<Course> firebaseEnrolled = [];

      // Try to call Firebase methods if they exist
      try {
        firebaseCourses = await FirebaseService.getAllCourses();
        print('Firebase getAllCourses success: ${firebaseCourses.length} courses');
      } catch (e) {
        print('getAllCourses failed: $e');
        firebaseCourses = [];
      }

      try {
        firebaseEnrolled = await FirebaseService.getEnrolledCourses(FirebaseService.currentUserId);
        print('Firebase getEnrolledCourses success: ${firebaseEnrolled.length} enrolled');
      } catch (e) {
        print('getEnrolledCourses failed: $e');
        firebaseEnrolled = [];
      }

      return {
        'availableCourses': firebaseCourses,
        'enrolledCourses': firebaseEnrolled,
        'success': firebaseCourses.isNotEmpty || firebaseEnrolled.isNotEmpty,
      };
    } catch (e) {
      print('Error loading from Firebase: $e');
      return {
        'availableCourses': [],
        'enrolledCourses': [],
        'success': false,
      };
    }
  }

  // Initialize with mock data immediately
  void _initializeWithMockData() {
    print('Initializing CourseProvider with mock data...');
    if (_availableCourses.isEmpty) {
      loadMockData();
    }
  }

  // NEW: Public method to load mock data
  void loadMockData() {
    print('Loading comprehensive mock data...');

    // Clear existing data
    _availableCourses.clear();
    _enrolledCourses.clear();

    // Available courses
    _availableCourses = [
      Course(
        id: '1',
        title: 'React Native Fundamentals',
        description: 'Build cross-platform mobile apps with React Native from scratch',
        currentLesson: 0,
        totalLessons: 12,
        progress: 0.0,
        category: 'Mobile Development',
        instructor: 'John Doe',
        imageUrl: '',
        isEnrolled: false,
        enrolledDate: DateTime.now(),
        difficulty: 'Beginner',
      ),
      Course(
        id: '2',
        title: 'Flutter Advanced',
        description: 'Master advanced Flutter concepts and state management',
        currentLesson: 0,
        totalLessons: 10,
        progress: 0.0,
        category: 'Mobile Development',
        instructor: 'Jane Smith',
        imageUrl: '',
        isEnrolled: false,
        enrolledDate: DateTime.now(),
        difficulty: 'Advanced',
      ),
      Course(
        id: '3',
        title: 'Web Development Bootcamp',
        description: 'Full-stack web development with HTML, CSS, JavaScript, and Node.js',
        currentLesson: 0,
        totalLessons: 20,
        progress: 0.0,
        category: 'Web Development',
        instructor: 'Alex Chen',
        imageUrl: '',
        isEnrolled: false,
        enrolledDate: DateTime.now(),
        difficulty: 'Intermediate',
      ),
      Course(
        id: '4',
        title: 'Python for Data Science',
        description: 'Data analysis, visualization, and machine learning with Python',
        currentLesson: 0,
        totalLessons: 15,
        progress: 0.0,
        category: 'Data Science',
        instructor: 'Mike Johnson',
        imageUrl: '',
        isEnrolled: false,
        enrolledDate: DateTime.now(),
        difficulty: 'Intermediate',
      ),
      Course(
        id: '5',
        title: 'UI/UX Design Principles',
        description: 'Learn modern UI/UX design patterns and best practices',
        currentLesson: 0,
        totalLessons: 12,
        progress: 0.0,
        category: 'Design',
        instructor: 'Emma Wilson',
        imageUrl: '',
        isEnrolled: false,
        enrolledDate: DateTime.now(),
        difficulty: 'Beginner',
      ),
      Course(
        id: '6',
        title: 'JavaScript Mastery',
        description: 'Master JavaScript from basics to advanced concepts and frameworks',
        currentLesson: 0,
        totalLessons: 18,
        progress: 0.0,
        category: 'Web Development',
        instructor: 'Sarah Johnson',
        imageUrl: '',
        isEnrolled: false,
        enrolledDate: DateTime.now(),
        difficulty: 'Intermediate',
      ),
      Course(
        id: '7',
        title: 'Machine Learning Basics',
        description: 'Introduction to machine learning algorithms and data preprocessing',
        currentLesson: 0,
        totalLessons: 14,
        progress: 0.0,
        category: 'AI/ML',
        instructor: 'Dr. Robert Kim',
        imageUrl: '',
        isEnrolled: false,
        enrolledDate: DateTime.now(),
        difficulty: 'Advanced',
      ),
      Course(
        id: '8',
        title: 'DevOps Fundamentals',
        description: 'Introduction to DevOps practices, CI/CD, and containerization',
        currentLesson: 0,
        totalLessons: 10,
        progress: 0.0,
        category: 'DevOps',
        instructor: 'David Miller',
        imageUrl: '',
        isEnrolled: false,
        enrolledDate: DateTime.now(),
        difficulty: 'Intermediate',
      ),
    ];

    // Enrolled courses (with progress)
    _enrolledCourses = [
      Course(
        id: '9',
        title: 'Mobile App Development',
        description: 'Comprehensive mobile app development course',
        currentLesson: 8,
        totalLessons: 12,
        progress: 0.65,
        category: 'Mobile Development',
        instructor: 'John Doe',
        imageUrl: '',
        isEnrolled: true,
        enrolledDate: DateTime(2024, 1, 15),
        difficulty: 'Intermediate',
      ),
      Course(
        id: '10',
        title: 'Data Structures & Algorithms',
        description: 'Essential computer science concepts for interviews',
        currentLesson: 5,
        totalLessons: 15,
        progress: 0.33,
        category: 'Computer Science',
        instructor: 'Prof. Alan Turing',
        imageUrl: '',
        isEnrolled: true,
        enrolledDate: DateTime(2024, 1, 20),
        difficulty: 'Advanced',
      ),
    ];

    print('Mock data loaded: ${_availableCourses.length} available courses, ${_enrolledCourses.length} enrolled courses');
    notifyListeners();
  }

  // NEW: Add a test course (for debugging)
  void addTestCourse() {
    final testCourse = Course(
      id: 'test-${DateTime.now().millisecondsSinceEpoch}',
      title: 'Test Course',
      description: 'This is a test course for debugging purposes',
      currentLesson: 0,
      totalLessons: 5,
      progress: 0.0,
      category: 'Testing',
      instructor: 'Test Instructor',
      imageUrl: '',
      isEnrolled: false,
      enrolledDate: DateTime.now(),
      difficulty: 'Beginner',
    );

    _availableCourses.add(testCourse);
    notifyListeners();

    print('Test course added: ${testCourse.title}');
  }

  // NEW: Clear all data and reload
  Future<void> clearAndReload() async {
    print('Clearing all course data...');
    _availableCourses.clear();
    _enrolledCourses.clear();
    _lastSession = null;
    _hasLoadedSession = false;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));
    await loadCourses();
  }

  // NEW: Get course by ID
  Course? getCourseById(String id) {
    try {
      return _availableCourses.firstWhere((course) => course.id == id);
    } catch (e) {
      print('Course not found with id: $id');
      return null;
    }
  }

  // NEW: Check enrollment status
  bool isEnrolled(String courseId) {
    return _enrolledCourses.any((course) => course.id == courseId);
  }

  // NEW: Force reload data
  Future<void> forceReload() async {
    _isInitialized = false;
    await loadCourses();
  }

  // Load last session
  Future<void> _loadLastSession() async {
    try {
      final sessionData = await SessionService().getLastCourseActivity();
      if (sessionData != null && sessionData['courseId'] != null) {
        _lastSession = UserSession(
          userId: FirebaseService.currentUserId,
          lastActivityTime: DateTime.now(),
          lastActivityType: 'course',
          lastActivityId: sessionData['courseId'],
          lastLessonIndex: sessionData['lessonIndex'] ?? 0,
          activityData: sessionData['activityData'] ?? {},
        );
        print('Loaded last session for course: ${sessionData['courseId']}');
      } else {
        print('No session data found');
      }
    } catch (e) {
      print('Error loading last session: $e');
    }
  }

  // Update course progress with session saving
  Future<void> updateCourseProgressWithSession(String courseId, int completedLessons) async {
    try {
      final courseIndex = _enrolledCourses.indexWhere((c) => c.id == courseId);
      if (courseIndex != -1) {
        final course = _enrolledCourses[courseIndex];
        final newProgress = completedLessons / course.totalLessons;

        // Update local course progress
        _enrolledCourses[courseIndex] = Course(
          id: course.id,
          title: course.title,
          description: course.description,
          currentLesson: completedLessons,
          totalLessons: course.totalLessons,
          progress: newProgress,
          category: course.category,
          instructor: course.instructor,
          imageUrl: course.imageUrl,
          isEnrolled: true,
          enrolledDate: course.enrolledDate,
          difficulty: course.difficulty,
        );

        // Save session
        await SessionService().saveCourseProgress(
          courseId,
          completedLessons,
          additionalData: {
            'courseTitle': course.title,
            'progressPercentage': (newProgress * 100).toInt(),
            'lessonsCompleted': completedLessons,
            'totalLessons': course.totalLessons,
            'lastUpdated': DateTime.now().toIso8601String(),
          },
        );

        // Update Firebase if available - using safe method
        try {
          await _updateCourseProgressInFirebase(
              FirebaseService.currentUserId,
              courseId,
              completedLessons,
              newProgress
          );
        } catch (e) {
          print('Error updating Firebase progress: $e');
        }

        // Update last session
        _lastSession = UserSession(
          userId: FirebaseService.currentUserId,
          lastActivityTime: DateTime.now(),
          lastActivityType: 'course',
          lastActivityId: courseId,
          lastLessonIndex: completedLessons,
          activityData: {
            'courseTitle': course.title,
            'progressPercentage': (newProgress * 100).toInt(),
            'lessonsCompleted': completedLessons,
            'totalLessons': course.totalLessons,
          },
        );

        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update progress: $e';
      notifyListeners();
      rethrow;
    }
  }

  // NEW: Safe method to update course progress in Firebase
  Future<void> _updateCourseProgressInFirebase(
      String userId,
      String courseId,
      int completedLessons,
      double progress,
      ) async {
    try {
      // Check if method exists before calling
      await FirebaseService.updateCourseProgress(
          userId,
          courseId,
          completedLessons,
          progress
      );
      print('Firebase progress updated successfully');
    } catch (e) {
      print('Firebase progress update failed: $e');
      // Don't rethrow - let local update succeed
    }
  }

  // Get course for resume functionality
  Course? _getCourseForResume() {
    if (_lastSession != null && _lastSession!.lastActivityType == 'course') {
      try {
        return _enrolledCourses.firstWhere(
              (c) => c.id == _lastSession!.lastActivityId,
        );
      } catch (e) {
        print('Course for resume not found: ${_lastSession!.lastActivityId}');
        return null;
      }
    }
    return null;
  }

  // Get last lesson index for resume
  int getLastLessonIndex() {
    return _lastSession?.lastLessonIndex ?? 0;
  }

  // Clear session (when user dismisses resume card)
  Future<void> clearLastSession() async {
    _lastSession = null;
    await SessionService().clearSession();
    notifyListeners();
  }

  // Check if course has recent progress
  bool hasRecentProgress(String courseId) {
    if (_lastSession == null) return false;

    return _lastSession!.lastActivityType == 'course' &&
        _lastSession!.lastActivityId == courseId &&
        _lastSession!.isRecent;
  }

  // Get progress summary for resume
  Map<String, dynamic>? getResumeProgress() {
    if (_lastSession != null && _lastSession!.lastActivityType == 'course') {
      final course = _getCourseForResume();
      if (course != null) {
        return {
          'course': course,
          'lessonIndex': _lastSession!.lastLessonIndex,
          'progressData': _lastSession!.activityData,
          'isRecent': _lastSession!.isRecent,
          'timeAgo': _getTimeAgo(_lastSession!.lastActivityTime),
        };
      }
    }
    return null;
  }

  // Force reload session
  Future<void> reloadSession() async {
    _hasLoadedSession = false;
    await _loadLastSession();
    notifyListeners();
  }

  // Enroll in course
  Future<void> enrollInCourse(String courseId) async {
    try {
      print('Enrolling in course: $courseId');

      // First update locally for immediate feedback
      final course = getCourseById(courseId);
      if (course != null && !isEnrolled(courseId)) {
        _enrolledCourses.add(Course(
          id: course.id,
          title: course.title,
          description: course.description,
          currentLesson: 0,
          totalLessons: course.totalLessons,
          progress: 0.0,
          category: course.category,
          instructor: course.instructor,
          imageUrl: course.imageUrl,
          isEnrolled: true,
          enrolledDate: DateTime.now(),
          difficulty: course.difficulty,
        ));
        notifyListeners();
      }

      // Then try Firebase - using safe method
      try {
        await _enrollInCourseInFirebase(FirebaseService.currentUserId, courseId);
      } catch (e) {
        print('Firebase enrollment failed, but local enrollment succeeded: $e');
      }

    } catch (e) {
      _error = 'Failed to enroll in course: $e';
      notifyListeners();
      rethrow;
    }
  }

  // NEW: Safe method to enroll in course in Firebase
  Future<void> _enrollInCourseInFirebase(String userId, String courseId) async {
    try {
      await FirebaseService.enrollInCourse(userId, courseId);
      print('Firebase enrollment successful');
    } catch (e) {
      print('Firebase enrollment failed: $e');
      // Don't rethrow - let local enrollment succeed
    }
  }

  // Unenroll from course
  Future<void> unenrollFromCourse(String courseId) async {
    try {
      // Remove locally first
      _enrolledCourses.removeWhere((c) => c.id == courseId);

      // Clear session if it was for this course
      if (_lastSession != null && _lastSession!.lastActivityId == courseId) {
        await clearLastSession();
      }

      notifyListeners();

      // Try Firebase - using safe method
      try {
        await _unenrollFromCourseInFirebase(FirebaseService.currentUserId, courseId);
      } catch (e) {
        print('Firebase unenrollment failed, but local removal succeeded: $e');
      }

    } catch (e) {
      _error = 'Failed to unenroll from course: $e';
      notifyListeners();
      rethrow;
    }
  }

  // NEW: Safe method to unenroll from course in Firebase
  Future<void> _unenrollFromCourseInFirebase(String userId, String courseId) async {
    try {
      await FirebaseService.unenrollFromCourse(userId, courseId);
      print('Firebase unenrollment successful');
    } catch (e) {
      print('Firebase unenrollment failed: $e');
      // Don't rethrow - let local removal succeed
    }
  }

  // Keep the original updateCourseProgress for backward compatibility
  Future<void> updateCourseProgress(String courseId, int completedLessons) async {
    await updateCourseProgressWithSession(courseId, completedLessons);
  }

  // Helper method for time display
  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }

  // NEW: Get statistics
  Map<String, dynamic> getStatistics() {
    return {
      'totalAvailableCourses': _availableCourses.length,
      'totalEnrolledCourses': _enrolledCourses.length,
      'totalProgress': _enrolledCourses.isEmpty ? 0 :
      _enrolledCourses.map((c) => c.progress).reduce((a, b) => a + b) / _enrolledCourses.length,
      'completedLessons': _enrolledCourses.isEmpty ? 0 :
      _enrolledCourses.map((c) => c.currentLesson).reduce((a, b) => a + b),
      'totalLessons': _enrolledCourses.isEmpty ? 0 :
      _enrolledCourses.map((c) => c.totalLessons).reduce((a, b) => a + b),
    };
  }
}