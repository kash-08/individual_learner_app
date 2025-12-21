import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:individual_learner_app/src/screens/take_assesment_screen.dart';
import '../services/assesment_service.dart';

class AssessmentListTab extends StatefulWidget {
  final String type;

  const AssessmentListTab({Key? key, required this.type}) : super(key: key);

  @override
  _AssessmentListTabState createState() => _AssessmentListTabState();
}

class _AssessmentListTabState extends State<AssessmentListTab> {
  final AssessmentService _assessmentService = AssessmentService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _assessmentService.getAssessmentsByType(widget.type),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final assessments = snapshot.data ?? [];

        if (assessments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.quiz, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No ${widget.type.replaceAll('_', ' ')} available',
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    _assessmentService.initializeMockData();
                  },
                  child: Text('Load Mock Data'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: assessments.length,
          itemBuilder: (context, index) {
            final assessment = assessments[index];
            return _buildAssessmentCard(context, assessment);
          },
        );
      },
    );
  }

  Widget _buildAssessmentCard(BuildContext context, Map<String, dynamic> assessment) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _getTypeColor(assessment['type']),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            _getTypeIcon(assessment['type']),
            color: Colors.white,
          ),
        ),
        title: Text(
          assessment['name'] ?? 'Untitled Quiz',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(assessment['description'] ?? ''),
            SizedBox(height: 8),
            Row(
              children: [
                Chip(
                  label: Text(assessment['difficulty'] ?? 'Unknown'),
                  backgroundColor: _getDifficultyColor(assessment['difficulty']),
                ),
                SizedBox(width: 8),
                Chip(
                  label: Text('${assessment['totalPoints'] ?? 0} pts'),
                ),
              ],
            ),
          ],
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // Navigate to quiz taking screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TakeAssessmentScreen(
                quizId: assessment['id'],
                quizName: assessment['name'],
                quizType: assessment['type'],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'quiz':
        return Colors.blue;
      case 'coding':
        return Colors.green;
      case 'exam':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'quiz':
        return Icons.quiz;
      case 'coding':
        return Icons.code;
      case 'exam':
        return Icons.assignment;
      default:
        return Icons.question_mark;
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty?.toLowerCase()) {
      case 'beginner':
        return Colors.green.withOpacity(0.2);
      case 'intermediate':
        return Colors.blue.withOpacity(0.2);
      case 'advanced':
        return Colors.orange.withOpacity(0.2);
      default:
        return Colors.grey.withOpacity(0.2);
    }
  }
}
