import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:individual_learner_app/src/models/assesment_model.dart';
import 'package:individual_learner_app/src/services/assesment_service.dart';
import 'assesment_list_tab.dart';
import 'results_tab.dart';

class ChallengesExamsScreen extends StatefulWidget {
  const ChallengesExamsScreen({Key? key}) : super(key: key);

  @override
  State<ChallengesExamsScreen> createState() => _ChallengesExamsScreenState();
}

class _ChallengesExamsScreenState extends State<ChallengesExamsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AssessmentService _assessmentService = AssessmentService();
  Map<String, dynamic> _statistics = {};
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (userId.isNotEmpty) {
      Map<String, dynamic> stats =
      await _assessmentService.getUserStatistics(userId);
      setState(() {
        _statistics = stats;
        _isLoadingStats = false;
      });
    } else {
      setState(() {
        _isLoadingStats = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Challenges & Exams',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'Test your knowledge and skills',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue[700],
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadStatistics,
          ),
        ],
      ),
      body: Column(
        children: [
          // Statistics Card
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue[700]!, Colors.blue[500]!],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _isLoadingStats
                      ? Center(child: CircularProgressIndicator())
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        Icons.assignment_turned_in,
                        _statistics['totalExams']?.toString() ?? '0',
                        'Exams Taken',
                        Colors.blue,
                      ),
                      _buildStatItem(
                        Icons.assessment,
                        '${_statistics['avgScore']?.toStringAsFixed(1) ?? '0.0'}%',
                        'Avg Score',
                        Colors.orange,
                      ),
                      _buildStatItem(
                        Icons.code,
                        _statistics['totalChallenges']?.toString() ?? '0',
                        'Challenges',
                        Colors.purple,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Pass/Fail Badge
          if (!_isLoadingStats && _statistics['totalExams'] != null && _statistics['totalExams'] > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.emoji_events, color: Colors.amber, size: 20),
                  SizedBox(width: 8),
                  Text(
                    '${_statistics['passedExams']} Passed • ${_statistics['failedExams']} Failed',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),

          // Tabs
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.blue[700],
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue[700],
              labelStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              tabs: [
                Tab(text: 'Quizzes'),
                Tab(text: 'Coding'),
                Tab(text: 'Mock Exam'),
                Tab(text: 'Results'),
              ],
            ),
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                AssessmentListTab(type: AssessmentType.quiz),
                AssessmentListTab(type: AssessmentType.challenge),
                AssessmentListTab(type: AssessmentType.mockExam),
                ResultsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
