import 'package:flutter/foundation.dart';
import '../models/achievement_model.dart';
import '../models/user_model.dart';

class AchievementProvider with ChangeNotifier {
  List<Achievement> _achievements = [];
  List<LeaderboardUser> _leaderboard = [];
  UserStats? _userStats;
  bool _isLoading = false;

  List<Achievement> get achievements => _achievements;
  List<LeaderboardUser> get leaderboard => _leaderboard;
  UserStats? get userStats => _userStats;
  bool get isLoading => _isLoading;

  Future<void> loadAchievements() async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 1000));

    // Mock achievements data
    _achievements = [
      Achievement(
        id: '1',
        title: 'First Steps',
        description: 'Complete your first lesson',
        icon: '🎯',
        xpReward: 50,
        isUnlocked: true,
        unlockedAt: DateTime.now().subtract(const Duration(days: 2)),
        category: 'learning',
      ),
      Achievement(
        id: '2',
        title: 'Week Warrior',
        description: 'Maintain a 7-day streak',
        icon: '🔥',
        xpReward: 100,
        isUnlocked: true,
        unlockedAt: DateTime.now().subtract(const Duration(days: 1)),
        category: 'consistency',
      ),
      Achievement(
        id: '3',
        title: 'Bookworm',
        description: 'Study for 10 hours total',
        icon: '📚',
        xpReward: 200,
        isUnlocked: false,
        category: 'dedication',
      ),
      Achievement(
        id: '4',
        title: 'Speed Learner',
        description: 'Complete 5 lessons in one day',
        icon: '⚡',
        xpReward: 150,
        isUnlocked: false,
        category: 'performance',
      ),
      Achievement(
        id: '5',
        title: 'Course Master',
        description: 'Complete your first course',
        icon: '🏆',
        xpReward: 500,
        isUnlocked: false,
        category: 'completion',
      ),
      Achievement(
        id: '6',
        title: 'Early Bird',
        description: 'Study before 8 AM for 5 days',
        icon: '🌅',
        xpReward: 100,
        isUnlocked: false,
        category: 'habits',
      ),
    ];

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadLeaderboard() async {
    // Mock leaderboard data
    _leaderboard = [
      LeaderboardUser(
        id: '1',
        name: 'Alex Johnson',
        xpPoints: 2847,
        dayStreak: 14,
        totalStudyHours: 28.5,
        rank: 1,
        avatarUrl: null,
      ),
      LeaderboardUser(
        id: '2',
        name: 'Sarah Chen',
        xpPoints: 2650,
        dayStreak: 12,
        totalStudyHours: 25.2,
        rank: 2,
        avatarUrl: null,
      ),
      LeaderboardUser(
        id: '3',
        name: 'Mike Rodriguez',
        xpPoints: 2341,
        dayStreak: 9,
        totalStudyHours: 22.8,
        rank: 3,
        avatarUrl: null,
      ),
      LeaderboardUser(
        id: '4',
        name: 'You',
        xpPoints: 1247,
        dayStreak: 7,
        totalStudyHours: 12.5,
        rank: 15,
        avatarUrl: null,
      ),
      LeaderboardUser(
        id: '5',
        name: 'Emma Wilson',
        xpPoints: 1987,
        dayStreak: 8,
        totalStudyHours: 19.3,
        rank: 4,
        avatarUrl: null,
      ),
    ];

    notifyListeners();
  }

  Future<void> loadUserStats() async {
    // Mock user stats
    _userStats = UserStats(
      totalXp: 1247,
      currentStreak: 7,
      longestStreak: 7,
      totalStudyHours: 12.5,
      completedCourses: 2,
      completedLessons: 24,
      rank: 15,
    );

    notifyListeners();
  }

  Future<void> refreshData() async {
    await Future.wait([
      loadAchievements(),
      loadLeaderboard(),
      loadUserStats(),
    ]);
  }
}

class UserStats {
  final int totalXp;
  final int currentStreak;
  final int longestStreak;
  final double totalStudyHours;
  final int completedCourses;
  final int completedLessons;
  final int rank;

  UserStats({
    required this.totalXp,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalStudyHours,
    required this.completedCourses,
    required this.completedLessons,
    required this.rank,
  });
}