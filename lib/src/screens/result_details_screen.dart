import 'package:flutter/material.dart';
import '../models/exam_model.dart';
import 'package:share_plus/share_plus.dart';

class ResultDetailsScreen extends StatelessWidget {
  final QuizResult result;
  final String userName;
  final String userEmail;

  const ResultDetailsScreen({
    Key? key,
    required this.result,
    required this.userName,
    required this.userEmail,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Debug logging
    print('ResultDetailsScreen: Building with result data');
    print('Quiz Name: ${result.quizName}');
    print('Score: ${result.score}');
    print('Percentage: ${result.percentage}');
    print('User: $userName');

    // Check if result is valid
    if (_isResultInvalid()) {
      return _buildErrorScreen(context);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Results'),
        backgroundColor: const Color(0xFF4361EE),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: _buildMainContent(context),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Info Card
          _buildUserInfoCard(context),
          const SizedBox(height: 16),

          // Result Summary Card
          _buildResultSummaryCard(context),
          const SizedBox(height: 20),

          // Performance Analysis Card
          _buildPerformanceAnalysisCard(context),
          const SizedBox(height: 20),

          // Detailed Results Section
          _buildDetailedResultsSection(context),
          const SizedBox(height: 20),

          // Personal Achievement Message
          _buildAchievementMessage(context),
          const SizedBox(height: 20),

          // Action Buttons
          _buildActionButtons(context),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildUserInfoCard(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFF4361EE).withOpacity(0.1),
              child: const Icon(
                Icons.person,
                color: Color(0xFF4361EE),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212529),
                    ),
                  ),
                  if (userEmail.isNotEmpty)
                    Text(
                      userEmail,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  const SizedBox(height: 4),
                  const Text(
                    'Assessment Completed',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF4361EE).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'ID: ${result.id.substring(0, result.id.length > 8 ? 8 : result.id.length)}',
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF4361EE),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultSummaryCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Quiz Completed!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212529),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Great job, $userName!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),

            // Score Circle
            _buildScoreCircle(),
            const SizedBox(height: 16),

            // Grade
            _buildGradeSection(),
            const SizedBox(height: 16),

            // Quiz Info
            _buildQuizInfoSection(),
            const SizedBox(height: 16),

            // Stats
            _buildStatsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCircle() {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: _getScoreGradient(result.percentage),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${result.percentage.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${result.score} points',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          if (result.percentage >= 70)
            const Positioned(
              top: 10,
              right: 10,
              child: CircleAvatar(
                radius: 12,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.star,
                  size: 16,
                  color: Colors.yellow,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGradeSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _getGradeGradient(result.grade),
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _getGradeColor(result.grade).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.emoji_events,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Your Grade: ${result.grade}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.emoji_events,
            color: Colors.white,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildQuizInfoSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildInfoRow('Quiz:', result.quizName),
          const SizedBox(height: 4),
          _buildInfoRow('Type:', result.quizType, isType: true),
          const SizedBox(height: 4),
          _buildInfoRow('Date:', _formatDate(result.completedAt)),
          const SizedBox(height: 4),
          _buildInfoRow('Time Spent:', _formatTime(result.timeSpent)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isType = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        if (isType)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: _getTypeColor(value),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          )
        else
          Text(
            value,
            style: label == 'Time Spent:'
                ? TextStyle(
              color: Colors.blue[700],
              fontWeight: FontWeight.w500,
            )
                : null,
          ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(
          'Correct Answers',
          '${result.correctAnswers}/${result.totalQuestions}',
          Colors.green,
          Icons.check_circle,
          'Your Score',
        ),
        _buildStatItem(
          'Accuracy Rate',
          '${_calculateAccuracy(result).toStringAsFixed(1)}%',
          Colors.blue,
          Icons.bar_chart,
          'Performance',
        ),
        _buildStatItem(
          'Avg Time',
          '${_calculateSpeedPerQuestion(result).toStringAsFixed(1)}s',
          Colors.orange,
          Icons.timer,
          'Per Question',
        ),
      ],
    );
  }

  Widget _buildPerformanceAnalysisCard(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics, color: Color(0xFF4361EE)),
                const SizedBox(width: 8),
                const Text(
                  'Performance Analysis',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildPerformanceMetric(
              'Answer Speed',
              '${_calculateSpeedPerQuestion(result).toStringAsFixed(1)} seconds per question',
              _getSpeedRating(result),
              Icons.speed,
              result.percentage > 50 ? Colors.green : Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildPerformanceMetric(
              'Accuracy Level',
              '${_calculateAccuracy(result).toStringAsFixed(1)}% correct answers',
              _getAccuracyRating(result),
              Icons.percent,
              _getAccuracyColor(result),
            ),
            const SizedBox(height: 12),
            _buildPerformanceMetric(
              'Completion Time',
              _formatDetailedTime(result.timeSpent),
              'On Schedule',
              Icons.calendar_today,
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildPerformanceMetric(
              'Questions Attempted',
              '${result.totalQuestions}/${result.totalQuestions}',
              'Full Attempt',
              Icons.question_answer,
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedResultsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detailed Results',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF212529),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Review your answers below:',
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),

        // Question Results
        ..._buildQuestionResults(),
      ],
    );
  }

  Widget _buildAchievementMessage(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF4361EE).withOpacity(0.1),
            const Color(0xFF3A0CA3).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF4361EE).withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            result.percentage >= 70 ? Icons.emoji_events : Icons.thumb_up,
            color: const Color(0xFF4361EE),
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.percentage >= 70
                      ? 'Excellent Work, $userName!'
                      : 'Keep Going, $userName!',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212529),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  result.percentage >= 70
                      ? 'You\'re making great progress in your learning journey!'
                      : 'Every attempt brings you closer to mastery. Try again for better results!',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4361EE),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.home, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text('Back to Home', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(color: Color(0xFF4361EE)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.assignment, color: Color(0xFF4361EE), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'More Assessments',
                      style: TextStyle(color: Color(0xFF4361EE)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              _showShareOptions(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.share, color: Colors.white),
            label: const Text(
              'Share Your Results',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  // Helper Widgets
  Widget _buildStatItem(String title, String value, Color color, IconData icon, String subtitle) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceMetric(String title, String value, String rating, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _getRatingColor(rating),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              rating,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildQuestionResults() {
    if (result.questionResults == null || result.questionResults!.isEmpty) {
      return [
        Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Icon(Icons.info, color: Colors.grey, size: 48),
                const SizedBox(height: 12),
                Text(
                  'Detailed question results are not available',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        )
      ];
    }

    return result.questionResults!.asMap().entries.map((entry) {
      final index = entry.key;
      final qResult = entry.value;
      final isCorrect = qResult['isCorrect'] == true;

      return Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isCorrect ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isCorrect ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isCorrect ? Colors.green : Colors.red,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isCorrect ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      qResult['question']?.toString() ?? 'Question ${index + 1}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Answer Status
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isCorrect ? Colors.green.withOpacity(0.05) : Colors.red.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(
                      isCorrect ? Icons.check_circle : Icons.cancel,
                      color: isCorrect ? Colors.green : Colors.red,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isCorrect ? 'Correct Answer' : 'Incorrect Answer',
                      style: TextStyle(
                        color: isCorrect ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                    const Spacer(),
                    if (qResult['points'] != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isCorrect ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${qResult['points']} pts',
                          style: TextStyle(
                            fontSize: 11,
                            color: isCorrect ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // User's Selected Answer
              if (qResult['selectedAnswer'] != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Your answer: ${qResult['selectedAnswer']}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],

              // Correct Answer (if incorrect)
              if (!isCorrect && qResult['correctAnswer'] != null) ...[
                const SizedBox(height: 6),
                Text(
                  'Correct answer: ${qResult['correctAnswer']}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.green[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],

              // Explanation
              if (qResult['explanation'] != null && qResult['explanation'].toString().isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Explanation:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        qResult['explanation'].toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Time Spent
              if (qResult['timeSpent'] != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.timer, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      'Time spent: ${qResult['timeSpent']} seconds',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      );
    }).toList();
  }

  // Helper Methods
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    if (minutes > 0) {
      return '${minutes}m ${remainingSeconds}s';
    }
    return '${remainingSeconds}s';
  }

  String _formatDetailedTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    if (minutes > 0) {
      return '${minutes} minute${minutes > 1 ? 's' : ''} ${remainingSeconds} second${remainingSeconds != 1 ? 's' : ''}';
    }
    return '${seconds} second${seconds != 1 ? 's' : ''}';
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/$year at $hour:$minute';
  }

  double _calculateAccuracy(QuizResult result) {
    if (result.totalQuestions == 0) return 0.0;
    return (result.correctAnswers / result.totalQuestions * 100);
  }

  double _calculateSpeedPerQuestion(QuizResult result) {
    if (result.totalQuestions == 0) return 0.0;
    return (result.timeSpent / result.totalQuestions);
  }

  String _getSpeedRating(QuizResult result) {
    final speed = _calculateSpeedPerQuestion(result);
    if (speed < 30) return 'Fast';
    if (speed < 60) return 'Good';
    if (speed < 90) return 'Average';
    return 'Slow';
  }

  String _getAccuracyRating(QuizResult result) {
    final accuracy = _calculateAccuracy(result);
    if (accuracy >= 90) return 'Excellent';
    if (accuracy >= 80) return 'Good';
    if (accuracy >= 70) return 'Average';
    if (accuracy >= 60) return 'Fair';
    return 'Needs Practice';
  }

  List<Color> _getScoreGradient(double percentage) {
    if (percentage >= 90) {
      return [Colors.green, Colors.green.shade700];
    } else if (percentage >= 80) {
      return [Colors.blue, Colors.blue.shade700];
    } else if (percentage >= 70) {
      return [Colors.orange, Colors.orange.shade700];
    } else if (percentage >= 60) {
      return [Colors.amber, Colors.amber.shade700];
    } else {
      return [Colors.red, Colors.red.shade700];
    }
  }

  List<Color> _getGradeGradient(String grade) {
    switch (grade) {
      case 'A':
        return [Colors.green, Colors.green.shade700];
      case 'B':
        return [Colors.blue, Colors.blue.shade700];
      case 'C':
        return [Colors.orange, Colors.orange.shade700];
      case 'D':
        return [Colors.amber, Colors.amber.shade700];
      default:
        return [Colors.red, Colors.red.shade700];
    }
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A':
        return Colors.green;
      case 'B':
        return Colors.blue;
      case 'C':
        return Colors.orange;
      case 'D':
        return Colors.amber;
      default:
        return Colors.red;
    }
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'quiz':
        return Colors.blue;
      case 'coding':
        return Colors.green;
      case 'exam':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Color _getAccuracyColor(QuizResult result) {
    final accuracy = _calculateAccuracy(result);
    if (accuracy >= 90) return Colors.green;
    if (accuracy >= 80) return Colors.blue;
    if (accuracy >= 70) return Colors.orange;
    if (accuracy >= 60) return Colors.amber;
    return Colors.red;
  }

  Color _getRatingColor(String rating) {
    final ratingLower = rating.toLowerCase();
    if (ratingLower.contains('excellent')) return Colors.green;
    if (ratingLower.contains('good')) return Colors.blue;
    if (ratingLower.contains('average')) return Colors.orange;
    if (ratingLower.contains('fair')) return Colors.amber;
    if (ratingLower.contains('improvement') || ratingLower.contains('needs practice')) return Colors.red;
    if (ratingLower.contains('on schedule') || ratingLower.contains('fast')) return Colors.green;
    if (ratingLower.contains('full attempt')) return Colors.purple;
    if (ratingLower.contains('slow')) return Colors.red;
    return Colors.grey;
  }

  bool _isResultInvalid() {
    return result.quizName.isEmpty ||
        result.totalQuestions == 0 ||
        result.id.isEmpty;
  }

  Widget _buildErrorScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 80, color: Colors.red),
              const SizedBox(height: 20),
              const Text(
                'Unable to Display Results',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'The quiz result data appears to be incomplete or corrupted.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Quiz Name: ${result.quizName.isEmpty ? "Not Available" : result.quizName}',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                ),
                child: const Text(
                  'Go Back',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showShareOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Your Results'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Share $userName\'s quiz results:'),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.share, color: Colors.blue),
              title: const Text('Share Results'),
              subtitle: const Text('Share via social media or apps'),
              onTap: () {
                Navigator.pop(context);
                _shareResults();
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy, color: Colors.grey),
              title: const Text('Copy Results'),
              subtitle: const Text('Copy to clipboard'),
              onTap: () {
                Navigator.pop(context);
                _copyResultsToClipboard(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _shareResults() {
    final resultsText = '''
🎯 $userName's Quiz Results 🎯

📝 Quiz: ${result.quizName}
⭐ Score: ${result.score} points (${result.percentage.toStringAsFixed(1)}%)
🏆 Grade: ${result.grade}

📊 Performance Summary:
✅ Correct Answers: ${result.correctAnswers}/${result.totalQuestions}
🎯 Accuracy Rate: ${_calculateAccuracy(result).toStringAsFixed(1)}%
⏱️ Time Spent: ${_formatTime(result.timeSpent)}
📅 Date Completed: ${_formatDate(result.completedAt)}

Great work on completing the assessment! 🚀
    ''';

    Share.share(resultsText, subject: '$userName\'s Quiz Results');
  }

  void _copyResultsToClipboard(BuildContext context) {
    final resultsText = '''
$userName's Quiz Results
========================

Quiz: ${result.quizName}
Score: ${result.score} points (${result.percentage.toStringAsFixed(1)}%)
Grade: ${result.grade}

Performance Summary:
• Correct Answers: ${result.correctAnswers}/${result.totalQuestions}
• Accuracy Rate: ${_calculateAccuracy(result).toStringAsFixed(1)}%
• Time Spent: ${_formatTime(result.timeSpent)}
• Date Completed: ${_formatDate(result.completedAt)}

Well done on completing the assessment!
    ''';

    // Copy to clipboard
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${userName}\'s results copied to clipboard'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}