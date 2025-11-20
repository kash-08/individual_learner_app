import 'package:flutter/material.dart';
import '../models/session_model.dart';
import '../models/course_model.dart';

class ResumeActivityCard extends StatelessWidget {
  final UserSession session;
  final Course? course;
  final VoidCallback onResume;
  final VoidCallback onDismiss;

  const ResumeActivityCard({
    super.key,
    required this.session,
    required this.course,
    required this.onResume,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
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
                Row(
                  children: [
                    Icon(
                      _getActivityIcon(session.lastActivityType),
                      color: const Color(0xFF4361EE),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Continue Where You Left Off',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: onDismiss,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _getActivityTitle(session),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF212529),
              ),
            ),
            const SizedBox(height: 8),
            if (session.lastActivityType == 'course' && course != null)
              _buildCourseProgress(context),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  _getTimeAgo(session.lastActivityTime),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: onResume,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4361EE),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text(
                    'Resume',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseProgress(BuildContext context) {
    final progress = session.activityData['courseProgress'] ?? {};
    final progressPercentage = progress['progressPercentage'] ?? 0;
    final lessonsCompleted = progress['lessonsCompleted'] ?? 0;
    final totalLessons = progress['totalLessons'] ?? 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Lesson ${session.lastLessonIndex + 1} of $totalLessons',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            Text(
              '$progressPercentage% complete',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4361EE),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            Container(
              height: 6,
              width: MediaQuery.of(context).size.width * (progressPercentage / 100),
              decoration: BoxDecoration(
                color: const Color(0xFF4361EE),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ],
        ),
      ],
    );
  }

  IconData _getActivityIcon(String activityType) {
    switch (activityType) {
      case 'course':
        return Icons.school;
      case 'quiz':
        return Icons.quiz;
      case 'ai_assistant':
        return Icons.auto_awesome;
      default:
        return Icons.history;
    }
  }

  String _getActivityTitle(UserSession session) {
    switch (session.lastActivityType) {
      case 'course':
        final courseTitle = session.activityData['courseProgress']?['courseTitle'] ?? 'Course';
        return 'Continue $courseTitle';
      case 'quiz':
        return 'Continue Quiz';
      case 'ai_assistant':
        final lastQuery = session.activityData['lastQuery'] ?? 'AI Assistant';
        return 'Continue AI Chat: ${lastQuery.length > 30 ? '${lastQuery.substring(0, 30)}...' : lastQuery}';
      default:
        return 'Continue Activity';
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }
}