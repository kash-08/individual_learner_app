class UserSession {
  final String userId;
  final DateTime lastActivityTime;
  final String lastActivityType; // 'course', 'quiz', 'ai_assistant', etc.
  final String lastActivityId; // courseId, quizId, etc.
  final int lastLessonIndex; // For courses - which lesson was last
  final Map<String, dynamic> activityData; // Additional activity-specific data

  const UserSession({
    required this.userId,
    required this.lastActivityTime,
    required this.lastActivityType,
    required this.lastActivityId,
    required this.lastLessonIndex,
    this.activityData = const {},
  });

  factory UserSession.fromMap(Map<String, dynamic> map) {
    return UserSession(
      userId: map['userId'] ?? '',
      lastActivityTime: DateTime.parse(map['lastActivityTime']),
      lastActivityType: map['lastActivityType'] ?? '',
      lastActivityId: map['lastActivityId'] ?? '',
      lastLessonIndex: map['lastLessonIndex'] ?? 0,
      activityData: Map<String, dynamic>.from(map['activityData'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'lastActivityTime': lastActivityTime.toIso8601String(),
      'lastActivityType': lastActivityType,
      'lastActivityId': lastActivityId,
      'lastLessonIndex': lastLessonIndex,
      'activityData': activityData,
    };
  }

  // Check if session is still valid (within 24 hours)
  bool get isValid {
    final now = DateTime.now();
    final difference = now.difference(lastActivityTime);
    return difference.inHours <= 24;
  }

  // Check if session was recent (within 1 hour)
  bool get isRecent {
    final now = DateTime.now();
    final difference = now.difference(lastActivityTime);
    return difference.inMinutes <= 60;
  }
}