class UserModel {
  final String id;
  final String name;
  final String email;
  final String? profileImageUrl;
  final int xpPoints;
  final int dayStreak;
  final double studyTimeThisWeek;
  final List<String> enrolledCourses;
  final List<String> completedQuizzes;
  final DateTime? createdAt;
  final DateTime? lastUpdated;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.profileImageUrl,
    required this.xpPoints,
    required this.dayStreak,
    required this.studyTimeThisWeek,
    required this.enrolledCourses,
    required this.completedQuizzes,
    this.createdAt,
    this.lastUpdated,
  });
}