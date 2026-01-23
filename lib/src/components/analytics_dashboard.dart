// lib/widgets/analytics_dashboard.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/profile_model.dart';

class AnalyticsDashboard extends StatelessWidget {
  final LearningAnalytics analytics;

  const AnalyticsDashboard({
    super.key,
    required this.analytics,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Weekly Progress Chart
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Weekly Progress',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Study time vs. Lessons completed',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          tooltipBgColor: Colors.white,
                          tooltipBorder: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      gridData: FlGridData(show: true),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= 0 &&
                                  value.toInt() < analytics.weeklyPerformance.length) {
                                final date =
                                    analytics.weeklyPerformance[value.toInt()].date;
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    _getDayLabel(date),
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt() % 20 == 0 ? '${value.toInt()}' : '',
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      minX: 0,
                      maxX: analytics.weeklyPerformance.length - 1,
                      minY: 0,
                      maxY: 100,
                      lineBarsData: [
                        // Study Time Line
                        LineChartBarData(
                          spots: analytics.weeklyPerformance.asMap().entries.map((entry) {
                            return FlSpot(
                              entry.key.toDouble(),
                              entry.value.studyMinutes.toDouble(),
                            );
                          }).toList(),
                          isCurved: true,
                          color: const Color(0xFF4361EE),
                          barWidth: 3,
                          isStrokeCapRound: true,
                          belowBarData: BarAreaData(show: false),
                          dotData: FlDotData(show: true),
                        ),
                        // Lessons Line
                        LineChartBarData(
                          spots: analytics.weeklyPerformance.asMap().entries.map((entry) {
                            return FlSpot(
                              entry.key.toDouble(),
                              entry.value.completedLessons.toDouble() * 10,
                            );
                          }).toList(),
                          isCurved: true,
                          color: Colors.green,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          belowBarData: BarAreaData(show: false),
                          dotData: FlDotData(show: true),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLegendItem(
                      color: const Color(0xFF4361EE),
                      label: 'Study Time (min)',
                    ),
                    const SizedBox(width: 20),
                    _buildLegendItem(
                      color: Colors.green,
                      label: 'Lessons (x10)',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Performance Metrics Grid
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildMetricCard(
              title: 'Average Daily Score',
              value: '${analytics.averageScore.toStringAsFixed(1)}%',
              icon: Icons.trending_up,
              color: Colors.green,
              trend: _calculateTrend('score'),
            ),
            _buildMetricCard(
              title: 'Total XP Earned',
              value: analytics.totalXpEarned.toString(),
              icon: Icons.workspace_premium,
              color: Colors.orange,
              trend: _calculateTrend('xp'),
            ),
            _buildMetricCard(
              title: 'Consistency Score',
              value: '${analytics.consistencyScore.toStringAsFixed(1)}%',
              icon: Icons.trending_up,
              color: Colors.purple,
              trend: _calculateTrend('consistency'),
            ),
            _buildMetricCard(
              title: 'Study Streak',
              value: '${_calculateStreak()} days',
              icon: Icons.local_fire_department,
              color: Colors.red,
              trend: '+2',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem({required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String trend,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: trend.startsWith('+')
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  trend,
                  style: TextStyle(
                    color: trend.startsWith('+') ? Colors.green : Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  String _getDayLabel(DateTime date) {
    return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][date.weekday - 1];
  }

  String _calculateTrend(String metric) {
    // Simplified trend calculation
    // In a real app, you would compare with previous period
    final random = DateTime.now().microsecondsSinceEpoch % 10;
    return random > 5 ? '+${random - 4}%' : '-${random}%';
  }

  int _calculateStreak() {
    // Simplified streak calculation
    // In a real app, you would calculate actual streak from user data
    return 7; // Mock 7-day streak
  }
}