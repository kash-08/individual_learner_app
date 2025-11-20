import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../models/course_model.dart';
import '../models/session_model.dart';
import '../providers/course_provider.dart';
import '../components/course_progress_card.dart';
import '../components/resume_activity_card.dart';
import 'course_catalog_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Mock data - replace with actual data from providers
  final User currentUser = User(
    id: '1',
    name: 'Alex',
    email: 'alex@example.com',
    xpPoints: 1247,
    dayStreak: 7,
    studyTimeThisWeek: 2.5,
  );

  // Resume feature variables
  bool _showResumeCard = true;

  @override
  void initState() {
    super.initState();
    // Load courses when screen initializes
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    await courseProvider.loadCourses();
  }

  // Resume activity methods
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

    // Also clear from provider
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    courseProvider.clearLastSession();
  }

  void _navigateToCourse(String courseId, int lessonIndex) {
    // Navigate to course screen at specific lesson
    // You'll implement this based on your navigation structure
    print('Navigate to course: $courseId, lesson: $lessonIndex');

    // Show a dialog for now (replace with actual navigation)
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
              // TODO: Implement actual course navigation
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(),
              const SizedBox(height: 24),

              // Resume Activity Card - Now the main learning section
              _buildResumeActivitySection(),

              _buildStatsSection(),
              const SizedBox(height: 24),
              _buildAIToolsSection(),
              const SizedBox(height: 24),
              _buildBrowseCoursesSection(),
              const SizedBox(height: 24),
              _buildQuickActionsSection(),
            ],
          ),
        ),
      ),
    );
  }

  // Resume Activity Section - Now serves as the main learning section
  Widget _buildResumeActivitySection() {
    return Consumer<CourseProvider>(
      builder: (context, courseProvider, child) {
        final resumeProgress = courseProvider.getResumeProgress();

        // Show resume card if there's a valid session and not dismissed
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

        // If no resume activity, show a prompt to start learning
        return _buildStartLearningPrompt(courseProvider);
      },
    );
  }

  // Prompt to start learning when no resume activity is available
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

    // If there are enrolled courses but no recent activity
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
            // Progress bar
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
                  // Save session before navigating
                  courseProvider.updateCourseProgressWithSession(
                    firstCourse.id,
                    firstCourse.currentLesson,
                  );
                  // Navigate to course screen
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back, ${currentUser.name}!',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Ready to continue your learning journey?',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
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
          _buildStatItem('${currentUser.xpPoints}', 'XP Points'),
          _buildStatItem('${currentUser.dayStreak}', 'Day Streak'),
          _buildStatItem('${currentUser.studyTimeThisWeek}h', 'This Week'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
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
          title: 'Smart Timetable',
          description: 'AI-optimized study schedule',
        ),
        const SizedBox(height: 8),
        _buildAIToolCard(
          title: 'AI Assistant',
          description: 'Get instant help and explanations',
        ),
      ],
    );
  }

  Widget _buildAIToolCard({required String title, required String description}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF4361EE).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Color(0xFF4361EE),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF6C757D),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  // Browse Courses Section - Replaced Registered Courses
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
                        '$enrolledCoursesCount ${enrolledCoursesCount == 1 ? 'Course' : 'Courses'}',
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
                        // Navigate to user's enrolled courses screen
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
              // Navigate to course player
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

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  // Navigate to progress/analytics
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF4361EE),
                  side: const BorderSide(color: Color(0xFF4361EE)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('View Progress'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to achievements
                },
                child: const Text('Achievements'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}