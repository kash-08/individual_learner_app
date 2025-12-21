import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/assesment_service.dart';
import '../models/exam_model.dart';

class ResultsTab extends StatefulWidget {
  // Make userId optional with a default value
  final String? userId;

  const ResultsTab({Key? key, this.userId}) : super(key: key);

  @override
  _ResultsTabState createState() => _ResultsTabState();
}

class _ResultsTabState extends State<ResultsTab> {
  final AssessmentService _assessmentService = AssessmentService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = _auth.currentUser?.uid;
  }

  @override
  Widget build(BuildContext context) {
    // Use widget.userId if provided, otherwise use current user's ID
    final userId = widget.userId ?? _currentUserId;

    if (userId == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Please login to view results',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return StreamBuilder<List<QuizResult>>(
      stream: _assessmentService.getUserResultsByUserId(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, color: Colors.red, size: 64),
                SizedBox(height: 16),
                Text(
                  'Error loading results',
                  style: TextStyle(color: Colors.red),
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    setState(() {});
                  },
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        }

        final results = snapshot.data ?? [];

        if (results.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.quiz_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No quiz results yet',
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to quizzes - you can adjust this based on your navigation
                    // Navigator.pushNamed(context, '/challenges');
                  },
                  child: Text('Take a Quiz'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final result = results[index];
              return _buildResultCard(context, result);
            },
          ),
        );
      },
    );
  }

  Widget _buildResultCard(BuildContext context, QuizResult result) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to result details
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => ResultDetailsScreen(result: result),
          //   ),
          // );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Score circle
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      _getGradeColor(result.grade),
                      _getGradeColor(result.grade).withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _getGradeColor(result.grade).withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${result.percentage.toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        result.grade,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 16),
              // Result details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.quizName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Chip(
                          label: Text(
                            '${result.correctAnswers}/${result.totalQuestions}',
                            style: TextStyle(fontSize: 12),
                          ),
                          backgroundColor: Colors.green[100],
                          visualDensity: VisualDensity.compact,
                        ),
                        SizedBox(width: 8),
                        Chip(
                          label: Text(
                            result.quizType,
                            style: TextStyle(fontSize: 12),
                          ),
                          backgroundColor: _getTypeColor(result.quizType),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.score, size: 14, color: Colors.grey[600]),
                        SizedBox(width: 4),
                        Text(
                          'Score: ${result.score}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(width: 16),
                        Icon(Icons.timer, size: 14, color: Colors.grey[600]),
                        SizedBox(width: 4),
                        Text(
                          _formatTime(result.timeSpent),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      _formatDate(result.completedAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              // Forward arrow
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
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
        return Colors.amber[700]!;
      default:
        return Colors.red;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'quiz':
        return Colors.blue[100]!;
      case 'coding':
        return Colors.green[100]!;
      case 'exam':
        return Colors.orange[100]!;
      default:
        return Colors.grey[100]!;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatTime(int seconds) {
    if (seconds < 60) {
      return '${seconds}s';
    } else {
      final minutes = seconds ~/ 60;
      final remainingSeconds = seconds % 60;
      if (remainingSeconds > 0) {
        return '${minutes}m ${remainingSeconds}s';
      } else {
        return '${minutes}m';
      }
    }
  }
}
