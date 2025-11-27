import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/update_model.dart';
import '../providers/updates_provider.dart';
import '../components/update_card.dart';

class WeeklyUpdatesScreen extends StatefulWidget {
  const WeeklyUpdatesScreen({super.key});

  @override
  State<WeeklyUpdatesScreen> createState() => _WeeklyUpdatesScreenState();
}

class _WeeklyUpdatesScreenState extends State<WeeklyUpdatesScreen> {
  @override
  void initState() {
    super.initState();
    // Load updates when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UpdatesProvider>(context, listen: false).loadUpdates();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Updates'),
        actions: [
          IconButton(
            onPressed: () {
              Provider.of<UpdatesProvider>(context, listen: false).refreshUpdates();
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Consumer<UpdatesProvider>(
        builder: (context, updatesProvider, child) {
          if (updatesProvider.isLoading && !updatesProvider.hasLoaded) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (updatesProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load updates',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    updatesProvider.error!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      updatesProvider.refreshUpdates();
                    },
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          final updates = updatesProvider.personalizedUpdates;

          if (updates.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.update,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No updates available',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Check back later for new courses, articles, and news',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
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
                      _handleUpdateTap(context, update);
                    },
                    onMarkAsRead: () {
                      updatesProvider.markAsRead(update.id);
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _handleUpdateTap(BuildContext context, Update update) {
    // Mark as read when tapped
    Provider.of<UpdatesProvider>(context, listen: false).markAsRead(update.id);

    // Handle different types of updates
    switch (update.type) {
      case 'course':
        _handleCourseUpdate(context, update);
        break;
      case 'article':
        _handleArticleUpdate(context, update);
        break;
      case 'news':
        _handleNewsUpdate(context, update);
        break;
    }
  }

  void _handleCourseUpdate(BuildContext context, Update update) {
    final courseId = update.metadata?['courseId'];
    if (courseId != null) {
      // Navigate to course details or enrollment
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Enrolling in ${update.title}'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      _showUpdateDetails(context, update);
    }
  }

  void _handleArticleUpdate(BuildContext context, Update update) {
    _showUpdateDetails(context, update);
  }

  void _handleNewsUpdate(BuildContext context, Update update) {
    _showUpdateDetails(context, update);
  }

  void _showUpdateDetails(BuildContext context, Update update) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(update.title),
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
              Text(update.description),
              const SizedBox(height: 16),
              if (update.author != null) ...[
                Text('By ${update.author}'),
                const SizedBox(height: 8),
              ],
              if (update.readTime != null) ...[
                Text('Read time: ${update.readTime}'),
                const SizedBox(height: 8),
              ],
              Text('Published: ${_formatDate(update.publishDate)}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (update.type == 'course')
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _handleCourseUpdate(context, update);
              },
              child: const Text('Enroll Now'),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}