class User {
  final String id;
  final String name;
  final String email;
  final int xpPoints;
  final int dayStreak;
  final double studyTimeThisWeek;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.xpPoints,
    required this.dayStreak,
    required this.studyTimeThisWeek,
  });
}