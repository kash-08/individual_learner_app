import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Make sure this import exists
import '../providers/course_provider.dart';
import '../models/course_model.dart';

class CourseCatalogScreen extends StatelessWidget {
  const CourseCatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Course Catalog'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF212529)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<CourseProvider>( // Use Consumer to access the provider
        builder: (context, courseProvider, child) {
          return courseProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: courseProvider.availableCourses.length,
            itemBuilder: (context, index) {
              final course = courseProvider.availableCourses[index];
              return _buildCourseCard(context, course, courseProvider);
            },
          );
        },
      ),
    );
  }

  Widget _buildCourseCard(BuildContext context, Course course, CourseProvider courseProvider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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
                      Text(
                        course.category,
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

            // Enroll Button
            ElevatedButton(
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Successfully enrolled in course!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back to home screen
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to enroll: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}