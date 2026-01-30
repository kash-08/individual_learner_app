import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/course_provider.dart';
import '../models/course_model.dart';

class CourseCatalogScreen extends StatefulWidget {
  const CourseCatalogScreen({super.key});

  @override
  State<CourseCatalogScreen> createState() => _CourseCatalogScreenState();
}

class _CourseCatalogScreenState extends State<CourseCatalogScreen> {
  @override
  void initState() {
    super.initState();
    // Load courses when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final courseProvider = Provider.of<CourseProvider>(context, listen: false);
      if (courseProvider.availableCourses.isEmpty) {
        courseProvider.loadCourses();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(context),
      body: Consumer<CourseProvider>(
        builder: (context, courseProvider, child) {
          if (courseProvider.isLoading && courseProvider.availableCourses.isEmpty) {
            return _buildLoadingState();
          }

          if (courseProvider.error != null && courseProvider.availableCourses.isEmpty) {
            return _buildErrorState(context, courseProvider);
          }

          if (courseProvider.availableCourses.isEmpty) {
            return _buildEmptyState(context, courseProvider);
          }

          return _buildCourseList(context, courseProvider);
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Loading Courses...',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            'Please wait while we fetch available courses',
            style: TextStyle(color: Color(0xFF6C757D)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, CourseProvider courseProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Failed to Load Courses',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              courseProvider.error ?? 'Unknown error occurred',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF6C757D),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    courseProvider.loadCourses();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4361EE),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Try Again'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    courseProvider.loadMockCourses(); // Fixed method name
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Use Demo Data'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, CourseProvider courseProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'No Courses Found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF212529),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'It looks like there are no courses available at the moment.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6C757D),
              ),
            ),
            const SizedBox(height: 24),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {
                    courseProvider.loadCourses();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4361EE),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(200, 48),
                  ),
                  child: const Text('Refresh Courses'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () {
                    courseProvider.loadMockCourses();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF4361EE),
                    side: const BorderSide(color: Color(0xFF4361EE)),
                    minimumSize: const Size(200, 48),
                  ),
                  child: const Text('Load Sample Courses'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Go Back to Home'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseList(BuildContext context, CourseProvider courseProvider) {
    return RefreshIndicator(
      onRefresh: () async {
        await courseProvider.loadCourses();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: courseProvider.availableCourses.length,
        itemBuilder: (context, index) {
          final course = courseProvider.availableCourses[index];
          return _buildCourseCard(context, course, courseProvider);
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
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
          const Text(
            'Course Catalog',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Consumer<CourseProvider>(
            builder: (context, courseProvider, child) {
              return Text(
                '${courseProvider.availableCourses.length} courses available',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              );
            },
          ),
        ],
      ),
      actions: [
        Consumer<CourseProvider>(
          builder: (context, courseProvider, child) {
            return IconButton(
              icon: Icon(
                courseProvider.isLoading ? Icons.hourglass_top : Icons.refresh,
                color: Colors.white,
              ),
              onPressed: courseProvider.isLoading
                  ? null
                  : () {
                courseProvider.loadCourses();
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildCourseCard(BuildContext context, Course course, CourseProvider courseProvider) {
    final bool isEnrolled = courseProvider.enrolledCourses.any((c) => c.id == course.id);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          _showCourseDetails(context, course, courseProvider);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course Image
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xFF4361EE).withOpacity(0.1),
                  image: course.imageUrl.isNotEmpty
                      ? DecorationImage(
                    image: NetworkImage(course.imageUrl),
                    fit: BoxFit.cover,
                  )
                      : null,
                ),
                child: course.imageUrl.isEmpty
                    ? const Icon(
                  Icons.school,
                  color: Color(0xFF4361EE),
                  size: 24,
                )
                    : null,
              ),
              const SizedBox(width: 12),

              // Course Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF212529),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'By ${course.instructor}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF4361EE),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      course.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6C757D),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getDifficultyColor(course.difficulty),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            course.difficulty,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4361EE).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            course.category,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF4361EE),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${course.totalLessons} lessons',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF6C757D),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Enroll Button
              const SizedBox(width: 12),
              isEnrolled
                  ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green[700], size: 16),
                    const SizedBox(width: 4),
                    const Text(
                      'Enrolled',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
                  : ElevatedButton(
                onPressed: () {
                  _enrollInCourse(context, course.id, courseProvider);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4361EE),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text(
                  'Enroll',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCourseDetails(BuildContext context, Course course, CourseProvider courseProvider) {
    final bool isEnrolled = courseProvider.enrolledCourses.any((c) => c.id == course.id);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(course.title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (course.imageUrl.isNotEmpty)
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: const Color(0xFF4361EE).withOpacity(0.1),
                    image: DecorationImage(
                      image: NetworkImage(course.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              Text(
                course.description,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Color(0xFF6C757D)),
                  const SizedBox(width: 4),
                  Text(
                    course.instructor,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6C757D),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.category, size: 16, color: Color(0xFF6C757D)),
                  const SizedBox(width: 4),
                  Text(
                    course.category,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6C757D),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.school, size: 16, color: Color(0xFF6C757D)),
                  const SizedBox(width: 4),
                  Text(
                    '${course.totalLessons} lessons',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6C757D),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.speed, size: 16, color: Color(0xFF6C757D)),
                  const SizedBox(width: 4),
                  Text(
                    course.difficulty,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6C757D),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Color(0xFF6C757D)),
                  const SizedBox(width: 4),
                  Text(
                    '${course.estimatedHours} hours',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6C757D),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (!isEnrolled)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _enrollInCourse(context, course.id, courseProvider);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4361EE),
                foregroundColor: Colors.white,
              ),
              child: const Text('Enroll Now'),
            ),
          if (isEnrolled)
            OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
                // Navigate to course learning screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Opening course...'),
                    backgroundColor: Colors.blue,
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF4361EE),
                side: const BorderSide(color: Color(0xFF4361EE)),
              ),
              child: const Text('Continue Learning'),
            ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return const Color(0xFF4CAF50);
      case 'intermediate':
        return const Color(0xFFFF9800);
      case 'advanced':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF4361EE);
    }
  }

  void _enrollInCourse(BuildContext context, String courseId, CourseProvider courseProvider) async {
    try {
      await courseProvider.enrollInCourse(courseId);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully enrolled in course!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to enroll: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}

extension on CourseProvider {
  void loadMockCourses() {}
}