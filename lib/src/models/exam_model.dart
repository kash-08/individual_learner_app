class Exam {
  final String id;
  final String title;
  final String description;
  final String category;
  final String difficulty;
  final int totalQuestions;
  final int timeLimit; // in minutes
  final double passingScore; // percentage
  final DateTime createdAt;
  final List<String> tags;
  final bool isActive;
  final String examType; // 'quiz', 'coding', 'mock_exam'

  Exam({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.totalQuestions,
    required this.timeLimit,
    required this.passingScore,
    required this.createdAt,
    required this.tags,
    required this.isActive,
    required this.examType,
  });
}

class Question {
  final String id;
  final String examId;
  final String questionText;
  final String questionType; // 'multiple_choice', 'coding', 'true_false'
  final List<String> options; // For multiple choice
  final int correctOptionIndex; // For multiple choice
  final String? correctCode; // For coding questions
  final String? codingLanguage; // For coding questions
  final String? hint;
  final int points;

  Question({
    required this.id,
    required this.examId,
    required this.questionText,
    required this.questionType,
    this.options = const [],
    this.correctOptionIndex = -1,
    this.correctCode,
    this.codingLanguage,
    this.hint,
    required this.points,
  });
}

class ExamResult {
  final String id;
  final String userId;
  final String examId;
  final String examTitle;
  final DateTime completedAt;
  final int totalQuestions;
  final int correctAnswers;
  final double scorePercentage;
  final int timeTaken; // in seconds
  final bool passed;
  final Map<String, dynamic> detailedResults;
  final String examType;

  ExamResult({
    required this.id,
    required this.userId,
    required this.examId,
    required this.examTitle,
    required this.completedAt,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.scorePercentage,
    required this.timeTaken,
    required this.passed,
    required this.detailedResults,
    required this.examType,
  });
}

class CodingChallenge {
  final String id;
  final String title;
  final String description;
  final String difficulty;
  final String language;
  final String starterCode;
  final List<TestCase> testCases;
  final String solution;
  final int timeLimit; // in minutes
  final int points;
  final List<String> tags;

  CodingChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.language,
    required this.starterCode,
    required this.testCases,
    required this.solution,
    required this.timeLimit,
    required this.points,
    required this.tags,
  });
}

class TestCase {
  final String input;
  final String expectedOutput;
  final bool isHidden;

  TestCase({
    required this.input,
    required this.expectedOutput,
    this.isHidden = false,
  });
}

class UserChallengeProgress {
  final String userId;
  final String challengeId;
  final String lastSubmittedCode;
  final bool completed;
  final int attempts;
  final DateTime? completedAt;
  final double bestScore;
  final List<DateTime> attemptHistory;

  UserChallengeProgress({
    required this.userId,
    required this.challengeId,
    required this.lastSubmittedCode,
    required this.completed,
    required this.attempts,
    this.completedAt,
    required this.bestScore,
    required this.attemptHistory,
  });
}