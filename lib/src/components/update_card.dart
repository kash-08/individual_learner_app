import 'package:flutter/material.dart';
import '../models/update_model.dart';

class UpdateCard extends StatelessWidget {
  final Update update;
  final VoidCallback? onTap;
  final VoidCallback? onMarkAsRead;

  const UpdateCard({
    super.key,
    required this.update,
    this.onTap,
    this.onMarkAsRead,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with type and new badge
              Row(
                children: [
                  _buildTypeChip(update.type),
                  const Spacer(),
                  if (update.isNew) _buildNewBadge(),
                  if (onMarkAsRead != null && update.isNew) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: onMarkAsRead,
                      icon: const Icon(Icons.check, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Mark as read',
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                update.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                update.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[700],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Metadata
              Row(
                children: [
                  if (update.category != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        update.category!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (update.readTime != null) ...[
                    Text(
                      '• ${update.readTime}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    _getTimeAgo(update.publishDate),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
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

  Widget _buildTypeChip(String type) {
    Color backgroundColor;
    Color textColor;
    String label;

    switch (type) {
      case 'course':
        backgroundColor = const Color(0xFF4361EE).withOpacity(0.1);
        textColor = const Color(0xFF4361EE);
        label = 'Course';
        break;
      case 'article':
        backgroundColor = const Color(0xFF7209B7).withOpacity(0.1);
        textColor = const Color(0xFF7209B7);
        label = 'Article';
        break;
      case 'news':
        backgroundColor = const Color(0xFFF72585).withOpacity(0.1);
        textColor = const Color(0xFFF72585);
        label = 'News';
        break;
      default:
        backgroundColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey;
        label = 'Update';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildNewBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF72585),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'NEW',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return '${(difference.inDays / 7).floor()}w ago';
  }
}