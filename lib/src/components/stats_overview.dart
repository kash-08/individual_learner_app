// lib/widgets/stats_overview.dart
import 'package:flutter/material.dart';
import '../models/profile_model.dart';

class StatsOverview extends StatelessWidget {
  final LearningAnalytics analytics;
  final UserProfile userProfile;

  const StatsOverview({
    super.key,
    required this.analytics,
    required this.userProfile,
  });

  BuildContext? get context => null;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Learning Statistics',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            // Main Stats Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildStatCard(
                  title: 'Avg. Score',
                  value: '${analytics.averageScore.toStringAsFixed(1)}%',
                  icon: Icons.score,
                  color: Colors.green,
                  progress: analytics.averageScore / 100,
                ),
                _buildStatCard(
                  title: 'Total Study Hours',
                  value: '${analytics.totalStudyHours}h',
                  icon: Icons.timer,
                  color: Colors.blue,
                  progress: analytics.totalStudyHours / 100,
                ),
                _buildStatCard(
                  title: 'Lessons Completed',
                  value: analytics.totalLessonsCompleted.toString(),
                  icon: Icons.check_circle,
                  color: Colors.purple,
                  progress: analytics.totalLessonsCompleted / 100,
                ),
                _buildStatCard(
                  title: 'Consistency',
                  value: '${analytics.consistencyScore.toStringAsFixed(1)}%',
                  icon: Icons.trending_up,
                  color: Colors.orange,
                  progress: analytics.consistencyScore / 100,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Category Breakdown
            Text(
              'Learning Distribution',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _buildCategoryBreakdown(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required double progress,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withOpacity(0.1),
            color: color,
            borderRadius: BorderRadius.circular(4),
            minHeight: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown() {
    final total = analytics.categoryBreakdown.values
        .fold(0, (sum, value) => sum + value);

    return Column(
      children: analytics.categoryBreakdown.entries.map((entry) {
        final percentage = (entry.value / total * 100).round();

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '$percentage%',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Stack(
                children: [
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Container(
                    height: 8,
                    width: (MediaQuery.of(context!).size.width - 72) * (percentage / 100),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(entry.key),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getCategoryColor(String category) {
    final colors = {
      'Programming': Colors.blue,
      'Mathematics': Colors.purple,
      'Science': Colors.green,
      'Languages': Colors.orange,
    };
    return colors[category] ?? Colors.grey;
  }
}