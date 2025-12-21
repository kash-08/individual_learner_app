import 'package:flutter/material.dart';
import 'package:individual_learner_app/src/screens/result_details_screen.dart';
import 'package:provider/provider.dart';
import '../providers/exam_provider.dart';
import '../models/exam_model.dart';
import '../components/exam_question_widget.dart';
import 'dart:async';

class TakeAssessmentScreen extends StatefulWidget {
  final String quizId;
  final String quizName;
  final String quizType;
  final int? totalDuration; // Duration in minutes (optional)
  final int? totalQuestions; // Total questions (optional)
  final int? totalPoints; // Total points (optional)

  const TakeAssessmentScreen({
    Key? key,
    required this.quizId,
    required this.quizName,
    required this.quizType,
    this.totalDuration,
    this.totalQuestions,
    this.totalPoints,
  }) : super(key: key);

  @override
  _TakeAssessmentScreenState createState() => _TakeAssessmentScreenState();
}

class _TakeAssessmentScreenState extends State<TakeAssessmentScreen> {
  late PageController _pageController;
  List<QuizQuestion> _questions = [];
  List<Map<String, dynamic>> _userAnswers = [];
  int _currentPage = 0;
  int _timeSpent = 0;
  int? _timeLimit; // Time limit in seconds
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _showTimeWarning = false;
  late Timer _timer;
  late Timer _warningTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _initializeTimeLimit();
    _loadQuestions();
    _startTimer();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer.cancel();
    _warningTimer.cancel();
    super.dispose();
  }

  void _initializeTimeLimit() {
    if (widget.totalDuration != null) {
      _timeLimit = widget.totalDuration! * 60; // Convert minutes to seconds
      // Start warning timer (show warning when 1 minute remaining)
      _warningTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (_timeLimit != null && _timeSpent >= _timeLimit! - 60) {
          setState(() {
            _showTimeWarning = true;
          });
        }
      });
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _timeSpent++;
      });

      // Auto-submit when time limit reached
      if (_timeLimit != null && _timeSpent >= _timeLimit!) {
        _timer.cancel();
        _showTimeUpDialog();
      }
    });
  }

  Future<void> _loadQuestions() async {
    try {
      final provider = Provider.of<ExamProvider>(context, listen: false);
      _questions = await provider.getQuizQuestions(widget.quizId);

      // Initialize empty answers
      _userAnswers = List.generate(_questions.length, (index) => {
        'questionId': _questions[index].id,
        'selectedIndex': -1,
        'answered': false,
        'timestamp': DateTime.now(),
        'timeSpentOnQuestion': 0,
      });

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading questions: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load questions: $e')),
      );
    }
  }

  void _onAnswerSelected(int questionIndex, int selectedIndex) {
    setState(() {
      _userAnswers[questionIndex] = {
        ..._userAnswers[questionIndex],
        'selectedIndex': selectedIndex,
        'answered': true,
        'timestamp': DateTime.now(),
      };
    });
  }

  void _updateTimeSpentOnQuestion(int questionIndex) {
    if (questionIndex >= 0 && questionIndex < _userAnswers.length) {
      final currentTime = DateTime.now();
      final lastTimestamp = _userAnswers[questionIndex]['timestamp'];
      if (lastTimestamp is DateTime) {
        final timeDiff = currentTime.difference(lastTimestamp).inSeconds;
        setState(() {
          _userAnswers[questionIndex]['timeSpentOnQuestion'] += timeDiff;
        });
      }
    }
  }

  void _showTimeUpDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.timer_off, color: Colors.red),
            SizedBox(width: 10),
            Text('Time\'s Up!'),
          ],
        ),
        content: Text('The time limit for this quiz has been reached. Your answers will be automatically submitted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    ).then((_) {
      _submitQuiz();
    });
  }

  Future<void> _submitQuiz() async {
    if (_isSubmitting) return;

    try {
      setState(() => _isSubmitting = true);
      _timer.cancel();
      if (_timeLimit != null) _warningTimer.cancel();

      final provider = Provider.of<ExamProvider>(context, listen: false);

      // Calculate total time spent per question
      for (int i = 0; i < _userAnswers.length; i++) {
        if (i == _currentPage) {
          _updateTimeSpentOnQuestion(i);
        }
      }

      // Filter only answered questions
      final answeredQuestions = _userAnswers
          .where((answer) => answer['answered'] && answer['selectedIndex'] != -1)
          .toList();

      final result = await provider.submitQuiz(
        quizId: widget.quizId,
        quizName: widget.quizName,
        quizType: widget.quizType,
        userAnswers: answeredQuestions,
        timeSpent: _timeSpent,
        totalQuestions: widget.totalQuestions ?? _questions.length,
        totalPoints: widget.totalPoints,
      );

      // Navigate to result screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultDetailsScreen(result: result),
        ),
      );
    } catch (e) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit quiz: $e')),
      );
    }
  }

  Widget _buildProgressIndicator() {
    final total = _questions.length;
    final answered = _userAnswers.where((a) => a['answered']).length;

    return LinearProgressIndicator(
      value: total > 0 ? answered / total : 0,
      backgroundColor: Colors.grey[300],
      valueColor: AlwaysStoppedAnimation<Color>(
        answered == total ? Colors.green : Colors.blue,
      ),
    );
  }

  Widget _buildTimer() {
    final minutes = (_timeSpent ~/ 60).toString().padLeft(2, '0');
    final seconds = (_timeSpent % 60).toString().padLeft(2, '0');

    Color timerColor = Colors.blue[700]!;
    if (_timeLimit != null) {
      final timeRemaining = _timeLimit! - _timeSpent;
      if (timeRemaining <= 60) {
        timerColor = Colors.red;
      } else if (timeRemaining <= 300) { // 5 minutes
        timerColor = Colors.orange;
      }
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _showTimeWarning ? Colors.red[50] : Colors.blue[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: timerColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _showTimeWarning ? Icons.warning : Icons.timer,
            size: 16,
            color: timerColor,
          ),
          SizedBox(width: 6),
          Text(
            '$minutes:$seconds',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: timerColor,
            ),
          ),
          if (_timeLimit != null) ...[
            SizedBox(width: 4),
            Text(
              '/${_timeLimit! ~/ 60}:${(_timeLimit! % 60).toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 12,
                color: timerColor.withOpacity(0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuestionCounter() {
    final answered = _userAnswers.where((a) => a['answered']).length;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: answered == _questions.length ? Colors.green[50] : Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: answered == _questions.length ? Colors.green : Colors.grey[300]!,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${_currentPage + 1}/${_questions.length}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: answered == _questions.length ? Colors.green[800] : Colors.grey[700],
            ),
          ),
          if (_questions.length > 0)
            Text(
              '$answered answered',
              style: TextStyle(
                fontSize: 10,
                color: answered == _questions.length ? Colors.green[600] : Colors.grey[500],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAppBarTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.quizName,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        if (widget.quizType.isNotEmpty)
          Text(
            widget.quizType,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
      ],
    );
  }

  void _showSubmitConfirmation() {
    final answered = _userAnswers.where((a) => a['answered']).length;
    final unanswered = _questions.length - answered;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Submit Quiz?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You have answered $answered out of ${_questions.length} questions.'),
            if (unanswered > 0) ...[
              SizedBox(height: 8),
              Text(
                '$unanswered question${unanswered > 1 ? 's are' : ' is'} unanswered.',
                style: TextStyle(color: Colors.orange[700]),
              ),
              SizedBox(height: 4),
              Text('Are you sure you want to submit?'),
            ],
            if (widget.totalDuration != null) ...[
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.timer, size: 16, color: Colors.blue),
                  SizedBox(width: 4),
                  Text('Time spent: ${_formatTime(_timeSpent)}'),
                ],
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _submitQuiz();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: Text('Submit Now'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _jumpToQuestion(int index) {
    _updateTimeSpentOnQuestion(_currentPage);
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() {
      _currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildAppBarTitle(),
        actions: [
          if (_questions.isNotEmpty) _buildQuestionCounter(),
          SizedBox(width: 8),
          if (!_isLoading) _buildTimer(),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(4),
          child: _isLoading ? SizedBox() : _buildProgressIndicator(),
        ),
      ),
      body: _isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading Questions...',
              style: TextStyle(color: Colors.grey[600]),
            ),
            if (widget.totalDuration != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Time Limit: ${widget.totalDuration} minutes',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue[700],
                  ),
                ),
              ),
          ],
        ),
      )
          : _questions.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No questions available',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadQuestions,
              child: Text('Retry'),
            ),
          ],
        ),
      )
          : Stack(
        children: [
          Column(
            children: [
              if (_showTimeWarning)
                Container(
                  padding: EdgeInsets.all(12),
                  color: Colors.red[50],
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Less than 1 minute remaining!',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: NotificationListener<ScrollEndNotification>(
                  onNotification: (notification) {
                    if (notification.dragDetails != null) {
                      _updateTimeSpentOnQuestion(_currentPage);
                    }
                    return false;
                  },
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _questions.length,
                    physics: BouncingScrollPhysics(),
                    onPageChanged: (index) {
                      _updateTimeSpentOnQuestion(_currentPage);
                      setState(() => _currentPage = index);
                    },
                    itemBuilder: (context, index) {
                      final question = _questions[index];
                      final userAnswer = _userAnswers[index];

                      return SingleChildScrollView(
                        padding: EdgeInsets.all(16.0),
                        child: ExamQuestionWidget(
                          question: question,
                          questionNumber: index + 1,
                          totalQuestions: _questions.length,
                          selectedIndex: userAnswer['selectedIndex'],
                          onAnswerSelected: (selectedIndex) {
                            _onAnswerSelected(index, selectedIndex);
                          },
                          showPoints: widget.totalPoints != null,
                        ),
                      );
                    },
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.grey[200]!)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _currentPage > 0
                          ? () => _jumpToQuestion(_currentPage - 1)
                          : null,
                      icon: Icon(Icons.arrow_back),
                      label: Text('Previous'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.grey[800],
                      ),
                    ),

                    if (_currentPage < _questions.length - 1)
                      ElevatedButton.icon(
                        onPressed: () => _jumpToQuestion(_currentPage + 1),
                        icon: Text('Next'),
                        label: Icon(Icons.arrow_forward),
                      )
                    else
                      ElevatedButton.icon(
                        onPressed: _isSubmitting ? null : _showSubmitConfirmation,
                        icon: _isSubmitting
                            ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : Icon(Icons.check_circle),
                        label: Text(_isSubmitting ? 'Submitting...' : 'Submit'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (_isSubmitting)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 20),
                    Text(
                      'Submitting your answers...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: _questions.length > 1
          ? FloatingActionButton(
        onPressed: () {
          _updateTimeSpentOnQuestion(_currentPage);
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            builder: (context) => _buildQuestionsOverview(),
          );
        },
        child: Icon(Icons.list),
        mini: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      )
          : null,
      bottomNavigationBar: _questions.isNotEmpty
          ? BottomAppBar(
        height: 60,
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                if (_currentPage > 0) {
                  _jumpToQuestion(0);
                }
              },
              icon: Icon(Icons.first_page),
              tooltip: 'First Question',
            ),
            IconButton(
              onPressed: () {
                final unansweredIndex = _userAnswers
                    .indexWhere((answer) => !answer['answered'] || answer['selectedIndex'] == -1);
                if (unansweredIndex != -1) {
                  _jumpToQuestion(unansweredIndex);
                }
              },
              icon: Icon(Icons.skip_next),
              tooltip: 'Next Unanswered',
            ),
            IconButton(
              onPressed: () {
                final answeredIndex = _userAnswers
                    .lastIndexWhere((answer) => answer['answered'] && answer['selectedIndex'] != -1);
                if (answeredIndex != -1 && answeredIndex != _currentPage) {
                  _jumpToQuestion(answeredIndex);
                }
              },
              icon: Icon(Icons.skip_previous),
              tooltip: 'Previous Answered',
            ),
            IconButton(
              onPressed: () {
                if (_currentPage < _questions.length - 1) {
                  _jumpToQuestion(_questions.length - 1);
                }
              },
              icon: Icon(Icons.last_page),
              tooltip: 'Last Question',
            ),
          ],
        ),
      )
          : null,
    );
  }

  Widget _buildQuestionsOverview() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Questions Overview',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(width: 6),
                  Text('Current', style: TextStyle(fontSize: 12)),
                  SizedBox(width: 12),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(width: 6),
                  Text('Answered', style: TextStyle(fontSize: 12)),
                  SizedBox(width: 12),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(width: 6),
                  Text('Unanswered', style: TextStyle(fontSize: 12)),
                ],
              ),
            ],
          ),
          SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.0,
              ),
              itemCount: _questions.length,
              itemBuilder: (context, index) {
                final isAnswered = _userAnswers[index]['answered'] &&
                    _userAnswers[index]['selectedIndex'] != -1;
                final isCurrent = index == _currentPage;

                return GestureDetector(
                  onTap: () {
                    _jumpToQuestion(index);
                    Navigator.pop(context);
                  },
                  onLongPress: () {
                    _showQuestionPreview(index);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? Colors.blue
                          : (isAnswered ? Colors.green : Colors.grey[200]),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isCurrent ? Colors.blue[900]! : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: [
                        if (isCurrent)
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                      ],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isCurrent || isAnswered
                                  ? Colors.white
                                  : Colors.grey[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (isAnswered)
                            Icon(
                              Icons.check,
                              size: 12,
                              color: Colors.white,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total: ${_questions.length} questions',
                style: TextStyle(color: Colors.grey[600]),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showQuestionPreview(int index) {
    final question = _questions[index];
    final userAnswer = _userAnswers[index];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Question ${index + 1} Preview'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                question.question,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              if (userAnswer['answered'])
                Text(
                  'Your answer: ${question.options[userAnswer['selectedIndex']]}',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                  ),
                )
              else
                Text(
                  'Not answered yet',
                  style: TextStyle(
                    color: Colors.orange[700],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              SizedBox(height: 8),
              Text(
                'Time spent: ${userAnswer['timeSpentOnQuestion']} seconds',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close preview
              _jumpToQuestion(index);
            },
            child: Text('Go to Question'),
          ),
        ],
      ),
    );
  }
}
