// lib/screens/challenges_exams_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/assesment_service.dart';
import '../providers/exam_provider.dart';
import 'take_assesment_screen.dart';
import 'result_details_screen.dart';
import 'progress_updates_screen.dart';

class ChallengesExamsScreen extends StatefulWidget {
  const ChallengesExamsScreen({Key? key}) : super(key: key);

  @override
  _ChallengesExamsScreenState createState() => _ChallengesExamsScreenState();
}

class _ChallengesExamsScreenState extends State<ChallengesExamsScreen> {
  final AssessmentService _assessmentService = AssessmentService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _quizzes = [];
  List<Map<String, dynamic>> _challenges = [];
  List<Map<String, dynamic>> _exams = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Get all quizzes
      final allQuizzes = await _assessmentService.getAvailableQuizzes();

      // Get completed assessments from provider
      final examProvider = Provider.of<ExamProvider>(context, listen: false);
      await examProvider.loadUserResults(); // Ensure results are loaded

      // Separate by type
      setState(() {
        _quizzes = allQuizzes.where((q) => q['type'] == 'quiz').toList();
        _challenges = allQuizzes.where((q) => q['type'] == 'coding').toList();
        _exams = allQuizzes.where((q) => q['type'] == 'exam').toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildAssessmentCard(Map<String, dynamic> assessment, Color color) {
    final examProvider = Provider.of<ExamProvider>(context, listen: false);
    final isCompleted = examProvider.isQuizCompleted(assessment['id'] ?? '');

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          if (isCompleted) {
            // Navigate to results if completed
            _viewResults(assessment);
          } else {
            // Show details if not completed
            _showAssessmentDetails(assessment);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isCompleted ? Colors.green.withOpacity(0.1) : color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      assessment['type'] == 'quiz' ? Icons.quiz_outlined :
                      assessment['type'] == 'coding' ? Icons.code_outlined :
                      Icons.assignment_outlined,
                      color: isCompleted ? Colors.green : color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          assessment['name'] ?? 'Assessment',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isCompleted ? Colors.green : Colors.black,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          assessment['description'] ?? 'Test your knowledge',
                          style: TextStyle(
                            fontSize: 12,
                            color: isCompleted ? Colors.green.shade600 : Colors.grey.shade600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (isCompleted)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.check_circle, size: 12, color: Colors.green),
                          SizedBox(width: 4),
                          Text(
                            'Completed',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoChip(
                    '${assessment['questionIds']?.length ?? assessment['totalQuestions'] ?? 0} Qs',
                    Icons.question_answer_outlined,
                  ),
                  _buildInfoChip(
                    '${(assessment['totalPoints'] ?? 100)} pts',
                    Icons.star_border_outlined,
                  ),
                  _buildInfoChip(
                    _formatTime(assessment['timeLimit'] ?? 0),
                    Icons.timer_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(assessment['difficulty'] ?? 'Beginner'),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      assessment['difficulty'] ?? 'Beginner',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (isCompleted)
                    OutlinedButton(
                      onPressed: () {
                        _viewResults(assessment);
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.green),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: const Text(
                        'View Results',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else
                    ElevatedButton(
                      onPressed: () {
                        _startAssessment(assessment);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: const Text(
                        'Start',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
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

  Widget _buildInfoChip(String text, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  String _formatTime(int seconds) {
    if (seconds < 60) {
      return '${seconds}s';
    } else if (seconds < 3600) {
      return '${seconds ~/ 60}m';
    } else {
      return '${seconds ~/ 3600}h';
    }
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

  void _showAssessmentDetails(Map<String, dynamic> assessment) {
    final examProvider = Provider.of<ExamProvider>(context, listen: false);
    final isCompleted = examProvider.isQuizCompleted(assessment['id'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(assessment['name'] ?? 'Assessment Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isCompleted)
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, size: 16, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      'You have completed this assessment',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            Text(
              assessment['description'] ?? 'Test your knowledge and skills',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Type', assessment['type'] ?? 'quiz'),
            _buildDetailRow('Difficulty', assessment['difficulty'] ?? 'Beginner'),
            _buildDetailRow('Questions', '${assessment['questionIds']?.length ?? assessment['totalQuestions'] ?? 0}'),
            _buildDetailRow('Total Points', '${assessment['totalPoints'] ?? 100}'),
            _buildDetailRow('Time Limit', _formatTime(assessment['timeLimit'] ?? 0)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (!isCompleted)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _startAssessment(assessment);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _getSectionColor(assessment['type'] ?? 'quiz'),
              ),
              child: const Text('Start Assessment'),
            )
          else
            OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
                _viewResults(assessment);
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.green),
              ),
              child: const Text(
                'View Results',
                style: TextStyle(color: Colors.green),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(value),
        ],
      ),
    );
  }

  Color _getSectionColor(String type) {
    switch (type) {
      case 'quiz':
        return Colors.blue;
      case 'coding':
        return Colors.green;
      case 'exam':
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }

  void _startAssessment(Map<String, dynamic> assessment) {
    // Get the assessment ID
    final assessmentId = assessment['id'] ??
        assessment['quizId'] ??
        assessment['assessmentId'] ??
        'demo_${DateTime.now().millisecondsSinceEpoch}';

    // Navigate to TakeAssessmentScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TakeAssessmentScreen(
          quizId: assessmentId,
          quizName: assessment['name'] ?? 'Assessment',
          quizType: assessment['type'] ?? 'quiz',
          difficulty: assessment['difficulty'] ?? 'Beginner',
          totalDuration: assessment['timeLimit'] != null
              ? (assessment['timeLimit'] ~/ 60) // Convert seconds to minutes
              : null,
          totalQuestions: assessment['questionIds']?.length ??
              assessment['totalQuestions'] ?? 0,
          totalPoints: assessment['totalPoints'] ?? 100,
        ),
      ),
    ).then((_) {
      // Reload data when returning from assessment (user might have completed it)
      _loadData();
    });
  }

  void _viewResults(Map<String, dynamic> assessment) {
    final examProvider = Provider.of<ExamProvider>(context, listen: false);
    final result = examProvider.getResultByQuizId(assessment['id'] ?? '');

    if (result != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultDetailsScreen(result: result), // FIXED: Pass QuizResult object
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No results found for this assessment'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _viewProgressHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProgressUpdatesScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final examProvider = Provider.of<ExamProvider>(context);
    final completedCount = examProvider.getCompletedCount();
    final averageScore = examProvider.getAverageScore();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Challenges & Exams'),
        centerTitle: true,
        elevation: 2,
        backgroundColor: const Color(0xFFEA580C),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _viewProgressHistory,
            tooltip: 'View Progress History',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFEA580C)),
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Stats
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFEA580C), Color(0xFFF97316)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(_quizzes.length + _challenges.length + _exams.length, 'Total'),
                  _buildStatItem(completedCount, 'Completed'),
                  _buildStatItem(
                    averageScore.toInt(),
                    'Avg %',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Quizzes Section
            if (_quizzes.isNotEmpty) ...[
              _buildSectionHeader(
                'Quizzes',
                'Quick tests to check your knowledge',
                Colors.blue,
              ),
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _quizzes.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) => _buildAssessmentCard(_quizzes[index], Colors.blue),
              ),
              const SizedBox(height: 24),
            ],

            // Coding Challenges Section
            if (_challenges.isNotEmpty) ...[
              _buildSectionHeader(
                'Coding Challenges',
                'Solve real coding problems',
                Colors.green,
              ),
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _challenges.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) => _buildAssessmentCard(_challenges[index], Colors.green),
              ),
              const SizedBox(height: 24),
            ],

            // Mock Exams Section
            if (_exams.isNotEmpty) ...[
              _buildSectionHeader(
                'Mock Exams',
                'Full-length practice tests',
                Colors.purple,
              ),
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _exams.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) => _buildAssessmentCard(_exams[index], Colors.purple),
              ),
            ],

            // Empty State - Show demo quizzes if no data
            if (_quizzes.isEmpty && _challenges.isEmpty && _exams.isEmpty)
              _buildEmptyState(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(int value, String label) {
    return Column(
      children: [
        Text(
          '$value',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 50),
          Icon(
            Icons.quiz_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          const Text(
            'No assessments available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try demo quizzes below',
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),

          // Demo quizzes
          _buildDemoSection(),
        ],
      ),
    );
  }

  Widget _buildDemoSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Demo Quizzes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try these demo quizzes to test the feature',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),

            // Demo Quizzes List
            _buildDemoQuizCard(
              'Programming Basics Quiz',
              'Test your programming fundamentals knowledge',
              3,
              100,
              10,
              'Beginner',
              'demo_quiz_1',
              Colors.blue,
            ),

            const SizedBox(height: 12),

            _buildDemoQuizCard(
              'Dart Coding Challenge',
              'Practice your Dart programming skills',
              2,
              150,
              15,
              'Intermediate',
              'demo_quiz_2',
              Colors.green,
            ),

            const SizedBox(height: 12),

            _buildDemoQuizCard(
              'Flutter Mock Exam',
              'Full-length Flutter certification practice test',
              4,
              200,
              60,
              'Advanced',
              'demo_quiz_3',
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoQuizCard(
      String title,
      String description,
      int questions,
      int points,
      int duration,
      String difficulty,
      String quizId,
      Color color,
      ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: color.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildInfoChip('$questions Qs', Icons.question_answer_outlined),
                const SizedBox(width: 8),
                _buildInfoChip('$points pts', Icons.star_border_outlined),
                const SizedBox(width: 8),
                _buildInfoChip('${duration}m', Icons.timer_outlined),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getDifficultyColor(difficulty),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    difficulty,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _startAssessment({
                      'id': quizId,
                      'name': title,
                      'description': description,
                      'type': 'quiz',
                      'totalQuestions': questions,
                      'totalPoints': points,
                      'timeLimit': duration * 60, // Convert to seconds
                      'difficulty': difficulty,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    backgroundColor: color,
                  ),
                  child: const Text(
                    'Try Demo',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}