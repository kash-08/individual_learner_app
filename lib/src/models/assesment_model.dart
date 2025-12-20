import 'package:cloud_firestore/cloud_firestore.dart';
import 'question_model.dart';

enum AssessmentType {
  quiz,
  challenge,
  mockExam,
}

class Assessment {
  final String id;
  final String title;
  final String description;
  final AssessmentType type;
  final String category;
  final String difficulty; // Easy, Medium, Hard
  final int duration; // in minutes
  final int totalQuestions;
  final int passingScore;
  final List<Question> questions;
  final bool isActive;
  final DateTime createdAt;

  Assessment({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.category,
    required this.difficulty,
    required this.duration,
    required this.totalQuestions,
    required this.passingScore,
    required this.questions,
    this.isActive = true,
    required this.createdAt,
  });

  factory Assessment.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    List<Question> questions = [];
    if (data['questions'] != null) {
      List<dynamic> questionsData = data['questions'];
      questions = questionsData
          .asMap()
          .entries
          .map((entry) => Question.fromMap(
        entry.value as Map<String, dynamic>,
        entry.key.toString(),
      ))
          .toList();
    }

    return Assessment(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      type: _getAssessmentType(data['type'] ?? 'quiz'),
      category: data['category'] ?? '',
      difficulty: data['difficulty'] ?? 'Easy',
      duration: data['duration'] ?? 30,
      totalQuestions: data['totalQuestions'] ?? 0,
      passingScore: data['passingScore'] ?? 70,
      questions: questions,
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'type': type.toString().split('.').last,
      'category': category,
      'difficulty': difficulty,
      'duration': duration,
      'totalQuestions': totalQuestions,
      'passingScore': passingScore,
      'questions': questions.map((q) => q.toMap()).toList(),
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  static AssessmentType _getAssessmentType(String type) {
    switch (type) {
      case 'quiz':
        return AssessmentType.quiz;
      case 'challenge':
        return AssessmentType.challenge;
      case 'mockExam':
        return AssessmentType.mockExam;
      default:
        return AssessmentType.quiz;
    }
  }

  String getTypeString() {
    switch (type) {
      case AssessmentType.quiz:
        return 'Quiz';
      case AssessmentType.challenge:
        return 'Coding Challenge';
      case AssessmentType.mockExam:
        return 'Mock Exam';
    }
  }
}
