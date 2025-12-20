import 'package:cloud_firestore/cloud_firestore.dart';

class AssessmentResult {
  final String id;
  final String userId;
  final String assessmentId;
  final String assessmentTitle;
  final String assessmentType;
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final int skippedQuestions;
  final double scorePercentage;
  final int totalPoints;
  final int earnedPoints;
  final bool passed;
  final int timeTaken; // in seconds
  final DateTime completedAt;
  final List<UserAnswer> userAnswers;

  AssessmentResult({
    required this.id,
    required this.userId,
    required this.assessmentId,
    required this.assessmentTitle,
    required this.assessmentType,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.skippedQuestions,
    required this.scorePercentage,
    required this.totalPoints,
    required this.earnedPoints,
    required this.passed,
    required this.timeTaken,
    required this.completedAt,
    required this.userAnswers,
  });

  factory AssessmentResult.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    List<UserAnswer> answers = [];
    if (data['userAnswers'] != null) {
      List<dynamic> answersData = data['userAnswers'];
      answers = answersData
          .map((answer) => UserAnswer.fromMap(answer as Map<String, dynamic>))
          .toList();
    }

    return AssessmentResult(
      id: doc.id,
      userId: data['userId'] ?? '',
      assessmentId: data['assessmentId'] ?? '',
      assessmentTitle: data['assessmentTitle'] ?? '',
      assessmentType: data['assessmentType'] ?? '',
      totalQuestions: data['totalQuestions'] ?? 0,
      correctAnswers: data['correctAnswers'] ?? 0,
      wrongAnswers: data['wrongAnswers'] ?? 0,
      skippedQuestions: data['skippedQuestions'] ?? 0,
      scorePercentage: (data['scorePercentage'] ?? 0).toDouble(),
      totalPoints: data['totalPoints'] ?? 0,
      earnedPoints: data['earnedPoints'] ?? 0,
      passed: data['passed'] ?? false,
      timeTaken: data['timeTaken'] ?? 0,
      completedAt:
      (data['completedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      userAnswers: answers,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'assessmentId': assessmentId,
      'assessmentTitle': assessmentTitle,
      'assessmentType': assessmentType,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'wrongAnswers': wrongAnswers,
      'skippedQuestions': skippedQuestions,
      'scorePercentage': scorePercentage,
      'totalPoints': totalPoints,
      'earnedPoints': earnedPoints,
      'passed': passed,
      'timeTaken': timeTaken,
      'completedAt': Timestamp.fromDate(completedAt),
      'userAnswers': userAnswers.map((answer) => answer.toMap()).toList(),
    };
  }
}

class UserAnswer {
  final int questionIndex;
  final String questionText;
  final int? selectedAnswerIndex;
  final int correctAnswerIndex;
  final bool isCorrect;
  final int pointsEarned;

  UserAnswer({
    required this.questionIndex,
    required this.questionText,
    this.selectedAnswerIndex,
    required this.correctAnswerIndex,
    required this.isCorrect,
    required this.pointsEarned,
  });

  factory UserAnswer.fromMap(Map<String, dynamic> map) {
    return UserAnswer(
      questionIndex: map['questionIndex'] ?? 0,
      questionText: map['questionText'] ?? '',
      selectedAnswerIndex: map['selectedAnswerIndex'],
      correctAnswerIndex: map['correctAnswerIndex'] ?? 0,
      isCorrect: map['isCorrect'] ?? false,
      pointsEarned: map['pointsEarned'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'questionIndex': questionIndex,
      'questionText': questionText,
      'selectedAnswerIndex': selectedAnswerIndex,
      'correctAnswerIndex': correctAnswerIndex,
      'isCorrect': isCorrect,
      'pointsEarned': pointsEarned,
    };
  }
}
