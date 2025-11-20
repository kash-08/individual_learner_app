import 'package:flutter/foundation.dart';
import '../models/course_model.dart';
import '../models/session_model.dart'; // Add this import
import '../services/firebase_service.dart';
import '../services/session_service.dart'; // Add this import

class CourseProvider with ChangeNotifier {
  List<Course> _enrolledCourses = [];
  List<Course> _availableCourses = [];
  bool _isLoading = false;
  String? _error;

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

  Future<void> loadCourses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Initialize sample data on first load
      await FirebaseService.initializeSampleData();

      // Load courses from Firebase
      _availableCourses = await FirebaseService.getAllCourses();
      _enrolledCourses = await FirebaseService.getEnrolledCourses(FirebaseService.currentUserId);

      print('Loaded ${_availableCourses.length} available courses');
      print('Loaded ${_enrolledCourses.length} enrolled courses');

      // Load last session after courses are loaded
      if (!_hasLoadedSession) {
        await _loadLastSession();
        _hasLoadedSession = true;
      }

    } catch (e) {
      _error = 'Failed to load courses: $e';
      print('Error loading courses: $e');
      // Fallback to mock data
      _loadMockData();

      // Still try to load session with mock data
      if (!_hasLoadedSession) {
        await _loadLastSession();
        _hasLoadedSession = true;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // NEW: Load last session
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
      }
    } catch (e) {
      print('Error loading last session: $e');
    }
  }

  // NEW: Update course progress with session saving
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

        // Update Firebase
        try {
          await FirebaseService.updateCourseProgress(
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

  // NEW: Get course for resume functionality
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

  // NEW: Get last lesson index for resume
  int getLastLessonIndex() {
    return _lastSession?.lastLessonIndex ?? 0;
  }

  // NEW: Clear session (when user dismisses resume card)
  Future<void> clearLastSession() async {
    _lastSession = null;
    await SessionService().clearSession();
    notifyListeners();
  }

  // NEW: Check if course has recent progress
  bool hasRecentProgress(String courseId) {
    if (_lastSession == null) return false;

    return _lastSession!.lastActivityType == 'course' &&
        _lastSession!.lastActivityId == courseId &&
        _lastSession!.isRecent;
  }

  // NEW: Get progress summary for resume
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

  // NEW: Force reload session
  Future<void> reloadSession() async {
    _hasLoadedSession = false;
    await _loadLastSession();
    notifyListeners();
  }

  // Existing methods (updated to use session-aware progress when possible)
  Future<void> enrollInCourse(String courseId) async {
    try {
      await FirebaseService.enrollInCourse(FirebaseService.currentUserId, courseId);
      await loadCourses(); // Reload to reflect changes
    } catch (e) {
      _error = 'Failed to enroll in course: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> unenrollFromCourse(String courseId) async {
    try {
      await FirebaseService.unenrollFromCourse(FirebaseService.currentUserId, courseId);

      // Clear session if it was for this course
      if (_lastSession != null && _lastSession!.lastActivityId == courseId) {
        await clearLastSession();
      }

      await loadCourses(); // Reload to reflect changes
    } catch (e) {
      _error = 'Failed to unenroll from course: $e';
      notifyListeners();
      rethrow;
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

  // Fallback mock data
  void _loadMockData() {
    print('Loading mock data as fallback');
    _enrolledCourses = [
      Course(
        id: 'mock-1',
        title: 'React Native Fundamentals',
        description: 'Build mobile apps with React Native',
        currentLesson: 8,
        totalLessons: 12,
        progress: 0.65,
        category: 'Mobile Development',
        instructor: 'John Doe',
        imageUrl: 'https://via.placeholder.com/80x80/4361EE/FFFFFF?text=RN',
        isEnrolled: true,
        enrolledDate: DateTime(2024, 1, 15),
        difficulty: 'Intermediate',
      ),
    ];

    _availableCourses = [
      Course(
        id: 'mock-2',
        title: 'Flutter Advanced',
        description: 'Advanced Flutter concepts and patterns',
        currentLesson: 0,
        totalLessons: 10,
        progress: 0.0,
        category: 'Mobile Development',
        instructor: 'Jane Smith',
        imageUrl: 'https://via.placeholder.com/80x80/3A0CA3/FFFFFF?text=FL',
        isEnrolled: false,
        enrolledDate: DateTime.now(),
        difficulty: 'Advanced',
      ),
      Course(
        id: 'mock-3',
        title: 'Python for Data Science',
        description: 'Data analysis and visualization with Python',
        currentLesson: 0,
        totalLessons: 8,
        progress: 0.0,
        category: 'Data Science',
        instructor: 'Mike Johnson',
        imageUrl: 'https://via.placeholder.com/80x80/7209B7/FFFFFF?text=PY',
        isEnrolled: false,
        enrolledDate: DateTime.now(),
        difficulty: 'Beginner',
      ),
    ];
  }
}