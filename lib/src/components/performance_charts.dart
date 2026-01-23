// lib/widgets/performance_charts.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/profile_model.dart';

class PerformanceCharts extends StatefulWidget {
  final LearningAnalytics analytics;

  const PerformanceCharts({
    super.key,
    required this.analytics,
  });

  @override
  State<PerformanceCharts> createState() => _PerformanceChartsState();
}

class _PerformanceChartsState extends State<PerformanceCharts> {
  int _selectedChartIndex = 0;
  final List<String> _chartTypes = ['Scores', 'Study Time', 'Lessons', 'XP'];

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Performance Trends',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.calendar_today, size: 14),
                      SizedBox(width: 4),
                      Text('Last 7 Days'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Chart Type Selector
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _chartTypes.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(_chartTypes[index]),
                      selected: _selectedChartIndex == index,
                      onSelected: (selected) {
                        setState(() {
                          _selectedChartIndex = index;
                        });
                      },
                      selectedColor: const Color(0xFF4361EE),
                      labelStyle: TextStyle(
                        color: _selectedChartIndex == index
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Chart Container
            SizedBox(
              height: 250,
              child: _buildChart(),
            ),
            const SizedBox(height: 16),

            // Chart Legend
            _buildChartLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    switch (_selectedChartIndex) {
      case 0:
        return _buildScoreChart();
      case 1:
        return _buildStudyTimeChart();
      case 2:
        return _buildLessonsChart();
      case 3:
        return _buildXPChart();
      default:
        return _buildScoreChart();
    }
  }

  Widget _buildScoreChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < widget.analytics.weeklyPerformance.length) {
                  final date = widget.analytics.weeklyPerformance[index].date;
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
                return Text('${value.toInt()}%');
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: widget.analytics.weeklyPerformance.asMap().entries.map((entry) {
              return FlSpot(
                entry.key.toDouble(),
                entry.value.score,
              );
            }).toList(),
            isCurved: true,
            color: const Color(0xFF4361EE),
            barWidth: 3,
            isStrokeCapRound: true,
            belowBarData: BarAreaData(show: false),
            dotData: FlDotData(show: true),
          ),
        ],
      ),
    );
  }

  Widget _buildStudyTimeChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: widget.analytics.weeklyPerformance
            .map((e) => e.studyMinutes.toDouble())
            .reduce((a, b) => a > b ? a : b) *
            1.1,
        barGroups: widget.analytics.weeklyPerformance.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.studyMinutes.toDouble(),
                color: const Color(0xFF4361EE),
                width: 16,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < widget.analytics.weeklyPerformance.length) {
                  final date = widget.analytics.weeklyPerformance[index].date;
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
                return Text('${value.toInt()}m');
              },
            ),
          ),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  Widget _buildLessonsChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: widget.analytics.weeklyPerformance
            .map((e) => e.completedLessons.toDouble())
            .reduce((a, b) => a > b ? a : b) *
            1.5,
        barGroups: widget.analytics.weeklyPerformance.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.completedLessons.toDouble(),
                color: Colors.green,
                width: 16,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < widget.analytics.weeklyPerformance.length) {
                  final date = widget.analytics.weeklyPerformance[index].date;
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
                return Text('${value.toInt()}');
              },
            ),
          ),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  Widget _buildXPChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < widget.analytics.weeklyPerformance.length) {
                  final date = widget.analytics.weeklyPerformance[index].date;
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
                return Text('${value.toInt()}');
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: widget.analytics.weeklyPerformance.asMap().entries.map((entry) {
              return FlSpot(
                entry.key.toDouble(),
                entry.value.xpEarned.toDouble(),
              );
            }).toList(),
            isCurved: true,
            color: Colors.orange,
            barWidth: 3,
            isStrokeCapRound: true,
            belowBarData: BarAreaData(
              show: true,
              color: Colors.orange.withOpacity(0.1),
            ),
            dotData: FlDotData(show: true),
          ),
        ],
      ),
    );
  }

  Widget _buildChartLegend() {
    final colors = [
      const Color(0xFF4361EE),
      Colors.green,
      Colors.orange,
      Colors.purple,
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: _chartTypes.asMap().entries.map((entry) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: colors[entry.key % colors.length],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              entry.value,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        );
      }).toList(),
    );
  }

  String _getDayLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (date.year == today.year &&
        date.month == today.month &&
        date.day == today.day) {
      return 'Today';
    } else {
      return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][date.weekday - 1];
    }
  }
}