import 'dart:async'; // ADD THIS IMPORT FOR Timer
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/exam_provider.dart';
import '../models/exam_model.dart';
import 'package:individual_learner_app/src/components/exam_question_widget.dart';

class ExamTakingScreen extends StatefulWidget {
  final Exam exam;

  const ExamTakingScreen({Key? key, required this.exam}) : super(key: key);

  @override
  _ExamTakingScreenState createState() => _ExamTakingScreenState();
}

class _ExamTakingScreenState extends State<ExamTakingScreen> {
  late PageController _pageController;
  late List<Question> _questions;
  late List<int?> _selectedAnswers;
  late DateTime _startTime;
  late Duration _timeLimit;
  late Duration _remainingTime;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _questions = [];
    _selectedAnswers = [];
    _timeLimit = Duration(minutes: widget.exam.timeLimit);
    _remainingTime = _timeLimit;
    _startTime = DateTime.now();

    // Load questions
    _loadQuestions();

    // Start timer
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime.inSeconds > 0) {
          _remainingTime = _remainingTime - Duration(seconds: 1);
        } else {
          _timer.cancel();
          _submitExam();
        }
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer.cancel();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    final examProvider = Provider.of<ExamProvider>(context, listen: false);
    final questions = await examProvider.getExamQuestions(widget.exam.id);

    setState(() {
      _questions = questions;
      _selectedAnswers = List.filled(questions.length, null);
    });
  }

  void _submitExam() async {
    _timer.cancel();

    // Calculate score
    int correctAnswers = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (_selectedAnswers[i] == _questions[i].correctOptionIndex) {
        correctAnswers++;
      }
    }

    double scorePercentage = (correctAnswers / _questions.length) * 100;
    bool passed = scorePercentage >= widget.exam.passingScore;

    final examProvider = Provider.of<ExamProvider>(context, listen: false);

    // Save exam result
    final result = ExamResult(
      id: '${widget.exam.id}_${DateTime.now().millisecondsSinceEpoch}',
      userId: examProvider.currentUserId,
      examId: widget.exam.id,
      examTitle: widget.exam.title,
      completedAt: DateTime.now(),
      totalQuestions: _questions.length,
      correctAnswers: correctAnswers,
      scorePercentage: scorePercentage,
      timeTaken: _timeLimit.inSeconds - _remainingTime.inSeconds,
      passed: passed,
      detailedResults: {
        'selectedAnswers': _selectedAnswers,
        'correctAnswers': _questions.map((q) => q.correctOptionIndex).toList(),
      },
      examType: widget.exam.examType,
    );

    await examProvider.saveExamResult(result);

    // Show result dialog
    _showResultDialog(scorePercentage, correctAnswers, passed);
  }

  void _showResultDialog(double score, int correctAnswers, bool passed) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          passed ? '🎉 Congratulations!' : '📝 Exam Completed',
          style: TextStyle(
            color: passed ? Colors.green : Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.exam.title}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            _buildScoreRow('Score', '${score.toStringAsFixed(1)}%'),
            _buildScoreRow('Correct Answers', '$correctAnswers/${_questions.length}'),
            _buildScoreRow('Passing Score', '${widget.exam.passingScore}%'),
            _buildScoreRow('Time Taken', '${(_timeLimit.inSeconds - _remainingTime.inSeconds) ~/ 60}m ${(_timeLimit.inSeconds - _remainingTime.inSeconds) % 60}s'),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: passed ? Colors.green.shade50 : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: passed ? Colors.green.shade200 : Colors.orange.shade200,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    passed ? Icons.check_circle : Icons.info,
                    color: passed ? Colors.green : Colors.orange,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      passed ? 'You have passed the exam!' : 'You need more practice.',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: passed ? Colors.green.shade800 : Colors.orange.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to exams screen
            },
            child: Text('Back to Exams'),
          ),
          if (passed)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text('Continue'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScoreRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return hours == '00' ? '$minutes:$seconds' : '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.exam.title),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.exam.title,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 2),
            Text(
              'Question ${(_pageController.hasClients ? (_pageController.page?.toInt() ?? 0) : 0) + 1}/${_questions.length}',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _remainingTime.inMinutes < 5 ? Colors.red.shade800 : Colors.white24,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.timer,
                  size: 16,
                  color: Colors.white,
                ),
                SizedBox(width: 4),
                Text(
                  _formatTime(_remainingTime),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: (_pageController.hasClients ? (_pageController.page?.toInt() ?? 0) : 0) / (_questions.length - 1),
            backgroundColor: Colors.grey.shade200,
            color: Colors.blue,
            minHeight: 3,
          ),

          // Questions
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _questions.length,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return ExamQuestionWidget(
                  question: _questions[index],
                  questionNumber: index + 1,
                  totalQuestions: _questions.length,
                  selectedAnswer: _selectedAnswers[index],
                  onAnswerSelected: (answerIndex) {
                    setState(() {
                      _selectedAnswers[index] = answerIndex;
                    });
                  },
                  onNext: () {
                    if (index < _questions.length - 1) {
                      _pageController.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  onPrevious: () {
                    if (index > 0) {
                      _pageController.previousPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Submit Exam?'),
                      content: Text('Are you sure you want to submit your exam? You cannot change answers after submission.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _submitExam();
                          },
                          child: Text('Submit'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  );
                },
                icon: Icon(Icons.send),
                label: Text('Submit Exam'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}