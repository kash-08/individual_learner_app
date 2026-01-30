import 'package:flutter/material.dart';
import 'package:individual_learner_app/src/screens/result_details_screen.dart';
import 'package:provider/provider.dart';
import '../providers/exam_provider.dart';
import '../models/exam_model.dart';
import '../components/exam_question_widget.dart';
import 'dart:async';

// Import your UserProvider if needed
// import '../providers/user_provider.dart';

class TakeAssessmentScreen extends StatefulWidget {
  final String quizId;
  final String quizName;
  final String quizType;
  final String difficulty;
  final int? totalDuration;
  final int? totalQuestions;
  final int? totalPoints;
  final bool isDemo;

  const TakeAssessmentScreen({
    Key? key,
    required this.quizId,
    required this.quizName,
    required this.quizType,
    this.difficulty = 'Beginner',
    this.totalDuration,
    this.totalQuestions,
    this.totalPoints,
    required this.isDemo,
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
  int? _timeLimit;
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _showTimeWarning = false;
  late Timer _timer;
  late Timer _warningTimer;

  // Static questions for all assessments
  final Map<String, List<QuizQuestion>> _staticQuestions = {
    // Programming Basics Quiz
    'quiz_1': [
      QuizQuestion(
        id: 'q1_1',
        question: 'What does the acronym "OOP" stand for?',
        options: [
          'Object-Oriented Programming',
          'Object-Oriented Protocol',
          'Object-Optimized Programming',
          'Object-Operated Programming'
        ],
        correctAnswerIndex: 0,
        points: 10,
        explanation: 'OOP stands for Object-Oriented Programming, a programming paradigm based on objects.',
        category: '',
      ),
      QuizQuestion(
        id: 'q1_2',
        question: 'Which data structure uses LIFO (Last In, First Out) principle?',
        options: ['Queue', 'Stack', 'Array', 'Linked List'],
        correctAnswerIndex: 1,
        points: 15,
        explanation: 'Stack uses LIFO principle while Queue uses FIFO (First In, First Out).',
        category: '',
      ),
      QuizQuestion(
        id: 'q1_3',
        question: 'What is the time complexity of binary search?',
        options: ['O(n)', 'O(log n)', 'O(n²)', 'O(1)'],
        correctAnswerIndex: 1,
        points: 20,
        explanation: 'Binary search has O(log n) time complexity as it divides the search space in half each time.',
        category: '',
      ),
    ],

    // Dart Syntax Quiz
    'quiz_2': [
      QuizQuestion(
        id: 'q2_1',
        question: 'What keyword is used to define a constant in Dart?',
        options: ['var', 'final', 'const', 'static'],
        correctAnswerIndex: 2,
        points: 10,
        explanation: 'The "const" keyword is used for compile-time constants in Dart.',
        category: '',
      ),
      QuizQuestion(
        id: 'q2_2',
        question: 'Which of the following is NOT a valid Dart data type?',
        options: ['int', 'double', 'string', 'bool'],
        correctAnswerIndex: 2,
        points: 15,
        explanation: 'Dart uses "String" (with capital S), not "string".',
        category: '',
      ),
      QuizQuestion(
        id: 'q2_3',
        question: 'How do you define a private variable in Dart?',
        options: [
          'Using private keyword',
          'Starting with underscore (_)',
          'Using # symbol',
          'Dart doesn\'t support private variables'
        ],
        correctAnswerIndex: 1,
        points: 20,
        explanation: 'In Dart, private variables start with an underscore (_).',
        category: '',
      ),
      QuizQuestion(
        id: 'q2_4',
        question: 'What is the purpose of async/await in Dart?',
        options: [
          'To create synchronous functions',
          'To handle asynchronous operations',
          'To improve performance',
          'To define classes'
        ],
        correctAnswerIndex: 1,
        points: 25,
        explanation: 'async/await is used for handling asynchronous operations without callbacks.',
        category: '',
      ),
      QuizQuestion(
        id: 'q2_5',
        question: 'Which method is called when a Dart object is created?',
        options: ['init()', 'create()', 'constructor()', 'build()'],
        correctAnswerIndex: 2,
        points: 20,
        explanation: 'The constructor method is called when an object is instantiated.',
        category: '',
      ),
    ],

    // Dart Coding Challenge
    'coding_1': [
      QuizQuestion(
        id: 'c1_1',
        question: 'Write a function to calculate factorial of a number',
        options: [
          'Iterative approach',
          'Recursive approach',
          'Both are correct',
          'Neither is correct'
        ],
        correctAnswerIndex: 2,
        points: 75,
        explanation: 'Factorial can be calculated using both iterative and recursive approaches.',
        category: '',
      ),
      QuizQuestion(
        id: 'c1_2',
        question: 'Which is the most efficient way to find duplicates in a list?',
        options: [
          'Using nested loops',
          'Using a Set',
          'Using sort and compare',
          'All are equally efficient'
        ],
        correctAnswerIndex: 1,
        points: 75,
        explanation: 'Using a Set provides O(n) time complexity for finding duplicates.',
        category: '',
      ),
    ],

    // Flutter Widget Challenge
    'coding_2': [
      QuizQuestion(
        id: 'c2_1',
        question: 'Which widget is used for scrollable content in Flutter?',
        options: ['Column', 'Row', 'ListView', 'Container'],
        correctAnswerIndex: 2,
        points: 20,
        explanation: 'ListView provides scrollable content in Flutter.',
        category: '',
      ),
      QuizQuestion(
        id: 'c2_2',
        question: 'What is the purpose of the build() method in Flutter?',
        options: [
          'To initialize variables',
          'To build the widget tree',
          'To handle user input',
          'To manage state'
        ],
        correctAnswerIndex: 1,
        points: 25,
        explanation: 'The build() method returns the widget tree for the current state.',
        category: '',
      ),
      QuizQuestion(
        id: 'c2_3',
        question: 'Which widget is NOT a layout widget?',
        options: ['Container', 'Text', 'Row', 'Column'],
        correctAnswerIndex: 1,
        points: 15,
        explanation: 'Text is a basic widget, not a layout widget.',
        category: '',
      ),
    ],

    // Flutter Mock Exam
    'exam_1': [
      QuizQuestion(
        id: 'e1_1',
        question: 'What is the difference between StatelessWidget and StatefulWidget?',
        options: [
          'StatelessWidget has mutable state',
          'StatefulWidget has mutable state',
          'They are the same',
          'Neither has state'
        ],
        correctAnswerIndex: 1,
        points: 25,
        explanation: 'StatefulWidget has mutable state while StatelessWidget does not.',
        category: '',
      ),
      QuizQuestion(
        id: 'e1_2',
        question: 'What is the purpose of the pubspec.yaml file?',
        options: [
          'To define app settings',
          'To manage dependencies',
          'To configure themes',
          'To define routes'
        ],
        correctAnswerIndex: 1,
        points: 25,
        explanation: 'pubspec.yaml manages dependencies and metadata for Flutter projects.',
        category: '',
      ),
      QuizQuestion(
        id: 'e1_3',
        question: 'How do you handle navigation in Flutter?',
        options: [
          'Using Navigator',
          'Using Router',
          'Using RouteManager',
          'Using NavigationController'
        ],
        correctAnswerIndex: 0,
        points: 25,
        explanation: 'Navigation in Flutter is handled using the Navigator class.',
        category: '',
      ),
      QuizQuestion(
        id: 'e1_4',
        question: 'What is BuildContext in Flutter?',
        options: [
          'A handle to location in widget tree',
          'A build configuration',
          'A context menu',
          'A debugging tool'
        ],
        correctAnswerIndex: 0,
        points: 25,
        explanation: 'BuildContext is a handle to the location of a widget in the widget tree.',
        category: '',
      ),
    ],

    // Demo Quizzes
    'demo_quiz_1': [
      QuizQuestion(
        id: 'd1_1',
        question: 'What is a variable in programming?',
        options: [
          'A fixed value',
          'A container for storing data',
          'A function',
          'A loop'
        ],
        correctAnswerIndex: 1,
        points: 10,
        explanation: 'A variable is a named container for storing data values.',
        category: '',
      ),
      QuizQuestion(
        id: 'd1_2',
        question: 'Which of these is a programming language?',
        options: ['HTML', 'CSS', 'Dart', 'XML'],
        correctAnswerIndex: 2,
        points: 15,
        explanation: 'Dart is a programming language, while others are markup or styling languages.',
        category: '',
      ),
      QuizQuestion(
        id: 'd1_3',
        question: 'What does IDE stand for?',
        options: [
          'Integrated Development Environment',
          'Interactive Development Engine',
          'Integrated Design Environment',
          'Interactive Debugging Environment'
        ],
        correctAnswerIndex: 0,
        points: 20,
        explanation: 'IDE stands for Integrated Development Environment.',
        category: '',
      ),
    ],

    'demo_quiz_2': [
      QuizQuestion(
        id: 'd2_1',
        question: 'What is the main purpose of Dart?',
        options: [
          'Web development only',
          'Mobile app development only',
          'Both web and mobile development',
          'Desktop applications only'
        ],
        correctAnswerIndex: 2,
        points: 50,
        explanation: 'Dart is used for both web and mobile app development, especially with Flutter.',
        category: '',
      ),
      QuizQuestion(
        id: 'd2_2',
        question: 'Which keyword is used to define a function in Dart?',
        options: ['function', 'def', 'fun', 'void or return type'],
        correctAnswerIndex: 3,
        points: 50,
        explanation: 'Functions in Dart are defined with a return type or void keyword.',
        category: '',
      ),
    ],
  };

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _initializeTimeLimit();
    _loadQuestions();
    _startTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // This ensures we have access to providers when the widget rebuilds
    if (_questions.isEmpty && !_isLoading) {
      _loadQuestions();
    }
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
      _timeLimit = widget.totalDuration! * 60;
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

      if (_timeLimit != null && _timeSpent >= _timeLimit!) {
        _timer.cancel();
        _showTimeUpDialog();
      }
    });
  }

  Future<void> _loadQuestions() async {
    try {
      // Get questions from static list based on quizId
      if (_staticQuestions.containsKey(widget.quizId)) {
        _questions = _staticQuestions[widget.quizId]!;
      } else {
        // Fallback: Get from provider for backward compatibility
        final provider = Provider.of<ExamProvider>(context, listen: false);
        _questions = await provider.getQuizQuestions(widget.quizId);
      }

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

      // For demo quizzes, we might want to handle differently
      if (widget.isDemo) {
        // Show demo results without saving to provider
        _showDemoResults(answeredQuestions);
        return;
      }

      // Calculate results locally first
      final localResult = _calculateLocalResult(answeredQuestions);

      // Try to submit to provider, but handle permission errors gracefully
      try {
        final result = await provider.submitQuiz(
          quizId: widget.quizId,
          quizName: widget.quizName,
          quizType: widget.quizType,
          userAnswers: answeredQuestions,
          timeSpent: _timeSpent,
          totalQuestions: widget.totalQuestions ?? _questions.length,
          totalPoints: widget.totalPoints,
          difficulty: widget.difficulty,
        );

        // Navigate to result screen WITH the current context
        // This ensures ResultDetailsScreen has access to all providers
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ResultDetailsScreen(result: result, userName: '', userEmail: '',),
          ),
        );
      } catch (firestoreError) {
        print('Firestore submission error: $firestoreError');

        // Fallback: Use locally calculated result and show offline message
        _showOfflineResult(localResult);
      }
    } catch (e) {
      print('General submission error: $e');
      setState(() => _isSubmitting = false);

      // Show user-friendly error message
      _showErrorDialog(e);
    }
  }

  // Calculate result locally without Firestore
  QuizResult _calculateLocalResult(List<Map<String, dynamic>> answeredQuestions) {
    int correctAnswers = 0;
    int totalPoints = 0;
    List<Map<String, dynamic>> questionResults = [];

    for (var answer in answeredQuestions) {
      final questionIndex = _questions.indexWhere((q) => q.id == answer['questionId']);
      if (questionIndex != -1) {
        final question = _questions[questionIndex];
        final isCorrect = answer['selectedIndex'] == question.correctAnswerIndex;

        if (isCorrect) {
          correctAnswers++;
          totalPoints += question.points;
        }

        questionResults.add({
          'question': question.question,
          'isCorrect': isCorrect,
          'selectedAnswer': question.options[answer['selectedIndex']],
          'correctAnswer': question.options[question.correctAnswerIndex],
          'explanation': question.explanation,
          'points': isCorrect ? question.points : 0,
          'timeSpent': answer['timeSpentOnQuestion'],
        });
      }
    }

    return QuizResult(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'local_user',
      quizId: widget.quizId,
      quizName: widget.quizName,
      quizType: widget.quizType,
      score: totalPoints,
      totalQuestions: widget.totalQuestions ?? _questions.length,
      correctAnswers: correctAnswers,
      timeSpent: _timeSpent,
      completedAt: DateTime.now(),
      questionResults: questionResults,
    );
  }

  void _showOfflineResult(QuizResult result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.cloud_off, color: Colors.orange),
            SizedBox(width: 10),
            Text('Offline Mode'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your quiz results have been saved locally.'),
            SizedBox(height: 12),
            Text('Score: ${result.percentage.toStringAsFixed(1)}%'),
            Text('Correct: ${result.correctAnswers}/${result.totalQuestions}'),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Text(
                'Results will be synced when you\'re back online.',
                style: TextStyle(color: Colors.orange[800]),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Go back to challenges screen
            },
            child: Text('OK'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate with context to ensure providers are available
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => ResultDetailsScreen(result: result, userName: '', userEmail: '',),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: Text('View Results'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(dynamic error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 10),
            Text('Submission Error'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('There was an error submitting your quiz:'),
            SizedBox(height: 8),
            Text(
              error.toString(),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontFamily: 'Monospace',
              ),
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Text(
                'Please check your internet connection or try again later.',
                style: TextStyle(color: Colors.red[800]),
              ),
            ),
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
              setState(() => _isSubmitting = false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showDemoResults(List<Map<String, dynamic>> answeredQuestions) {
    // Calculate demo results manually
    int correctAnswers = 0;
    int totalPoints = 0;
    int maxPoints = widget.totalPoints ?? 100;
    List<Map<String, dynamic>> questionResults = [];

    for (var answer in answeredQuestions) {
      final questionIndex = _questions.indexWhere((q) => q.id == answer['questionId']);
      if (questionIndex != -1) {
        final question = _questions[questionIndex];
        final isCorrect = answer['selectedIndex'] == question.correctAnswerIndex;

        if (isCorrect) {
          correctAnswers++;
          totalPoints += question.points;
        }

        questionResults.add({
          'question': question.question,
          'isCorrect': isCorrect,
          'selectedAnswer': question.options[answer['selectedIndex']],
          'correctAnswer': question.options[question.correctAnswerIndex],
          'explanation': question.explanation,
          'points': isCorrect ? question.points : 0,
          'timeSpent': answer['timeSpentOnQuestion'],
        });
      }
    }

    final demoResult = QuizResult(
      id: 'demo_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'demo_user',
      quizId: widget.quizId,
      quizName: widget.quizName,
      quizType: widget.quizType,
      score: totalPoints,
      totalQuestions: widget.totalQuestions ?? _questions.length,
      correctAnswers: correctAnswers,
      timeSpent: _timeSpent,
      completedAt: DateTime.now(),
      questionResults: questionResults,
    );

    // Calculate percentage using the getter
    final double percentage = demoResult.percentage;
    final String grade = demoResult.grade;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.science, color: Colors.orange),
            SizedBox(width: 10),
            Text('Demo Quiz Results'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This is a demo quiz. Results are not saved.'),
            SizedBox(height: 16),
            Text('Quiz: ${widget.quizName}'),
            Text('Type: ${widget.quizType}'),
            Text('Difficulty: ${widget.difficulty}'),
            SizedBox(height: 12),
            Divider(),
            SizedBox(height: 12),
            Text('Correct Answers: $correctAnswers/${demoResult.totalQuestions}'),
            Text('Points Earned: $totalPoints/$maxPoints'),
            Text('Percentage: ${percentage.toStringAsFixed(1)}%'),
            Text('Grade: $grade'),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Text(
                'To save your progress, try the regular quizzes above!',
                style: TextStyle(color: Colors.orange[800]),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Try Another Demo'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate with context to ensure providers are available
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => ResultDetailsScreen(result: demoResult, userName: '', userEmail: '',),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: Text('View Detailed Results'),
          ),
        ],
      ),
    );
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
      } else if (timeRemaining <= 300) {
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
        SizedBox(height: 2),
        Row(
          children: [
            Text(
              '${widget.quizType} • ',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            if (widget.isDemo) ...[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  'Demo',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(width: 4),
            ],
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getDifficultyColor(widget.difficulty).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: _getDifficultyColor(widget.difficulty).withOpacity(0.3),
                ),
              ),
              child: Text(
                widget.difficulty,
                style: TextStyle(
                  fontSize: 10,
                  color: _getDifficultyColor(widget.difficulty),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return Colors.blue;
    }
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
            if (widget.isDemo)
              Container(
                padding: EdgeInsets.all(8),
                margin: EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.science, size: 16, color: Colors.orange),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This is a demo quiz. Results will not be saved.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
            SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getDifficultyColor(widget.difficulty),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(width: 6),
                Text(
                  'Difficulty: ${widget.difficulty}',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: _getDifficultyColor(widget.difficulty),
                  ),
                ),
              ],
            ),
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
              backgroundColor: widget.isDemo ? Colors.orange : Colors.green,
            ),
            child: Text(widget.isDemo ? 'View Demo Results' : 'Submit Now'),
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
    // Ensure we have access to ExamProvider
    final examProvider = Provider.of<ExamProvider>(context, listen: false);

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
            SizedBox(height: 4),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _getDifficultyColor(widget.difficulty).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Difficulty: ${widget.difficulty}',
                style: TextStyle(
                  fontSize: 12,
                  color: _getDifficultyColor(widget.difficulty),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (widget.isDemo)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                margin: EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Demo Quiz - Results not saved',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange,
                    fontWeight: FontWeight.w500,
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
                          difficulty: widget.difficulty,
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
                        label: Text(_isSubmitting ? 'Submitting...' : widget.isDemo ? 'View Results' : 'Submit'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.isDemo ? Colors.orange : Colors.green,
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
                      widget.isDemo ? 'Calculating results...' : 'Submitting your answers...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 10),
                    if (!widget.isDemo)
                      Text(
                        'Please wait...',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
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
        backgroundColor: widget.isDemo ? Colors.orange : Colors.blue,
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
                          ? (widget.isDemo ? Colors.orange : Colors.blue)
                          : (isAnswered ? Colors.green : Colors.grey[200]),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isCurrent ? (widget.isDemo ? Colors.orange[900]! : Colors.blue[900]!) : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: [
                        if (isCurrent)
                          BoxShadow(
                            color: (widget.isDemo ? Colors.orange : Colors.blue).withOpacity(0.3),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total: ${_questions.length} questions',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  SizedBox(height: 2),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(widget.difficulty).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Difficulty: ${widget.difficulty}',
                      style: TextStyle(
                        fontSize: 10,
                        color: _getDifficultyColor(widget.difficulty),
                      ),
                    ),
                  ),
                  if (widget.isDemo)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      margin: EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Demo Quiz',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                ],
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
                    color: userAnswer['selectedIndex'] == question.correctAnswerIndex ? Colors.green[700] : Colors.red[700],
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
              if (question.explanation.isNotEmpty) ...[
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Explanation: ${question.explanation}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[800],
                    ),
                  ),
                ),
              ],
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
              Navigator.pop(context);
              _jumpToQuestion(index);
            },
            child: Text('Go to Question'),
          ),
        ],
      ),
    );
  }
}