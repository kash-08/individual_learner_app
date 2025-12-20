import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:individual_learner_app/src/models/result_model.dart';
import 'package:individual_learner_app/src/services/assesment_service.dart';

class ResultsTab extends StatelessWidget {
  final AssessmentService _assessmentService = AssessmentService();

  ResultsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    if (userId.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.login, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'Please login to view results',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return StreamBuilder<List<AssessmentResult>>(
      stream: _assessmentService.getUserResults(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                SizedBox(height: 16),
                Text(
                  'Error loading results',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.assessment_outlined,
                  size: 80,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 16),
                Text(
                  'No results yet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Complete assessments to see your results here',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        List<AssessmentResult> results = snapshot.data!;

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: results.length,
          itemBuilder: (context, index) {
            AssessmentResult result = results[index];
            return _buildResultCard(context, result);
          },
        );
      },
    );
  }

  Widget _buildResultCard(BuildContext context, AssessmentResult result) {
    Color scoreColor = result.passed ? Colors.green : Colors.red;

    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: scoreColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    result.passed ? Icons.check_circle : Icons.cancel,
                    color: scoreColor,
                    size: 24,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.assessmentTitle,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        DateFormat('MMM dd, yyyy • hh:mm a')
                            .format(result.completedAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: scoreColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${result.scorePercentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: scoreColor,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),

            // Stats
            Row(
              children: [
                Expanded(
                  child: _buildStatChip(
                    Icons.check_circle,
                    '${result.correctAnswers}',
                    'Correct',
                    Colors.green,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _buildStatChip(
                    Icons.cancel,
                    '${result.wrongAnswers}',
                    'Wrong',
                    Colors.red,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _buildStatChip(
                    Icons.remove_circle,
                    '${result.skippedQuestions}',
                    'Skipped',
                    Colors.orange,
                  ),
                ),
              ],
            ),

            SizedBox(height: 12),

            // Additional info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.timer, size: 16, color: Colors.grey[600]),
                    SizedBox(width: 4),
                    Text(
                      '${_formatDuration(result.timeTaken)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.star, size: 16, color: Colors.amber),
                    SizedBox(width: 4),
                    Text(
                      '${result.earnedPoints}/${result.totalPoints} pts',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 12),

            // View details button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // Navigate to detailed results view
                  _showResultDetails(context, result);
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.blue[700]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('View Details'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(
      IconData icon, String value, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    if (minutes > 0) {
      return '$minutes min ${remainingSeconds}s';
    }
    return '${remainingSeconds}s';
  }

  void _showResultDetails(BuildContext context, AssessmentResult result) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Answer Review',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Divider(height: 1),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: EdgeInsets.all(16),
                itemCount: result.userAnswers.length,
                itemBuilder: (context, index) {
                  UserAnswer answer = result.userAnswers[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: answer.isCorrect
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.red.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  answer.isCorrect
                                      ? Icons.check
                                      : Icons.close,
                                  color: answer.isCorrect
                                      ? Colors.green
                                      : Colors.red,
                                  size: 20,
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Question ${index + 1}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                answer.selectedAnswerIndex != null
                                    ? String.fromCharCode(
                                    65 + answer.selectedAnswerIndex!)
                                    : 'Skipped',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: answer.isCorrect
                                      ? Colors.green
                                      : answer.selectedAnswerIndex != null
                                      ? Colors.red
                                      : Colors.orange,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            answer.questionText,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                          if (!answer.isCorrect)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Correct Answer: ${String.fromCharCode(65 + answer.correctAnswerIndex)}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
