class Course {
  final String id;
  final String title;
  final String description;
  final int currentLesson;
  final int totalLessons;
  final double progress;
  final String category;
  final String instructor;
  final String imageUrl;
  final bool isEnrolled;
  final DateTime enrolledDate;
  final String difficulty;

  const Course({
    required this.id,
    required this.title,
    required this.description,
    required this.currentLesson,
    required this.totalLessons,
    required this.progress,
    required this.category,
    required this.instructor,
    required this.imageUrl,
    required this.isEnrolled,
    required this.enrolledDate,
    required this.difficulty,
  });

  // Convert to map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'currentLesson': currentLesson,
      'totalLessons': totalLessons,
      'progress': progress,
      'category': category,
      'instructor': instructor,
      'imageUrl': imageUrl,
      'isEnrolled': isEnrolled,
      'enrolledDate': enrolledDate.millisecondsSinceEpoch,
      'difficulty': difficulty,
    };
  }

  // Create from Firebase data
  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      currentLesson: map['currentLesson'] ?? 0,
      totalLessons: map['totalLessons'] ?? 0,
      progress: map['progress']?.toDouble() ?? 0.0,
      category: map['category'] ?? '',
      instructor: map['instructor'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      isEnrolled: map['isEnrolled'] ?? false,
      enrolledDate: DateTime.fromMillisecondsSinceEpoch(map['enrolledDate'] ?? 0),
      difficulty: map['difficulty'] ?? 'Beginner',
    );
  }
}