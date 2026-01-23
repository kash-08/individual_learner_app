// lib/models/profile_model.dart
class UserProfile {
  final String userId;
  String name;
  String email;
  String? profileImageUrl;
  String? bio;
  String? studyFocus;
  String? educationLevel;
  String? preferredLanguage;
  DateTime? joinDate;
  Map<String, dynamic> preferences;
  List<String> interests;

  UserProfile({
    required this.userId,
    required this.name,
    required this.email,
    this.profileImageUrl,
    this.bio,
    this.studyFocus,
    this.educationLevel,
    this.preferredLanguage,
    this.joinDate,
    this.preferences = const {},
    this.interests = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'bio': bio,
      'studyFocus': studyFocus,
      'educationLevel': educationLevel,
      'preferredLanguage': preferredLanguage,
      'joinDate': joinDate?.toIso8601String(),
      'preferences': preferences,
      'interests': interests,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      profileImageUrl: map['profileImageUrl'],
      bio: map['bio'],
      studyFocus: map['studyFocus'],
      educationLevel: map['educationLevel'],
      preferredLanguage: map['preferredLanguage'],
      joinDate: map['joinDate'] != null
          ? DateTime.parse(map['joinDate'])
          : null,
      preferences: map['preferences'] ?? {},
      interests: List<String>.from(map['interests'] ?? []),
    );
  }
}

class PerformanceMetric {
  final DateTime date;
  final double score;
  final int studyMinutes;
  final int completedLessons;
  final int xpEarned;

  PerformanceMetric({
    required this.date,
    required this.score,
    required this.studyMinutes,
    required this.completedLessons,
    required this.xpEarned,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'score': score,
      'studyMinutes': studyMinutes,
      'completedLessons': completedLessons,
      'xpEarned': xpEarned,
    };
  }

  factory PerformanceMetric.fromMap(Map<String, dynamic> map) {
    return PerformanceMetric(
      date: DateTime.parse(map['date']),
      score: map['score']?.toDouble() ?? 0.0,
      studyMinutes: map['studyMinutes'] ?? 0,
      completedLessons: map['completedLessons'] ?? 0,
      xpEarned: map['xpEarned'] ?? 0,
    );
  }
}

class LearningAnalytics {
  final double averageScore;
  final int totalStudyHours;
  final int totalLessonsCompleted;
  final int totalXpEarned;
  final double consistencyScore;
  final Map<String, int> categoryBreakdown;
  final List<PerformanceMetric> weeklyPerformance;

  LearningAnalytics({
    required this.averageScore,
    required this.totalStudyHours,
    required this.totalLessonsCompleted,
    required this.totalXpEarned,
    required this.consistencyScore,
    required this.categoryBreakdown,
    required this.weeklyPerformance,
  });
}