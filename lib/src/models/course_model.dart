class Course {
  final String id;
  final String title;
  final String description;
  final int currentLesson;
  final int totalLessons;
  final double progress;
  final String category;

  const Course({
    required this.id,
    required this.title,
    required this.description,
    required this.currentLesson,
    required this.totalLessons,
    required this.progress,
    required this.category,
  });
}