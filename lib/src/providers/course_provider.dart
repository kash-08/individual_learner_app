import 'package:flutter/foundation.dart';
import '../models/course_model.dart';
import '../services/firebase_service.dart';

class CourseProvider with ChangeNotifier {
  List<Course> _enrolledCourses = [];
  List<Course> _availableCourses = [];
  bool _isLoading = false;
  String? _error;

  List<Course> get enrolledCourses => _enrolledCourses;
  List<Course> get availableCourses => _availableCourses;
  bool get isLoading => _isLoading;
  String? get error => _error;

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
    } catch (e) {
      _error = 'Failed to load courses: $e';
      print('Error loading courses: $e');
      // Fallback to mock data
      _loadMockData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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
      await loadCourses(); // Reload to reflect changes
    } catch (e) {
      _error = 'Failed to unenroll from course: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateCourseProgress(String courseId, int completedLessons) async {
    try {
      final course = _enrolledCourses.firstWhere((c) => c.id == courseId);
      final newProgress = completedLessons / course.totalLessons;

      await FirebaseService.updateCourseProgress(
          FirebaseService.currentUserId,
          courseId,
          completedLessons,
          newProgress
      );

      await loadCourses(); // Reload to reflect changes
    } catch (e) {
      _error = 'Failed to update progress: $e';
      notifyListeners();
      rethrow;
    }
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