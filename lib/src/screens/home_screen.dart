// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:provider/provider.dart';
import '../models/timetable_model.dart';
import '../models/update_model.dart';
import '../models/user_model.dart';
import '../models/course_model.dart';
import '../models/session_model.dart';
import '../providers/auth_provider.dart';
import '../providers/course_provider.dart';
import '../providers/updates_provider.dart';
import '../providers/timetable_provider.dart';
import '../providers/short_answer_provider.dart';
import '../providers/profile_provider.dart';
import '../components/course_progress_card.dart';
import '../components/resume_activity_card.dart';
import '../components/update_card.dart';
import 'course_catalog_screen.dart';
import 'progress_updates_screen.dart';
import 'achievements_screen.dart';
import 'challenges_exams_screen.dart';
import 'ai_assistant_screen.dart';
import 'smart_timetable_screen.dart';
import 'ai_short_answer_screen.dart';
import 'profile_screen.dart' hide UserModel;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final UserModel currentUser = UserModel(
    id: '1',
    name: 'Alex',
    email: 'alex@example.com',
    profileImageUrl: null,
    xpPoints: 1247,
    dayStreak: 7,
    studyTimeThisWeek: 2.5,
    enrolledCourses: [],
    completedQuizzes: [],
    createdAt: DateTime.now(),
    lastUpdated: DateTime.now(),
  );

  bool _showResumeCard = true;
  TimetableStats? _timetableStats; // Store timetable stats
  bool _loadingStats = false; // Loading state for stats

  @override
  void initState() {
    super.initState();
    _loadCourses();
    _loadWeeklyUpdates();
    _loadTimetableData();
    _loadShortAnswerData();
    _loadProfileData();
    _loadTimetableStats(); // Load stats on init
  }

  Future<void> _loadCourses() async {
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    await courseProvider.loadCourses();
  }

  Future<void> _loadWeeklyUpdates() async {
    final updatesProvider = Provider.of<UpdatesProvider>(context, listen: false);
    await updatesProvider.loadUpdates();
  }

  Future<void> _loadTimetableData() async {
    final timetableProvider = Provider.of<TimetableProvider>(context, listen: false);
    await timetableProvider.loadTimetableSlots();
  }

  // NEW: Load timetable statistics
  Future<void> _loadTimetableStats() async {
    try {
      setState(() => _loadingStats = true);
      final timetableProvider = Provider.of<TimetableProvider>(context, listen: false);
      final stats = await timetableProvider.getStats(daysBack: 30);
      setState(() {
        _timetableStats = stats;
        _loadingStats = false;
      });
    } catch (e) {
      print('Error loading timetable stats: $e');
      setState(() => _loadingStats = false);
    }
  }

  Future<void> _loadShortAnswerData() async {
    final shortAnswerProvider = Provider.of<ShortAnswerProvider>(context, listen: false);
    print('AI Short Answer data initialized');
  }

  Future<void> _loadProfileData() async {
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    await profileProvider.loadUserProfile();
  }

  void _onResumeActivity() {
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    final resumeProgress = courseProvider.getResumeProgress();

    if (resumeProgress != null) {
      final course = resumeProgress['course'] as Course;
      final lessonIndex = resumeProgress['lessonIndex'] as int;
      _navigateToCourse(course.id, lessonIndex);
    }
  }

  void _onDismissResumeCard() {
    setState(() {
      _showResumeCard = false;
    });

    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    courseProvider.clearLastSession();
  }

  void _navigateToCourse(String courseId, int lessonIndex) {
    print('Navigate to course: $courseId, lesson: $lessonIndex');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resume Course'),
        content: Text('Would you like to continue from lesson ${lessonIndex + 1}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Navigating to lesson ${lessonIndex + 1}'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Resume'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.white,
    ));
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(),
              const SizedBox(height: 24),

              _buildResumeActivitySection(),

              _buildStatsSection(),
              const SizedBox(height: 24),

              _buildTodaysScheduleSection(),
              const SizedBox(height: 24),

              _buildAIToolsSection(),
              const SizedBox(height: 24),

              _buildBrowseCoursesSection(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF4361EE),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Learning Dashboard',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Track your progress and continue learning',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
      actions: [
        Consumer<ProfileProvider>(
          builder: (context, profileProvider, child) {
            final profile = profileProvider.userProfile;
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                icon: CircleAvatar(
                  radius: 16,
                  backgroundImage: profile?.profileImageUrl != null
                      ? NetworkImage(profile!.profileImageUrl!)
                      : null,
                  child: profile?.profileImageUrl == null
                      ? const Icon(Icons.person, size: 16, color: Colors.white)
                      : null,
                  backgroundColor: profile?.profileImageUrl == null
                      ? Colors.white.withOpacity(0.3)
                      : null,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                },
                tooltip: 'Profile & Analytics',
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildResumeActivitySection() {
    return Consumer<CourseProvider>(
      builder: (context, courseProvider, child) {
        final resumeProgress = courseProvider.getResumeProgress();

        if (_showResumeCard && resumeProgress != null) {
          final course = resumeProgress['course'] as Course;
          final session = UserSession(
            userId: currentUser.id,
            lastActivityTime: DateTime.now().subtract(const Duration(minutes: 30)),
            lastActivityType: 'course',
            lastActivityId: course.id,
            lastLessonIndex: resumeProgress['lessonIndex'] as int,
            activityData: resumeProgress['progressData'] as Map<String, dynamic>,
          );

          return Column(
            children: [
              ResumeActivityCard(
                session: session,
                course: course,
                onResume: _onResumeActivity,
                onDismiss: _onDismissResumeCard,
              ),
              const SizedBox(height: 24),
            ],
          );
        }

        return _buildStartLearningPrompt(courseProvider);
      },
    );
  }

  Widget _buildStartLearningPrompt(CourseProvider courseProvider) {
    final enrolledCourses = courseProvider.enrolledCourses;

    if (enrolledCourses.isEmpty) {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Start Your Learning Journey',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Enroll in your first course to begin learning and track your progress',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CourseCatalogScreen(),
                      ),
                    );
                  },
                  child: const Text('Browse Courses'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final firstCourse = enrolledCourses.first;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ready to Learn?',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4361EE).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${(firstCourse.progress * 100).toInt()}% complete',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF4361EE),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              firstCourse.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE9ECEF),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Container(
                      height: 8,
                      width: MediaQuery.of(context).size.width * firstCourse.progress,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4361EE),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Lesson ${firstCourse.currentLesson} of ${firstCourse.totalLessons}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      '${firstCourse.totalLessons - firstCourse.currentLesson} lessons left',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  courseProvider.updateCourseProgressWithSession(
                    firstCourse.id,
                    firstCourse.currentLesson,
                  );
                },
                child: const Text('Start Learning'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        String userName = 'Learner';
        final firebaseUser = FirebaseAuth.instance.currentUser;

        if (firebaseUser != null && firebaseUser.displayName != null && firebaseUser.displayName!.isNotEmpty) {
          userName = firebaseUser.displayName!;
        } else if (authProvider.user != null && authProvider.user!.displayName != null) {
          userName = authProvider.user!.displayName!;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back, $userName!',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ready to continue your learning journey?',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatsSection() {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        final analytics = profileProvider.learningAnalytics;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4361EE), Color(0xFF3A0CA3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                analytics?.totalXpEarned.toString() ?? currentUser.xpPoints.toString(),
                'XP Points',
                Icons.star,
              ),
              _buildStatItem(
                currentUser.dayStreak.toString(),
                'Day Streak',
                Icons.local_fire_department,
              ),
              _buildStatItem(
                analytics?.totalStudyHours.toString() ?? currentUser.studyTimeThisWeek.toStringAsFixed(1) + 'h',
                'Study Hours',
                Icons.timer,
              ),
              _buildStatItem(
                analytics?.totalLessonsCompleted.toString() ?? '0',
                'Lessons',
                Icons.check_circle,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
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

  // Today's Study Schedule Section - UPDATED
  Widget _buildTodaysScheduleSection() {
    return Consumer<TimetableProvider>(
      builder: (context, timetableProvider, child) {
        final todaySlots = timetableProvider.getTodaySlots();
        final upcomingSlots = timetableProvider.getUpcomingSlots().take(2).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Today\'s Study Schedule',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                if (todaySlots.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4361EE).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${todaySlots.where((slot) => slot.isCompleted).length}/${todaySlots.length} completed',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF4361EE),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            if (todaySlots.isEmpty)
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            color: Colors.blue[400],
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'No study slots scheduled for today',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Plan your study sessions for better results',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SmartTimetableScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4361EE),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Plan Now'),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Column(
                children: [
                  ...todaySlots.map((slot) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Color(int.parse(slot.colorHex.substring(1, 7),
                                  radix: 16) + 0xFF000000).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              slot.isCompleted ? Icons.check_circle : Icons.schedule,
                              color: Color(int.parse(slot.colorHex.substring(1, 7),
                                  radix: 16) + 0xFF000000),
                            ),
                          ),
                          title: Text(
                            slot.title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              decoration: slot.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          subtitle: Text(
                            '${slot.startTime.format(context)} - ${slot.endTime.format(context)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  slot.isCompleted
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_unchecked,
                                  color: slot.isCompleted
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                                onPressed: () {
                                  timetableProvider.toggleSlotCompletion(
                                    slot.id,
                                    !slot.isCompleted,
                                  );
                                },
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SmartTimetableScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }).toList(),

                  if (upcomingSlots.isNotEmpty)
                    Column(
                      children: [
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Upcoming Sessions',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SmartTimetableScreen(),
                                  ),
                                );
                              },
                              child: const Text('View All'),
                            ),
                          ],
                        ),
                        ...upcomingSlots.map((slot) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.schedule,
                                  color: Colors.grey[600],
                                  size: 18,
                                ),
                              ),
                              title: Text(
                                slot.title,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Text(
                                '${_formatDate(slot.date)} • ${slot.startTime.format(context)}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                ],
              ),

            const SizedBox(height: 12),

            // Study Statistics - UPDATED
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Study Statistics',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (_loadingStats)
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.blue[400],
                            ),
                          )
                        else
                          IconButton(
                            icon: const Icon(Icons.refresh, size: 16),
                            onPressed: _loadTimetableStats,
                            tooltip: 'Refresh statistics',
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (_loadingStats)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (_timetableStats == null)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Text(
                            'No statistics available',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStudyStatItem(
                            '${_timetableStats!.completedSlots}',
                            'Completed',
                            Icons.check_circle,
                            Colors.green,
                          ),
                          _buildStudyStatItem(
                            '${_timetableStats!.upcomingSlots}',
                            'Upcoming',
                            Icons.upcoming,
                            Colors.blue,
                          ),
                          _buildStudyStatItem(
                            '${_timetableStats!.totalStudyHours.toStringAsFixed(1)}h',
                            'Total Time',
                            Icons.timer,
                            Colors.orange,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStudyStatItem(String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dayAfterTomorrow = today.add(const Duration(days: 2));

    if (date.year == today.year &&
        date.month == today.month &&
        date.day == today.day) {
      return 'Today';
    } else if (date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day) {
      return 'Tomorrow';
    } else if (date.year == dayAfterTomorrow.year &&
        date.month == dayAfterTomorrow.month &&
        date.day == dayAfterTomorrow.day) {
      return 'Day after';
    } else {
      return '${date.day}/${date.month}';
    }
  }

  // AI Tools Section
  Widget _buildAIToolsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI Learning Tools',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),

        _buildAIToolCard(
          icon: Icons.question_answer,
          title: 'AI Short Answers',
          description: 'Quick definitions & summaries',
          color: Colors.teal,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AIShortAnswerScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 8),

        _buildAIToolCard(
          icon: Icons.schedule,
          title: 'Smart Timetable',
          description: 'AI-generated personalized study schedule',
          color: Colors.blue,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SmartTimetableScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        _buildAIToolCard(
          icon: Icons.smart_toy,
          title: 'AI Assistant',
          description: '24/7 AI-powered learning companion',
          color: Colors.purple,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AIAssistantScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAIToolCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.05),
                color.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.black38,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrowseCoursesSection() {
    return Consumer<CourseProvider>(
      builder: (context, courseProvider, child) {
        final enrolledCoursesCount = courseProvider.enrolledCourses.length;

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Your Learning',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4361EE).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '$enrolledCoursesCount ${enrolledCoursesCount == 1
                            ? 'Course'
                            : 'Courses'}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF4361EE),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  enrolledCoursesCount == 0
                      ? 'Start your learning journey by exploring our course catalog'
                      : 'Continue exploring new topics and expand your knowledge',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CourseCatalogScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4361EE),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Browse All Courses',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (enrolledCoursesCount > 0) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        _showEnrolledCourses(context);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF4361EE),
                        side: const BorderSide(color: Color(0xFF4361EE)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('View My Courses'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEnrolledCourses(BuildContext context) {
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    final enrolledCourses = courseProvider.enrolledCourses;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Courses',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: enrolledCourses.isEmpty
                  ? _buildEmptyCoursesState()
                  : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: enrolledCourses.length,
                itemBuilder: (context, index) {
                  final course = enrolledCourses[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: CourseProgressCard(
                      course: course,
                      onTap: () {
                        courseProvider.updateCourseProgressWithSession(
                          course.id,
                          course.currentLesson,
                        );
                        _showCourseDetails(context, course);
                        Navigator.pop(context);
                      },
                      onUnenroll: () {
                        _showUnenrollDialog(context, course);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCoursesState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'No Courses Enrolled',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF212529),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Browse our catalog and enroll in your first course to start learning!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CourseCatalogScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4361EE),
                foregroundColor: Colors.white,
              ),
              child: const Text('Browse Courses'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCourseDetails(BuildContext context, Course course) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(course.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Instructor: ${course.instructor}'),
            Text('Category: ${course.category}'),
            Text('Difficulty: ${course.difficulty}'),
            Text('Progress: ${(course.progress * 100).toInt()}%'),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: course.progress,
              backgroundColor: const Color(0xFFE9ECEF),
              color: const Color(0xFF4361EE),
            ),
            Consumer<CourseProvider>(
              builder: (context, courseProvider, child) {
                if (courseProvider.hasRecentProgress(course.id)) {
                  return Column(
                    children: [
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.history, color: Colors.green[700], size: 16),
                            const SizedBox(width: 8),
                            Text(
                              'Recent progress available',
                              style: TextStyle(
                                color: Colors.green[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showUnenrollDialog(BuildContext context, Course course) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unenroll from Course'),
        content: Text('Are you sure you want to unenroll from "${course.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await Provider.of<CourseProvider>(context, listen: false)
                    .unenrollFromCourse(course.id);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Successfully unenrolled from course'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to unenroll: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Unenroll'),
          ),
        ],
      ),
    );
  }
}