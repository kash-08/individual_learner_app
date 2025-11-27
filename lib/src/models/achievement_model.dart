class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int xpReward;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final String category;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.xpReward,
    required this.isUnlocked,
    this.unlockedAt,
    required this.category,
  });
}

class LeaderboardUser {
  final String id;
  final String name;
  final String? avatarUrl;
  final int xpPoints;
  final int dayStreak;
  final double totalStudyHours;
  final int rank;

  LeaderboardUser({
    required this.id,
    required this.name,
    required this.xpPoints,
    required this.dayStreak,
    required this.totalStudyHours,
    required this.rank,
    this.avatarUrl,
  });
}