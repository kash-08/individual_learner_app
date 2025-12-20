import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:individual_learner_app/src/models/assesment_model.dart';
import 'package:individual_learner_app/src/services/assesment_service.dart';
import 'package:individual_learner_app/src/components/assesment_card.dart';
import 'package:individual_learner_app/src/screens/take_assesment_screen.dart';

class AssessmentListTab extends StatelessWidget {
  final AssessmentType type;
  final AssessmentService _assessmentService = AssessmentService();

  AssessmentListTab({Key? key, required this.type}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Assessment>>(
      stream: _assessmentService.getAssessmentsByType(type),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                SizedBox(height: 16),
                Text(
                  'Error loading assessments',
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
                  Icons.assignment_outlined,
                  size: 80,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 16),
                Text(
                  'No ${_getTypeName()} available',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Check back later for new ${_getTypeName().toLowerCase()}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        List<Assessment> assessments = snapshot.data!;

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: assessments.length,
          itemBuilder: (context, index) {
            Assessment assessment = assessments[index];
            return AssessmentCard(
              assessment: assessment,
              onTap: () => _startAssessment(context, assessment),
            );
          },
        );
      },
    );
  }

  String _getTypeName() {
    switch (type) {
      case AssessmentType.quiz:
        return 'Quizzes';
      case AssessmentType.challenge:
        return 'Coding Challenges';
      case AssessmentType.mockExam:
        return 'Mock Exams';
    }
  }

  Future<void> _startAssessment(
      BuildContext context, Assessment assessment) async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    if (userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please login to take assessments'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if user has already attempted
    bool hasAttempted = await _assessmentService.hasUserAttempted(
      userId,
      assessment.id,
    );

    if (hasAttempted) {
      // Show dialog asking if they want to retake
      bool? retake = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Retake Assessment?'),
          content: Text(
            'You have already attempted this ${assessment.getTypeString()}. Do you want to retake it?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
              ),
              child: Text('Retake'),
            ),
          ],
        ),
      );

      if (retake != true) return;
    }

    // Navigate to assessment screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TakeAssessmentScreen(assessment: assessment),
      ),
    );
  }
}
