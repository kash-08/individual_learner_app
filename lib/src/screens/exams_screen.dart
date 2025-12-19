import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/exam_provider.dart';
import '../models/exam_model.dart';
import 'exam_taking_screen.dart';
import 'coding_challenge_screen.dart';

class ExamsScreen extends StatefulWidget {
  const ExamsScreen({super.key});

  @override
  State<ExamsScreen> createState() => _ExamsScreenState();
}

class _ExamsScreenState extends State<ExamsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Load data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ExamProvider>(context, listen: false).loadExams();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Stats Overview
          _buildStatsOverview(),

          // Tabs
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF4361EE),
              unselectedLabelColor: const Color(0xFF6C757D),
              indicatorColor: const Color(0xFF4361EE),
              indicatorWeight: 3,
              tabs: const [
                Tab(text: 'Quizzes'),
                Tab(text: 'Coding'),
                Tab(text: 'Mock Exams'),
                Tab(text: 'Results'),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildQuizzesTab(),
                _buildCodingTab(),
                _buildMockExamsTab(),
                _buildResultsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF4361EE),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Challenges & Exams',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Test your knowledge and skills',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: () {
            Provider.of<ExamProvider>(context, listen: false).loadExams();
          },
        ),
      ],
    );
  }

  Widget _buildStatsOverview() {
    return Consumer<ExamProvider>(
      builder: (context, examProvider, child) {
        final stats = examProvider.statistics;

        return Card(
          margin: const EdgeInsets.all(16),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      stats['totalCompleted'].toString(),
                      'Exams Taken',
                      Icons.assignment_turned_in,
                    ),
                    _buildStatItem(
                      '${stats['averageScore'].toStringAsFixed(1)}%',
                      'Avg Score',
                      Icons.score,
                    ),
                    _buildStatItem(
                      stats['challengesCompleted'].toString(),
                      'Challenges',
                      Icons.code,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4361EE).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.emoji_events, color: Colors.amber[700], size: 16),
                      const SizedBox(width: 8),
                      Text(
                        '${stats['passedExams']} Passed • ${stats['failedExams']} Failed',
                        style: const TextStyle(
                          color: Color(0xFF4361EE),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF4361EE).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF4361EE), size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF212529),
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6C757D),
          ),
        ),
      ],
    );
  }

  Widget _buildQuizzesTab() {
    return Consumer<ExamProvider>(
      builder: (context, examProvider, child) {
        final quizzes = examProvider.availableExams
            .where((exam) => exam.examType == 'quiz')
            .toList();

        if (examProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (quizzes.isEmpty) {
          return _buildEmptyState('No quizzes available', 'Check back later for new quizzes');
        }

        return RefreshIndicator(
          onRefresh: () async {
            await examProvider.loadExams();
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: quizzes.length,
            itemBuilder: (context, index) {
              final quiz = quizzes[index];
              return _buildExamCard(quiz, examProvider);
            },
          ),
        );
      },
    );
  }

  Widget _buildCodingTab() {
    return Consumer<ExamProvider>(
      builder: (context, examProvider, child) {
        final challenges = examProvider.codingChallenges;

        if (examProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (challenges.isEmpty) {
          return _buildEmptyState('No coding challenges', 'Practice your coding skills with challenges');
        }

        return RefreshIndicator(
          onRefresh: () async {
            await examProvider.loadExams();
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: challenges.length,
            itemBuilder: (context, index) {
              final challenge = challenges[index];
              return _buildChallengeCard(challenge, examProvider);
            },
          ),
        );
      },
    );
  }

  Widget _buildMockExamsTab() {
    return Consumer<ExamProvider>(
      builder: (context, examProvider, child) {
        final mockExams = examProvider.availableExams
            .where((exam) => exam.examType == 'mock_exam')
            .toList();

        if (examProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (mockExams.isEmpty) {
          return _buildEmptyState('No mock exams', 'Prepare for certifications with practice exams');
        }

        return RefreshIndicator(
          onRefresh: () async {
            await examProvider.loadExams();
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: mockExams.length,
            itemBuilder: (context, index) {
              final exam = mockExams[index];
              return _buildExamCard(exam, examProvider);
            },
          ),
        );
      },
    );
  }

  Widget _buildResultsTab() {
    return Consumer<ExamProvider>(
      builder: (context, examProvider, child) {
        final results = examProvider.examResults;

        if (examProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (results.isEmpty) {
          return _buildEmptyState('No exam results', 'Take an exam to see your results here');
        }

        return RefreshIndicator(
          onRefresh: () async {
            await examProvider.loadExams();
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final result = results[index];
              return _buildResultCard(result);
            },
          ),
        );
      },
    );
  }

  Widget _buildExamCard(Exam exam, ExamProvider examProvider) {
    final result = examProvider.getExamResult(exam.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (result != null) {
            _showExamResult(context, result);
          } else {
            _startExam(context, exam);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      exam.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF212529),
                      ),
                    ),
                  ),
                  if (result != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: result.passed ? Colors.green[50] : Colors.red[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: result.passed ? Colors.green : Colors.red,
                        ),
                      ),
                      child: Text(
                        result.passed ? 'PASSED' : 'FAILED',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: result.passed ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                exam.description,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6C757D),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(exam.difficulty),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      exam.difficulty,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4361EE).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      exam.category,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF4361EE),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      const Icon(Icons.timer, size: 12, color: Color(0xFF6C757D)),
                      const SizedBox(width: 4),
                      Text(
                        '${exam.timeLimit} min',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF6C757D),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Row(
                    children: [
                      const Icon(Icons.question_answer, size: 12, color: Color(0xFF6C757D)),
                      const SizedBox(width: 4),
                      Text(
                        '${exam.totalQuestions} Q',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF6C757D),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (result != null) ...[
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: result.scorePercentage / 100,
                  backgroundColor: const Color(0xFFE9ECEF),
                  color: result.passed ? Colors.green : Colors.red,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Score: ${result.scorePercentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: result.passed ? Colors.green : Colors.red,
                      ),
                    ),
                    Text(
                      'Time: ${(result.timeTaken / 60).toStringAsFixed(1)} min',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6C757D),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _startExam(context, exam);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4361EE),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Start Exam'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChallengeCard(CodingChallenge challenge, ExamProvider examProvider) {
    final progress = examProvider.getChallengeProgress(challenge.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CodingChallengeScreen(
                challenge: challenge,
                initialCode: progress?.lastSubmittedCode ?? challenge.starterCode,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      challenge.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF212529),
                      ),
                    ),
                  ),
                  if (progress?.completed == true)
                    const Icon(Icons.check_circle, color: Colors.green, size: 20),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                challenge.description,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6C757D),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(challenge.difficulty),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      challenge.difficulty,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.amber[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.code, size: 10, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          challenge.language.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.amber,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (progress != null) ...[
                    Text(
                      '${progress.attempts} attempts',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF6C757D),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Best: ${progress.bestScore.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF4361EE),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ] else ...[
                    Text(
                      '${challenge.points} points',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.amber,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CodingChallengeScreen(
                          challenge: challenge,
                          initialCode: progress?.lastSubmittedCode ?? challenge.starterCode,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4361EE),
                    foregroundColor: Colors.white,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.code, size: 16),
                      const SizedBox(width: 8),
                      Text(progress != null ? 'Continue' : 'Start Challenge'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard(ExamResult result) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          _showExamResult(context, result);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      result.examTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF212529),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: result.passed ? Colors.green[50] : Colors.red[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: result.passed ? Colors.green : Colors.red,
                      ),
                    ),
                    child: Text(
                      result.passed ? 'PASSED' : 'FAILED',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: result.passed ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Completed: ${_formatDate(result.completedAt)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6C757D),
                ),
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: result.scorePercentage / 100,
                backgroundColor: const Color(0xFFE9ECEF),
                color: result.passed ? Colors.green : Colors.red,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Score: ${result.scorePercentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: result.passed ? Colors.green : Colors.red,
                        ),
                      ),
                      Text(
                        '${result.correctAnswers}/${result.totalQuestions} correct',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6C757D),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Time: ${(result.timeTaken / 60).toStringAsFixed(1)} min',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF212529),
                        ),
                      ),
                      Text(
                        result.examType.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6C757D),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.insights, size: 14, color: Color(0xFF6C757D)),
                  const SizedBox(width: 4),
                  Text(
                    'Tap to view detailed results',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6C757D),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.quiz,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6C757D),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
      case 'easy':
        return const Color(0xFF4CAF50);
      case 'intermediate':
      case 'medium':
        return const Color(0xFFFF9800);
      case 'advanced':
      case 'hard':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF4361EE);
    }
  }

  void _startExam(BuildContext context, Exam exam) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExamTakingScreen(exam: exam),
      ),
    );
  }

  void _showExamResult(BuildContext context, ExamResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(result.examTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: result.passed ? Colors.green[50] : Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      result.passed ? '🎉 Congratulations!' : '💪 Keep Practicing!',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You ${result.passed ? 'passed' : 'did not pass'} this exam',
                      style: TextStyle(
                        fontSize: 14,
                        color: result.passed ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildResultDetail('Score', '${result.scorePercentage.toStringAsFixed(1)}%'),
              _buildResultDetail('Correct Answers', '${result.correctAnswers}/${result.totalQuestions}'),
              _buildResultDetail('Time Taken', '${(result.timeTaken / 60).toStringAsFixed(1)} minutes'),
              _buildResultDetail('Completed On', _formatDate(result.completedAt)),
              _buildResultDetail('Exam Type', result.examType.toUpperCase()),
              const SizedBox(height: 16),
              const Text(
                'Performance Breakdown:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              // Add detailed results here
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (!result.passed)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Retry exam
              },
              child: const Text('Retry Exam'),
            ),
        ],
      ),
    );
  }

  Widget _buildResultDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6C757D),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF212529),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}