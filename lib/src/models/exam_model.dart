// Add to your existing exam_model.dart or create if doesn't exist
class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;
  final String category;
  final int points;
  final String type; // 'quiz', 'coding', 'exam'
  final String? codeSnippet; // For coding challenges

  QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
    required this.category,
    this.points = 10,
    this.type = 'quiz',
    this.codeSnippet,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
      'explanation': explanation,
      'category': category,
      'points': points,
      'type': type,
      'codeSnippet': codeSnippet,
    };
  }

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    return QuizQuestion(
      id: map['id'] ?? '',
      question: map['question'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctAnswerIndex: map['correctAnswerIndex'] ?? 0,
      explanation: map['explanation'] ?? '',
      category: map['category'] ?? 'General',
      points: map['points'] ?? 10,
      type: map['type'] ?? 'quiz',
      codeSnippet: map['codeSnippet'],
    );
  }
}

class QuizResult {
  final String id;
  final String userId;
  final String quizId;
  final String quizName;
  final String quizType; // 'quiz', 'coding_challenge', 'mock_exam'
  final int score;
  final int totalQuestions;
  final int correctAnswers;
  final int timeSpent; // in seconds
  final DateTime completedAt;
  final Map<String, dynamic>? details;
  final List<Map<String, dynamic>>? questionResults;

  QuizResult({
    required this.id,
    required this.userId,
    required this.quizId,
    required this.quizName,
    required this.quizType,
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.timeSpent,
    required this.completedAt,
    this.details,
    this.questionResults,
  });

  double get percentage => (correctAnswers / totalQuestions) * 100;
  String get grade {
    final percent = percentage;
    if (percent >= 90) return 'A';
    if (percent >= 80) return 'B';
    if (percent >= 70) return 'C';
    if (percent >= 60) return 'D';
    return 'F';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'quizId': quizId,
      'quizName': quizName,
      'quizType': quizType,
      'score': score,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'timeSpent': timeSpent,
      'completedAt': completedAt.toIso8601String(),
      'details': details,
      'questionResults': questionResults,
    };
  }

  factory QuizResult.fromMap(Map<String, dynamic> map) {
    return QuizResult(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      quizId: map['quizId'] ?? '',
      quizName: map['quizName'] ?? '',
      quizType: map['quizType'] ?? 'quiz',
      score: map['score'] ?? 0,
      totalQuestions: map['totalQuestions'] ?? 0,
      correctAnswers: map['correctAnswers'] ?? 0,
      timeSpent: map['timeSpent'] ?? 0,
      completedAt: DateTime.parse(map['completedAt']),
      details: map['details'],
      questionResults: map['questionResults'] != null
          ? List<Map<String, dynamic>>.from(map['questionResults'])
          : null,
    );
  }

  num? get incorrectAnswers => null;
}