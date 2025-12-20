import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:individual_learner_app/src/models/assesment_model.dart';
import 'package:individual_learner_app/src/models/question_model.dart';
import 'package:individual_learner_app/src/models/result_model.dart';
import 'package:individual_learner_app/src/services/assesment_service.dart';
import 'result_details_screen.dart';

class TakeAssessmentScreen extends StatefulWidget {
  final Assessment assessment;

  const TakeAssessmentScreen({Key? key, required this.assessment})
      : super(key: key);

  @override
  State<TakeAssessmentScreen> createState() => _TakeAssessmentScreenState();
}

class _TakeAssessmentScreenState extends State<TakeAssessmentScreen> {
  int _currentQuestionIndex = 0;
  List<int?> _selectedAnswers = [];
  Timer? _timer;
  int _secondsRemaining = 0;
  bool _isSubmitting = false;
  DateTime? _startTime;

  @override
  void initState() {
    super.initState();
    _selectedAnswers =
    List<int?>.filled(widget.assessment.questions.length, null);
    _secondsRemaining = widget.assessment.duration * 60;
    _startTime = DateTime.now();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _submitAssessment();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < widget.assessment.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  void _selectAnswer(int answerIndex) {
    setState(() {
      _selectedAnswers[_currentQuestionIndex] = answerIndex;
    });
  }

  Future<void> _submitAssessment() async {
    if (_isSubmitting) return;

    bool? confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Submit Assessment?'),
        content: Text(
          _getUnansweredCount() > 0
              ? 'You have ${_getUnansweredCount()} unanswered questions. Do you want to submit anyway?'
              : 'Are you sure you want to submit your assessment?',
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
            child: Text('Submit'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isSubmitting = true;
    });

    _timer?.cancel();

    // Calculate results
    int timeTaken =
        DateTime.now().difference(_startTime!).inSeconds;
    int correctAnswers = 0;
    int totalPoints = 0;
    int earnedPoints = 0;
    List<UserAnswer> userAnswers = [];

    for (int i = 0; i < widget.assessment.questions.length; i++) {
      Question question = widget.assessment.questions[i];
      int? selectedAnswer = _selectedAnswers[i];
      bool isCorrect = selectedAnswer == question.correctAnswerIndex;

      if (isCorrect) {
        correctAnswers++;
        earnedPoints += question.points;
      }

      totalPoints += question.points;

      userAnswers.add(UserAnswer(
        questionIndex: i,
        questionText: question.questionText,
        selectedAnswerIndex: selectedAnswer,
        correctAnswerIndex: question.correctAnswerIndex,
        isCorrect: isCorrect,
        pointsEarned: isCorrect ? question.points : 0,
      ));
    }

    int wrongAnswers = _selectedAnswers
        .where((answer) => answer != null)
        .where((answer) => userAnswers[_selectedAnswers.indexOf(answer)].isCorrect == false)
        .length;
    int skippedQuestions = _selectedAnswers.where((answer) => answer == null).length;
    double scorePercentage = (earnedPoints / totalPoints) * 100;
    bool passed = scorePercentage >= widget.assessment.passingScore;

    // Create result object
    AssessmentResult result = AssessmentResult(
      id: '',
      userId: FirebaseAuth.instance.currentUser?.uid ?? '',
      assessmentId: widget.assessment.id,
      assessmentTitle: widget.assessment.title,
      assessmentType: widget.assessment.type.toString().split('.').last,
      totalQuestions: widget.assessment.questions.length,
      correctAnswers: correctAnswers,
      wrongAnswers: wrongAnswers,
      skippedQuestions: skippedQuestions,
      scorePercentage: scorePercentage,
      totalPoints: totalPoints,
      earnedPoints: earnedPoints,
      passed: passed,
      timeTaken: timeTaken,
      completedAt: DateTime.now(),
      userAnswers: userAnswers,
    );

    // Save to Firebase
    AssessmentService assessmentService = AssessmentService();
    String? resultId = await assessmentService.saveAssessmentResult(result);

    if (resultId != null) {
      // Navigate to results screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultDetailsScreen(
            result: result,
            assessment: widget.assessment,
          ),
        ),
      );
    } else {
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save result. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  int _getUnansweredCount() {
    return _selectedAnswers.where((answer) => answer == null).length;
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    Question currentQuestion = widget.assessment.questions[_currentQuestionIndex];

    return WillPopScope(
      onWillPop: () async {
        bool? leave = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Leave Assessment?'),
            content: Text('Your progress will be lost if you leave now.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Stay'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: Text('Leave'),
              ),
            ],
          ),
        );
        return leave ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.assessment.title),
          backgroundColor: Colors.blue[700],
          actions: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _secondsRemaining < 60
                      ? Colors.red
                      : Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.timer, size: 18),
                    SizedBox(width: 4),
                    Text(
                      _formatTime(_secondsRemaining),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        body: _isSubmitting
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Submitting your assessment...',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        )
            : Column(
          children: [
            // Progress indicator
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Question ${_currentQuestionIndex + 1} of ${widget.assessment.questions.length}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      Text(
                        '${_selectedAnswers.where((a) => a != null).length} answered',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (_currentQuestionIndex + 1) /
                        widget.assessment.questions.length,
                    backgroundColor: Colors.grey[300],
                    color: Colors.blue[700],
                  ),
                ],
              ),
            ),

            // Question content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question text
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          currentQuestion.questionText,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    // Answer options
                    ...currentQuestion.options.asMap().entries.map((entry) {
                      int index = entry.key;
                      String option = entry.value;
                      bool isSelected =
                          _selectedAnswers[_currentQuestionIndex] == index;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: InkWell(
                          onTap: () => _selectAnswer(index),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.blue[700]
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.blue[700]!
                                    : Colors.grey[300]!,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.grey[200],
                                  ),
                                  child: Center(
                                    child: Text(
                                      String.fromCharCode(65 + index),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? Colors.blue[700]
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
                                      fontSize: 16,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.grey[800],
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),

            // Navigation buttons
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  if (_currentQuestionIndex > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousQuestion,
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: Colors.blue[700]!),
                        ),
                        child: Text('Previous'),
                      ),
                    ),
                  if (_currentQuestionIndex > 0) SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _currentQuestionIndex ==
                          widget.assessment.questions.length - 1
                          ? _submitAssessment
                          : _nextQuestion,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: _currentQuestionIndex ==
                            widget.assessment.questions.length - 1
                            ? Colors.green
                            : Colors.blue[700],
                      ),
                      child: Text(
                        _currentQuestionIndex ==
                            widget.assessment.questions.length - 1
                            ? 'Submit'
                            : 'Next',
                        style: TextStyle(fontSize: 16),
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
}
