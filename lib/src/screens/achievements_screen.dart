import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/achievement_model.dart';
import '../providers/achievement_provider.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Load data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AchievementProvider>(context, listen: false).refreshData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Stats Overview Card
          _buildStatsOverview(),
          const SizedBox(height: 8),

          // Tabs
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF4361EE),
              unselectedLabelColor: const Color(0xFF6C757D),
              indicatorColor: const Color(0xFF4361EE),
              indicatorWeight: 3,
              tabs: const [
                Tab(text: 'Achievements'),
                Tab(text: 'Leaderboard'),
                Tab(text: 'Stats'),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAchievementsTab(),
                _buildLeaderboardTab(),
                _buildStatsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF4361EE),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Achievements',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Track your progress and compete',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview() {
    return Consumer<AchievementProvider>(
      builder: (context, achievementProvider, child) {
        final stats = achievementProvider.userStats;

        if (stats == null) {
          return const Card(
            margin: EdgeInsets.all(16),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        return Card(
          margin: const EdgeInsets.all(16),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(stats.totalXp.toString(), 'XP Points', Icons.emoji_events),
                    _buildStatItem('${stats.currentStreak}', 'Day Streak', Icons.local_fire_department),
                    _buildStatItem('${stats.totalStudyHours}h', 'Study Time', Icons.timer),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4361EE).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Global Rank: #${stats.rank}',
                    style: const TextStyle(
                      color: Color(0xFF4361EE),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF4361EE).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF4361EE), size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF212529),
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6C757D),
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementsTab() {
    return Consumer<AchievementProvider>(
      builder: (context, achievementProvider, child) {
        if (achievementProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final achievements = achievementProvider.achievements;
        final unlockedCount = achievements.where((a) => a.isUnlocked).length;
        final totalXp = achievements.where((a) => a.isUnlocked).fold(0, (sum, a) => sum + a.xpReward);

        return Column(
          children: [
            // Progress Header
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF4361EE).withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        '$unlockedCount/${achievements.length}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4361EE),
                        ),
                      ),
                      const Text(
                        'Achievements',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6C757D),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        '$totalXp XP',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4361EE),
                        ),
                      ),
                      const Text(
                        'Total Earned',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6C757D),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Achievements List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: achievements.length,
                itemBuilder: (context, index) {
                  final achievement = achievements[index];
                  return _buildAchievementCard(achievement);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: achievement.isUnlocked ? Colors.white : Colors.grey[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Achievement Icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: achievement.isUnlocked
                    ? const Color(0xFF4361EE).withOpacity(0.1)
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(25),
              ),
              child: Center(
                child: Text(
                  achievement.icon,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Achievement Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    achievement.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: achievement.isUnlocked
                          ? const Color(0xFF212529)
                          : const Color(0xFF6C757D),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    achievement.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: achievement.isUnlocked
                          ? const Color(0xFF6C757D)
                          : const Color(0xFFADB5BD),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: achievement.isUnlocked
                          ? const Color(0xFF4CAF50).withOpacity(0.1)
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '+${achievement.xpReward} XP',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: achievement.isUnlocked
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFF6C757D),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Status Indicator
            Icon(
              achievement.isUnlocked ? Icons.check_circle : Icons.lock,
              color: achievement.isUnlocked ? const Color(0xFF4CAF50) : const Color(0xFFADB5BD),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardTab() {
    return Consumer<AchievementProvider>(
      builder: (context, achievementProvider, child) {
        final leaderboard = achievementProvider.leaderboard;

        return Column(
          children: [
            // Leaderboard Header
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4361EE), Color(0xFF3A0CA3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.leaderboard, color: Colors.white, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Global Leaderboard',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Leaderboard List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: leaderboard.length,
                itemBuilder: (context, index) {
                  final user = leaderboard[index];
                  return _buildLeaderboardItem(user);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLeaderboardItem(LeaderboardUser user) {
    final isCurrentUser = user.name == 'You';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: isCurrentUser ? 4 : 1,
      color: isCurrentUser ? const Color(0xFF4361EE).withOpacity(0.05) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isCurrentUser
            ? const BorderSide(color: Color(0xFF4361EE), width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Rank
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _getRankColor(user.rank),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  user.rank.toString(),
                  style: TextStyle(
                    color: user.rank <= 3 ? Colors.white : const Color(0xFF212529),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.w500,
                      color: const Color(0xFF212529),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      _buildUserStat('${user.xpPoints} XP', Icons.emoji_events),
                      const SizedBox(width: 8),
                      _buildUserStat('${user.dayStreak}d', Icons.local_fire_department),
                      const SizedBox(width: 8),
                      _buildUserStat('${user.totalStudyHours}h', Icons.timer),
                    ],
                  ),
                ],
              ),
            ),

            // Trophy for top 3
            if (user.rank <= 3)
              Icon(
                Icons.emoji_events,
                color: _getTrophyColor(user.rank),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserStat(String value, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: const Color(0xFF6C757D)),
        const SizedBox(width: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF6C757D),
          ),
        ),
      ],
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return const Color(0xFFE9ECEF);
    }
  }

  Color _getTrophyColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700);
      case 2:
        return const Color(0xFFC0C0C0);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return const Color(0xFF6C757D);
    }
  }

  Widget _buildStatsTab() {
    return Consumer<AchievementProvider>(
      builder: (context, achievementProvider, child) {
        final stats = achievementProvider.userStats;

        if (stats == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildStatCard(
              'Learning Statistics',
              Icons.bar_chart,
              [
                _buildStatRow('Total XP Earned', '${stats.totalXp} XP'),
                _buildStatRow('Current Streak', '${stats.currentStreak} days'),
                _buildStatRow('Longest Streak', '${stats.longestStreak} days'),
                _buildStatRow('Total Study Time', '${stats.totalStudyHours} hours'),
                _buildStatRow('Courses Completed', '${stats.completedCourses}'),
                _buildStatRow('Lessons Completed', '${stats.completedLessons}'),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatCard(
              'Performance',
              Icons.trending_up,
              [
                _buildStatRow('Daily Average', '${(stats.totalStudyHours / 7).toStringAsFixed(1)} hours'),
                _buildStatRow('XP per Hour', '${(stats.totalXp / stats.totalStudyHours).toStringAsFixed(0)} XP/h'),
                _buildStatRow('Completion Rate', '${((stats.completedLessons / (stats.completedLessons + 10)) * 100).toStringAsFixed(0)}%'),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String title, IconData icon, List<Widget> stats) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF4361EE), size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF212529),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...stats,
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6C757D),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF212529),
            ),
          ),
        ],
      ),
    );
  }
}