import 'package:flutter/material.dart';
import 'package:individual_learner_app/src/models/assesment_model.dart';
import 'package:individual_learner_app/src/models/result_model.dart';
import 'challenges_exams_screen.dart';

class ResultDetailsScreen extends StatelessWidget {
  final AssessmentResult result;
  final Assessment assessment;

  const ResultDetailsScreen({
    Key? key,
    required this.result,
    required this.assessment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color scoreColor = result.passed ? Colors.green : Colors.red;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Assessment Result'),
        backgroundColor: Colors.blue[700],
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => ChallengesExamsScreen()),
                  (route) => false,
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Result Header
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: result.passed
                      ? [Colors.green[400]!, Colors.green[600]!]
                      : [Colors.red[400]!, Colors.red[600]!],
                ),
              ),
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      result.passed ? Icons.emoji_events : Icons.error_outline,
                      size: 60,
                      color: scoreColor,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    result.passed ? 'Congratulations!' : 'Keep Trying!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    result.passed
                        ? 'You passed the assessment!'
                        : 'You didn\'t pass this time',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    '${result.scorePercentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Your Score',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Statistics Cards
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Summary Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Summary',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildSummaryItem(
                                  Icons.check_circle,
                                  'Correct',
                                  result.correctAnswers.toString(),
                                  Colors.green,
                                ),
                              ),
                              Expanded(
                                child: _buildSummaryItem(
                                  Icons.cancel,
                                  'Wrong',
                                  result.wrongAnswers.toString(),
                                  Colors.red,
                                ),
                              ),
                              Expanded(
                                child: _buildSummaryItem(
                                  Icons.remove_circle_outline,
                                  'Skipped',
                                  result.skippedQuestions.toString(),
                                  Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // Performance Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Performance',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          SizedBox(height: 16),
                          _buildPerformanceRow(
                            Icons.star,
                            'Points Earned',
                            '${result.earnedPoints}/${result.totalPoints}',
                            Colors.amber,
                          ),
                          Divider(height: 24),
                          _buildPerformanceRow(
                            Icons.timer,
                            'Time Taken',
                            _formatDuration(result.timeTaken),
                            Colors.blue,
                          ),
                          Divider(height: 24),
                          _buildPerformanceRow(
                            Icons.assessment,
                            'Total Questions',
                            result.totalQuestions.toString(),
                            Colors.purple,
                          ),
                          Divider(height: 24),
                          _buildPerformanceRow(
                            Icons.flag,
                            'Passing Score',
                            '${assessment.passingScore}%',
                            Colors.teal,
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // Review Answers Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showAnswerReview(context);
                      },
                      icon: Icon(Icons.remove_red_eye),
                      label: Text('Review Answers'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 12),

                  // Back to Challenges Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChallengesExamsScreen()),
                              (route) => false,
                        );
                      },
                      icon: Icon(Icons.arrow_back),
                      label: Text('Back to Challenges'),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.blue[700]!),
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
      IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceRow(
      IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[700],
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      ],
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

  void _showAnswerReview(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
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
                  UserAnswer userAnswer = result.userAnswers[index];
                  var question = assessment.questions[index];

                  return Card(
                    margin: EdgeInsets.only(bottom: 16),
                    elevation: 2,
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
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: userAnswer.isCorrect
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.red.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  userAnswer.isCorrect
                                      ? Icons.check
                                      : Icons.close,
                                  color: userAnswer.isCorrect
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
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: userAnswer.isCorrect
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '+${userAnswer.pointsEarned} pts',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: userAnswer.isCorrect
                                        ? Colors.green
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Text(
                            userAnswer.questionText,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          SizedBox(height: 12),
                          ...question.options.asMap().entries.map((entry) {
                            int optionIndex = entry.key;
                            String option = entry.value;
                            bool isCorrect =
                                optionIndex == userAnswer.correctAnswerIndex;
                            bool isSelected =
                                optionIndex == userAnswer.selectedAnswerIndex;

                            return Container(
                              margin: EdgeInsets.only(bottom: 8),
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isCorrect
                                    ? Colors.green.withOpacity(0.1)
                                    : isSelected
                                    ? Colors.red.withOpacity(0.1)
                                    : Colors.grey[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isCorrect
                                      ? Colors.green
                                      : isSelected
                                      ? Colors.red
                                      : Colors.grey[300]!,
                                  width: isCorrect || isSelected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isCorrect
                                          ? Colors.green
                                          : isSelected
                                          ? Colors.red
                                          : Colors.grey[300],
                                    ),
                                    child: Center(
                                      child: Text(
                                        String.fromCharCode(65 + optionIndex),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: isCorrect || isSelected
                                              ? Colors.white
                                              : Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      option,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                  ),
                                  if (isCorrect)
                                    Icon(Icons.check_circle,
                                        color: Colors.green, size: 20),
                                  if (isSelected && !isCorrect)
                                    Icon(Icons.cancel,
                                        color: Colors.red, size: 20),
                                ],
                              ),
                            );
                          }).toList(),
                          if (question.explanation != null &&
                              question.explanation!.isNotEmpty)
                            Container(
                              margin: EdgeInsets.only(top: 12),
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.info_outline,
                                      color: Colors.blue[700], size: 20),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      question.explanation!,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.blue[900],
                                      ),
                                    ),
                                  ),
                                ],
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
