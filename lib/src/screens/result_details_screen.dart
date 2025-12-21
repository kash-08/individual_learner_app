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
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Result Summary Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Quiz Completed!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
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
                            Colors.blue,
                            Colors.green,
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
                    // Stats Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          'Correct',
                          '${result.correctAnswers}/${result.totalQuestions}',
                          Colors.green,
                        ),
                        _buildStatItem(
                          'Time',
                          '${(result.timeSpent ~/ 60)}m ${result.timeSpent % 60}s',
                          Colors.blue,
                        ),
                        _buildStatItem(
                          'Points',
                          '${result.score}',
                          Colors.orange,
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
              ),
            ),
            SizedBox(height: 10),
            ..._buildQuestionResults(),
            SizedBox(height: 20),
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    child: Text('Back to Home'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to retake quiz
                      // You can implement this based on your navigation
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: Text('Retake Quiz'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getStatIcon(title),
            color: color,
          ),
        ),
        SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(value),
      ],
    );
  }

  IconData _getStatIcon(String title) {
    switch (title) {
      case 'Correct':
        return Icons.check_circle;
      case 'Time':
        return Icons.timer;
      case 'Points':
        return Icons.star;
      default:
        return Icons.info;
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
        return Colors.yellow;
      default:
        return Colors.red;
    }
  }

  List<Widget> _buildQuestionResults() {
    if (result.questionResults == null) return [Text('No detailed results available')];

    return result.questionResults!.map((qResult) {
      return Card(
        margin: EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                qResult['question'],
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    qResult['isCorrect'] ? Icons.check_circle : Icons.cancel,
                    color: qResult['isCorrect'] ? Colors.green : Colors.red,
                  ),
                  SizedBox(width: 8),
                  Text(
                    qResult['isCorrect'] ? 'Correct' : 'Incorrect',
                    style: TextStyle(
                      color: qResult['isCorrect'] ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  Text('${qResult['points']} points'),
                ],
              ),
              if (qResult['explanation'] != null) ...[
                SizedBox(height: 8),
                Text(
                  'Explanation: ${qResult['explanation']}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ],
          ),
        ),
      );
    }).toList();
  }
}
