import 'package:flutter/material.dart';
import '../models/exam_model.dart';

class ResultDetailsScreen extends StatelessWidget {
  final QuizResult result;

  const ResultDetailsScreen({Key? key, required this.result}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz Results'),
        backgroundColor: const Color(0xFF4361EE),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Result Summary Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Quiz Completed!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF212529),
                      ),
                    ),
                    SizedBox(height: 16),
                    // Score Circle
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF4361EE),
                            const Color(0xFF3A0CA3),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${result.percentage.toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Score: ${result.score}',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    // Grade
                    Chip(
                      label: Text(
                        'Grade: ${result.grade}',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      backgroundColor: _getGradeColor(result.grade),
                    ),
                    SizedBox(height: 16),
                    // Quiz Info
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Quiz:', style: TextStyle(fontWeight: FontWeight.w500)),
                              Text(result.quizName),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Type:', style: TextStyle(fontWeight: FontWeight.w500)),
                              Text(result.quizType),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Date:', style: TextStyle(fontWeight: FontWeight.w500)),
                              Text(_formatDate(result.completedAt)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    // Stats Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          'Correct',
                          '${result.correctAnswers}/${result.totalQuestions}',
                          Colors.green,
                          Icons.check_circle,
                        ),
                        _buildStatItem(
                          'Time',
                          '${_formatTime(result.timeSpent)}',
                          Colors.blue,
                          Icons.timer,
                        ),
                        _buildStatItem(
                          'Accuracy',
                          '${_calculateAccuracy(result)}%',
                          Colors.orange,
                          Icons.analytics,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            // Detailed Results
            Text(
              'Detailed Results',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF212529),
              ),
            ),
            SizedBox(height: 10),
            ..._buildQuestionResults(),
            SizedBox(height: 20),
            // Performance Analysis
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Performance Analysis',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    _buildPerformanceMetric(
                      'Speed',
                      '${_calculateSpeedPerQuestion(result)} sec/question',
                      _getSpeedRating(result),
                      Icons.speed,
                    ),
                    SizedBox(height: 8),
                    _buildPerformanceMetric(
                      'Accuracy Rate',
                      '${_calculateAccuracy(result)}%',
                      _getAccuracyRating(result),
                      Icons.percent,
                    ),
                    SizedBox(height: 8),
                    _buildPerformanceMetric(
                      'Completion',
                      '${_formatDate(result.completedAt)}',
                      'On Time',
                      Icons.calendar_today,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4361EE),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text('Back to Home', style: TextStyle(color: Colors.white)),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Navigate to retake quiz or challenges screen
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: const Color(0xFF4361EE)),
                    ),
                    child: Text(
                      'Back to Assessments',
                      style: TextStyle(color: const Color(0xFF4361EE)),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Share Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  _showShareOptions(context);
                },
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: Colors.green),
                ),
                icon: Icon(Icons.share, color: Colors.green),
                label: Text(
                  'Share Results',
                  style: TextStyle(color: Colors.green),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, String value, Color color, IconData icon) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
          ),
        ),
        SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceMetric(String title, String value, String rating, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.blue, size: 20),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
              Text(value, style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getRatingColor(rating),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            rating,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
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

  Color _getRatingColor(String rating) {
    switch (rating.toLowerCase()) {
      case 'excellent':
        return Colors.green;
      case 'good':
        return Colors.blue;
      case 'average':
        return Colors.orange;
      case 'slow':
        return Colors.amber;
      case 'on time':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  List<Widget> _buildQuestionResults() {
    if (result.questionResults == null || result.questionResults!.isEmpty) {
      return [
        Card(
          margin: EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'No detailed question results available',
              style: TextStyle(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        )
      ];
    }

    return result.questionResults!.asMap().entries.map((entry) {
      final index = entry.key;
      final qResult = entry.value;

      return Card(
        margin: EdgeInsets.symmetric(vertical: 8),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      qResult['question'] ?? 'Question ${index + 1}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    qResult['isCorrect'] == true ? Icons.check_circle : Icons.cancel,
                    color: qResult['isCorrect'] == true ? Colors.green : Colors.red,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    qResult['isCorrect'] == true ? 'Correct' : 'Incorrect',
                    style: TextStyle(
                      color: qResult['isCorrect'] == true ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  if (qResult['points'] != null)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${qResult['points']} points',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
              if (qResult['explanation'] != null) ...[
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Explanation: ${qResult['explanation']}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
              if (qResult['timeSpent'] != null) ...[
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.timer, size: 14, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(
                      'Time spent: ${qResult['timeSpent']}s',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
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

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    if (minutes > 0) {
      return '${minutes}m ${remainingSeconds}s';
    }
    return '${remainingSeconds}s';
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    return '$day/$month/$year';
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
    if (speed < 30) return 'Excellent';
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
    return 'Needs Improvement';
  }

  void _showShareOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Share Results'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.email, color: Colors.blue),
              title: Text('Share via Email'),
              onTap: () {
                Navigator.pop(context);
                _shareResults('email');
              },
            ),
            ListTile(
              leading: Icon(Icons.share, color: Colors.green),
              title: Text('Share via Message'),
              onTap: () {
                Navigator.pop(context);
                _shareResults('message');
              },
            ),
            ListTile(
              leading: Icon(Icons.copy, color: Colors.grey),
              title: Text('Copy Results'),
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
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _shareResults(String method) {
    // Implement sharing logic here
    print('Sharing results via $method');
  }

  void _copyResultsToClipboard(BuildContext context) {
    final resultsText = '''
Quiz Results
------------
Quiz: ${result.quizName}
Score: ${result.score} (${result.percentage.toStringAsFixed(1)}%)
Grade: ${result.grade}
Correct: ${result.correctAnswers}/${result.totalQuestions}
Time Spent: ${_formatTime(result.timeSpent)}
Date: ${_formatDate(result.completedAt)}
    ''';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Results copied to clipboard'),
        backgroundColor: Colors.green,
      ),
    );
  }
}