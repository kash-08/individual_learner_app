import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/course_provider.dart';
import '../providers/updates_provider.dart';
import '../components/course_progress_card.dart';
import '../components/update_card.dart';
import '../models/course_model.dart';
import '../models/update_model.dart';

class ProgressUpdatesScreen extends StatefulWidget {
  const ProgressUpdatesScreen({super.key});

  @override
  State<ProgressUpdatesScreen> createState() => _ProgressUpdatesScreenState();
}

class _ProgressUpdatesScreenState extends State<ProgressUpdatesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CourseProvider>(context, listen: false).loadCourses();
      Provider.of<UpdatesProvider>(context, listen: false).loadUpdates();
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
      appBar: _buildAppBar(), // Updated app bar
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProgressTab(),
          _buildUpdatesTab(),
        ],
      ),
    );
  }

  // NEW: App Bar with proper color contrast matching home screen
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF4361EE), // Blue background
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Progress & Updates',
            style: TextStyle(
              color: Colors.white, // White text for contrast
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Track your learning journey',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9), // Slightly transparent white
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: Colors.white, // White indicator to match text
        indicatorWeight: 3,
        labelColor: Colors.white, // White text for selected tab
        unselectedLabelColor: Colors.white.withOpacity(0.7), // Slightly transparent white for unselected
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 14,
        ),
        tabs: const [
          Tab(text: 'My Progress'),
          Tab(text: 'Weekly Updates'),
        ],
      ),
      // Optional: Add actions if needed
      // actions: [
      //   IconButton(
      //     icon: const Icon(Icons.refresh, color: Colors.white),
      //     onPressed: () {
      //       // Refresh both tabs
      //       Provider.of<CourseProvider>(context, listen: false).loadCourses();
      //       Provider.of<UpdatesProvider>(context, listen: false).refreshUpdates();
      //     },
      //   ),
      // ],
    );
  }

  Widget _buildProgressTab() {
    return Consumer<CourseProvider>(
      builder: (context, courseProvider, child) {
        final enrolledCourses = courseProvider.enrolledCourses;

        if (courseProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (enrolledCourses.isEmpty) {
          return Center(
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
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Enroll in courses to track your progress',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to course catalog
                    Navigator.pop(context); // Go back to home, then to catalog
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

        return RefreshIndicator(
          onRefresh: () async {
            await courseProvider.loadCourses();
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: enrolledCourses.length,
            itemBuilder: (context, index) {
              final course = enrolledCourses[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: CourseProgressCard(
                  course: course,
                  onTap: () {
                    _showCourseProgressDetails(context, course);
                  },
                  onUnenroll: () {
                    _showUnenrollDialog(context, course);
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildUpdatesTab() {
    return Consumer<UpdatesProvider>(
      builder: (context, updatesProvider, child) {
        final updates = updatesProvider.updates;

        if (updatesProvider.isLoading && !updatesProvider.hasLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        if (updatesProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Failed to load updates',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(updatesProvider.error!),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    updatesProvider.refreshUpdates();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4361EE),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Try Again'),
                ),
              ],
            ),
          );
        }

        if (updates.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.update,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                const Text(
                  'No Updates Available',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Check back later for new content',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    updatesProvider.refreshUpdates();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4361EE),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Refresh'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await updatesProvider.refreshUpdates();
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: updates.length,
            itemBuilder: (context, index) {
              final update = updates[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: UpdateCard(
                  update: update,
                  onTap: () {
                    updatesProvider.markAsRead(update.id);
                    _handleUpdateTap(context, update);
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showCourseProgressDetails(BuildContext context, Course course) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          course.title,
          style: const TextStyle(
            color: Color(0xFF4361EE),
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Instructor: ${course.instructor}'),
            Text('Category: ${course.category}'),
            Text('Difficulty: ${course.difficulty}'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progress: ${(course.progress * 100).toInt()}%',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4361EE).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${course.totalLessons - course.currentLesson} lessons left',
                    style: const TextStyle(
                      color: Color(0xFF4361EE),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: course.progress,
              backgroundColor: const Color(0xFFE9ECEF),
              color: const Color(0xFF4361EE),
            ),
            const SizedBox(height: 8),
            Text('Lesson ${course.currentLesson} of ${course.totalLessons}'),
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Continuing ${course.title}'),
                  backgroundColor: const Color(0xFF4361EE),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4361EE),
              foregroundColor: Colors.white,
            ),
            child: const Text('Continue Learning'),
          ),
        ],
      ),
    );
  }

  void _showUnenrollDialog(BuildContext context, Course course) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Unenroll from Course',
          style: TextStyle(color: Colors.red),
        ),
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

  void _handleUpdateTap(BuildContext context, Update update) {
    switch (update.type) {
      case 'course':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening course: ${update.title}'),
            backgroundColor: const Color(0xFF4361EE),
          ),
        );
        break;
      case 'article':
      case 'news':
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              update.title,
              style: const TextStyle(
                color: Color(0xFF4361EE),
                fontWeight: FontWeight.w600,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (update.imageUrl != null)
                    Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(update.imageUrl!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    update.description,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  if (update.author != null) ...[
                    Text(
                      'By ${update.author}',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (update.readTime != null) ...[
                    Text(
                      'Read time: ${update.readTime}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    'Published: ${_formatDate(update.publishDate)}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Mark as read or perform action
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4361EE),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Mark as Read'),
              ),
            ],
          ),
        );
        break;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}