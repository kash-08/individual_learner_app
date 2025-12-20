import 'package:cloud_firestore/cloud_firestore.dart';

class Question {
  final String id;
  final String questionText;
  final List<String> options;
  final int correctAnswerIndex;
  final String? explanation;
  final int points;

  Question({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
    this.explanation,
    this.points = 10,
  });

  factory Question.fromMap(Map<String, dynamic> map, String id) {
    return Question(
      id: id,
      questionText: map['questionText'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctAnswerIndex: map['correctAnswerIndex'] ?? 0,
      explanation: map['explanation'],
      points: map['points'] ?? 10,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'questionText': questionText,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
      'explanation': explanation,
      'points': points,
    };
  }
}
