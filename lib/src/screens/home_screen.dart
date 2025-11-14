import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../models/course_model.dart';
import '../providers/course_provider.dart';
import '../components/course_progress_card.dart';
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
              _buildCurrentCourseSection(),
              const SizedBox(height: 24),
              _buildStatsSection(),
              const SizedBox(height: 24),
              _buildAIToolsSection(),
              const SizedBox(height: 24),
              _buildRegisteredCoursesSection(context), // NEW SECTION
              const SizedBox(height: 24),
              _buildQuickActionsSection(),
            ],
          ),
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

  Widget _buildCurrentCourseSection() {
    return Consumer<CourseProvider>(
      builder: (context, courseProvider, child) {
        // Get the first enrolled course with progress, or show placeholder
        final enrolledCourses = courseProvider.enrolledCourses;
        final currentCourse = enrolledCourses.isNotEmpty
            ? enrolledCourses.first
            : Course(
          id: 'placeholder',
          title: 'No Active Course',
          description: 'Enroll in a course to start learning',
          currentLesson: 0,
          totalLessons: 1,
          progress: 0.0,
          category: 'General',
          instructor: '',
          imageUrl: '',
          isEnrolled: false,
          enrolledDate: DateTime.now(),
          difficulty: 'Beginner',
        );

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
                      'Continue Learning',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (enrolledCourses.isNotEmpty)
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
                          'Lesson ${currentCourse.currentLesson} of ${currentCourse.totalLessons}',
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
                  currentCourse.title,
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
                          width: MediaQuery.of(context).size.width * currentCourse.progress,
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
                          '${(currentCourse.progress * 100).toInt()}% complete',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (enrolledCourses.isNotEmpty)
                          Text(
                            '${currentCourse.totalLessons - currentCourse.currentLesson} lessons left',
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
                    onPressed: enrolledCourses.isNotEmpty ? () {
                      // Navigate to course screen
                    } : () {
                      // Navigate to course catalog
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CourseCatalogScreen(),
                        ),
                      );
                    },
                    child: Text(
                      enrolledCourses.isNotEmpty ? 'Continue Learning' : 'Browse Courses',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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

  // NEW: Registered Courses Section
  Widget _buildRegisteredCoursesSection(BuildContext context) {
    return Consumer<CourseProvider>(
      builder: (context, courseProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Registered Courses',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CourseCatalogScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Browse All',
                    style: TextStyle(
                      color: Color(0xFF4361EE),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (courseProvider.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (courseProvider.enrolledCourses.isEmpty)
              _buildEmptyCoursesState()
            else
              ...courseProvider.enrolledCourses
                  .map((course) => Column(
                children: [
                  CourseProgressCard(
                    course: course,
                    onTap: () {
                      _showCourseDetails(context, course);
                    },
                    onUnenroll: () {
                      _showUnenrollDialog(context, course);
                    },
                  ),
                  const SizedBox(height: 12),
                ],
              ))
                  .toList(),
          ],
        );
      },
    );
  }

  Widget _buildEmptyCoursesState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: Column(
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CourseCatalogScreen(),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF4361EE),
                  side: const BorderSide(color: Color(0xFF4361EE)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Browse Courses'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to progress/analytics
                },
                child: const Text('View Progress'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}