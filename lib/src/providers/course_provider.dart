import 'package:flutter/foundation.dart';
import '../models/course_model.dart';

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

    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock data - replace with Firebase later
    _loadMockData();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> enrollInCourse(String courseId) async {
    try {
      final courseIndex = _availableCourses.indexWhere((course) => course.id == courseId);
      if (courseIndex != -1) {
        final course = _availableCourses[courseIndex];
        final enrolledCourse = Course(
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
        );

        _enrolledCourses.add(enrolledCourse);
        _availableCourses.removeAt(courseIndex);
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to enroll in course: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> unenrollFromCourse(String courseId) async {
    try {
      final courseIndex = _enrolledCourses.indexWhere((course) => course.id == courseId);
      if (courseIndex != -1) {
        final course = _enrolledCourses[courseIndex];
        final availableCourse = Course(
          id: course.id,
          title: course.title,
          description: course.description,
          currentLesson: 0,
          totalLessons: course.totalLessons,
          progress: 0.0,
          category: course.category,
          instructor: course.instructor,
          imageUrl: course.imageUrl,
          isEnrolled: false,
          enrolledDate: DateTime.now(),
          difficulty: course.difficulty,
        );

        _availableCourses.add(availableCourse);
        _enrolledCourses.removeAt(courseIndex);
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to unenroll from course: $e';
      notifyListeners();
      rethrow;
    }
  }

  void _loadMockData() {
    _enrolledCourses = [
      Course(
        id: '1',
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
        id: '2',
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
        id: '3',
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
      Course(
        id: '4',
        title: 'JavaScript Mastery',
        description: 'Complete JavaScript guide from basics to advanced',
        currentLesson: 0,
        totalLessons: 15,
        progress: 0.0,
        category: 'Web Development',
        instructor: 'Sarah Wilson',
        imageUrl: 'https://via.placeholder.com/80x80/4CC9F0/FFFFFF?text=JS',
        isEnrolled: false,
        enrolledDate: DateTime.now(),
        difficulty: 'Beginner',
      ),
    ];
  }
}