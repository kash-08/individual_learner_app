// lib/models/user_model.dart
class User {
  final String id;
  String name;
  String email;
  String? profileImageUrl;
  int xpPoints;
  int dayStreak;
  double studyTimeThisWeek;
  DateTime? joinDate;
  List<String>? interests;
  Map<String, dynamic>? preferences;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profileImageUrl,
    required this.xpPoints,
    required this.dayStreak,
    required this.studyTimeThisWeek,
    this.joinDate,
    this.interests,
    this.preferences,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'xpPoints': xpPoints,
      'dayStreak': dayStreak,
      'studyTimeThisWeek': studyTimeThisWeek,
      'joinDate': joinDate?.toIso8601String(),
      'interests': interests,
      'preferences': preferences,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      profileImageUrl: map['profileImageUrl'],
      xpPoints: map['xpPoints'] ?? 0,
      dayStreak: map['dayStreak'] ?? 0,
      studyTimeThisWeek: map['studyTimeThisWeek']?.toDouble() ?? 0.0,
      joinDate: map['joinDate'] != null
          ? DateTime.parse(map['joinDate'])
          : null,
      interests: List<String>.from(map['interests'] ?? []),
      preferences: map['preferences'] ?? {},
    );
  }
}