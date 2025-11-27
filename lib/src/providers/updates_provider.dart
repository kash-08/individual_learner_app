import 'package:flutter/foundation.dart';
import '../models/update_model.dart';
import '../services/firebase_service.dart';

class UpdatesProvider with ChangeNotifier {
  List<Update> _updates = [];
  List<Update> _personalizedUpdates = [];
  bool _isLoading = false;
  String? _error;
  bool _hasLoaded = false;

  List<Update> get updates => _updates;
  List<Update> get personalizedUpdates => _personalizedUpdates;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasLoaded => _hasLoaded;

  // Get updates for the current week
  List<Update> get weeklyUpdates {
    final oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));
    return _updates.where((update) =>
        update.publishDate.isAfter(oneWeekAgo)
    ).toList();
  }

  // Get new courses only
  List<Update> get newCourses {
    return _updates.where((update) =>
    update.type == 'course' && update.isNew
    ).toList();
  }

  // Get articles only
  List<Update> get articles {
    return _updates.where((update) =>
    update.type == 'article'
    ).toList();
  }

  // Get news only
  List<Update> get news {
    return _updates.where((update) =>
    update.type == 'news'
    ).toList();
  }

  Future<void> loadUpdates() async {
    if (_hasLoaded) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load from Firebase
      _updates = await FirebaseService.getWeeklyUpdates();

      // Generate personalized content based on user interests
      _generatePersonalizedUpdates();

      _hasLoaded = true;
      print('✅ Loaded ${_updates.length} updates');
      print('✅ Generated ${_personalizedUpdates.length} personalized updates');

    } catch (e) {
      _error = 'Failed to load updates: $e';
      print('❌ Error loading updates: $e');
      // Load mock data as fallback
      _loadMockUpdates();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshUpdates() async {
    _hasLoaded = false;
    await loadUpdates();
  }

  void markAsRead(String updateId) {
    final index = _updates.indexWhere((update) => update.id == updateId);
    if (index != -1) {
      _updates[index] = Update(
        id: _updates[index].id,
        title: _updates[index].title,
        description: _updates[index].description,
        type: _updates[index].type,
        imageUrl: _updates[index].imageUrl,
        publishDate: _updates[index].publishDate,
        category: _updates[index].category,
        author: _updates[index].author,
        readTime: _updates[index].readTime,
        isNew: false,
        metadata: _updates[index].metadata,
      );
      notifyListeners();
    }
  }

  void _generatePersonalizedUpdates() {
    // This would be enhanced with actual user preference data
    // For now, we'll prioritize certain categories and types

    final userInterests = ['Mobile Development', 'AI & ML', 'Web Development'];

    _personalizedUpdates = _updates.where((update) {
      // Prioritize user interests
      if (userInterests.contains(update.category)) {
        return true;
      }

      // Include new courses and trending content
      if (update.type == 'course' && update.isNew) {
        return true;
      }

      // Include recent articles
      if (update.type == 'article' &&
          update.publishDate.isAfter(DateTime.now().subtract(const Duration(days: 3)))) {
        return true;
      }

      return false;
    }).toList();

    // Sort by relevance (newest first, then by user interest)
    _personalizedUpdates.sort((a, b) {
      if (a.isNew && !b.isNew) return -1;
      if (!a.isNew && b.isNew) return 1;
      return b.publishDate.compareTo(a.publishDate);
    });
  }

  void _loadMockUpdates() {
    print('📦 Loading mock updates as fallback');

    _updates = [
      Update(
        id: '1',
        title: 'New Flutter Course: Advanced State Management',
        description: 'Learn advanced state management techniques with Riverpod and Bloc',
        type: 'course',
        imageUrl: 'https://via.placeholder.com/300x200/4361EE/FFFFFF?text=Flutter+Advanced',
        publishDate: DateTime.now().subtract(const Duration(days: 1)),
        category: 'Mobile Development',
        author: 'Jane Smith',
        readTime: '8 hours',
        isNew: true,
        metadata: {
          'courseId': 'flutter-advanced-2024',
          'difficulty': 'Advanced',
          'enrollmentCount': 1247,
        },
      ),
      Update(
        id: '2',
        title: 'The Future of AI in Mobile Development',
        description: 'Exploring how AI is transforming mobile app development and user experiences',
        type: 'article',
        imageUrl: 'https://via.placeholder.com/300x200/3A0CA3/FFFFFF?text=AI+Future',
        publishDate: DateTime.now().subtract(const Duration(days: 2)),
        category: 'AI & ML',
        author: 'Dr. Alex Chen',
        readTime: '8 min',
        isNew: true,
        metadata: {
          'readCount': 2843,
          'likes': 156,
        },
      ),
      Update(
        id: '3',
        title: 'React Native 2024 Updates',
        description: 'Major updates and new features in the latest React Native release',
        type: 'news',
        imageUrl: 'https://via.placeholder.com/300x200/7209B7/FFFFFF?text=React+Native',
        publishDate: DateTime.now().subtract(const Duration(days: 3)),
        category: 'Mobile Development',
        author: 'John Doe',
        readTime: '5 min',
        isNew: true,
      ),
      Update(
        id: '4',
        title: 'Python for Machine Learning: Complete Guide',
        description: 'Comprehensive guide to machine learning with Python and TensorFlow',
        type: 'course',
        imageUrl: 'https://via.placeholder.com/300x200/4CC9F0/FFFFFF?text=Python+ML',
        publishDate: DateTime.now().subtract(const Duration(days: 4)),
        category: 'AI & ML',
        author: 'Mike Johnson',
        readTime: '12 hours',
        isNew: false,
        metadata: {
          'courseId': 'python-ml-2024',
          'difficulty': 'Intermediate',
          'enrollmentCount': 3562,
        },
      ),
      Update(
        id: '5',
        title: 'Web Development Trends 2024',
        description: 'Top web development trends and technologies to watch this year',
        type: 'article',
        imageUrl: 'https://via.placeholder.com/300x200/F72585/FFFFFF?text=Web+Trends',
        publishDate: DateTime.now().subtract(const Duration(days: 5)),
        category: 'Web Development',
        author: 'Sarah Wilson',
        readTime: '10 min',
        isNew: true,
      ),
    ];

    _generatePersonalizedUpdates();
  }
}