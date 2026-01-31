import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_timetable_service.dart';
import '../models/timetable_model.dart';

class TimetableProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseTimetableService _timetableService = firebaseTimetableService;

  List<TimetableSlot> _timetableSlots = [];
  bool _isLoading = false;
  String? _error;
  User? _currentUser;
  StreamSubscription<List<TimetableSlot>>? _timetableSubscription;
  StreamSubscription<User?>? _authStateSubscription;

  List<TimetableSlot> get timetableSlots => _timetableSlots;
  bool get isLoading => _isLoading;
  String? get error => _error;
  User? get currentUser => _currentUser;

  TimetableProvider() {
    // Listen to auth state changes
    _authStateSubscription = _auth.authStateChanges().listen((user) {
      initializeWithUser(user);
    });

    // Initialize with current user if already logged in
    initializeWithUser(_auth.currentUser);
  }

  // Initialize provider with user
  void initializeWithUser(User? user) {
    print('TimetableProvider: User changed to ${user?.uid ?? 'null'}');

    // Clear any existing subscription
    _timetableSubscription?.cancel();

    _currentUser = user;

    if (user != null) {
      _error = null;
      _setupRealtimeUpdates();
      loadTimetableSlots();
    } else {
      _clearData();
    }

    notifyListeners();
  }

  // Set up real-time updates
  void _setupRealtimeUpdates() {
    if (_currentUser == null) {
      _error = 'User not logged in';
      notifyListeners();
      return;
    }

    try {
      _timetableSubscription = _timetableService.streamUserTimetableSlots().listen(
            (slots) {
          print('TimetableProvider: Received ${slots.length} slots from stream');
          _timetableSlots = slots;
          _generateRecurringSlots(); // Regenerate recurring slots
          _error = null;
          notifyListeners();
        },
        onError: (error) {
          print('TimetableProvider: Stream error: $error');
          _error = error.toString();
          notifyListeners();
        },
        cancelOnError: true,
      );
    } catch (e) {
      print('TimetableProvider: Error setting up stream: $e');
      _error = e.toString();
      notifyListeners();
    }
  }

  // Get slots for a specific date
  List<TimetableSlot> getSlotsForDate(DateTime date) {
    if (_currentUser == null) {
      return [];
    }

    return _timetableSlots.where((slot) {
      return slot.date.year == date.year &&
          slot.date.month == date.month &&
          slot.date.day == date.day;
    }).toList();
  }

  // Get today's slots
  List<TimetableSlot> getTodaySlots() {
    if (_currentUser == null) {
      return [];
    }

    final today = DateTime.now();
    return getSlotsForDate(today);
  }

  // Get upcoming slots (from now onwards)
  List<TimetableSlot> getUpcomingSlots() {
    if (_currentUser == null) {
      return [];
    }

    final now = DateTime.now();
    return _timetableSlots.where((slot) {
      final slotDateTime = DateTime(
          slot.date.year, slot.date.month, slot.date.day,
          slot.startTime.hour, slot.startTime.minute
      );
      return slotDateTime.isAfter(now);
    }).toList();
  }

  // Load all timetable slots for current user
  Future<void> loadTimetableSlots() async {
    try {
      if (_currentUser == null) {
        print('TimetableProvider: Cannot load slots - user is null');
        _error = 'User not logged in';
        notifyListeners();
        return;
      }

      _isLoading = true;
      _error = null;
      notifyListeners();

      print('TimetableProvider: Loading slots for user ${_currentUser!.uid}');

      // Load from service
      _timetableSlots = await _timetableService.getUserTimetableSlots();

      print('TimetableProvider: Loaded ${_timetableSlots.length} slots');

      // Generate recurring slots for the next 30 days
      _generateRecurringSlots();

      _isLoading = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      print('TimetableProvider: Error loading slots: $e');
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Generate recurring slots for the next 30 days
  void _generateRecurringSlots() {
    if (_currentUser == null) return;

    final recurringSlots = _timetableSlots.where((slot) => slot.isRecurring).toList();
    if (recurringSlots.isEmpty) return;

    final now = DateTime.now();
    final endDate = now.add(const Duration(days: 30));

    // Remove previously generated recurring slots
    _timetableSlots.removeWhere((slot) => slot.id.contains('_generated_'));

    for (var slot in recurringSlots) {
      for (var day in slot.recurringDays) {
        DateTime currentDate = _getNextOccurrence(day, now);

        while (currentDate.isBefore(endDate)) {
          // Check if slot already exists for this date
          final exists = _timetableSlots.any((existing) =>
          existing.date.year == currentDate.year &&
              existing.date.month == currentDate.month &&
              existing.date.day == currentDate.day &&
              existing.startTime == slot.startTime &&
              existing.title == slot.title);

          if (!exists && (slot.recurringEndDate == null ||
              currentDate.isBefore(slot.recurringEndDate!))) {

            final generatedSlot = TimetableSlot(
              id: '${slot.id}_generated_${currentDate.toIso8601String()}',
              userId: slot.userId,
              date: currentDate,
              startTime: slot.startTime,
              endTime: slot.endTime,
              title: slot.title,
              description: slot.description,
              courseId: slot.courseId,
              colorHex: slot.colorHex,
              isCompleted: false,
              isRecurring: true,
              recurringDays: slot.recurringDays,
              recurringEndDate: slot.recurringEndDate,
              createdAt: slot.createdAt,
              updatedAt: slot.updatedAt,
            );

            _timetableSlots.add(generatedSlot);
          }

          currentDate = currentDate.add(const Duration(days: 7));
        }
      }
    }

    // Sort all slots
    _timetableSlots.sort((a, b) {
      final aDateTime = DateTime(
          a.date.year, a.date.month, a.date.day,
          a.startTime.hour, a.startTime.minute
      );
      final bDateTime = DateTime(
          b.date.year, b.date.month, b.date.day,
          b.startTime.hour, b.startTime.minute
      );
      return aDateTime.compareTo(bDateTime);
    });
  }

  DateTime _getNextOccurrence(int dayOfWeek, DateTime fromDate) {
    final daysToAdd = (dayOfWeek - fromDate.weekday + 7) % 7;
    return fromDate.add(Duration(days: daysToAdd == 0 ? 7 : daysToAdd));
  }

  // Add a new timetable slot
  Future<void> addTimetableSlot(TimetableSlot slot) async {
    try {
      if (_currentUser == null) {
        throw Exception('User not logged in');
      }

      _isLoading = true;
      _error = null;
      notifyListeners();

      await _timetableService.addTimetableSlot(slot);

      // The real-time stream will update the list automatically
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Update a timetable slot
  Future<void> updateTimetableSlot(TimetableSlot updatedSlot) async {
    try {
      if (_currentUser == null) {
        throw Exception('User not logged in');
      }

      _isLoading = true;
      _error = null;
      notifyListeners();

      await _timetableService.updateTimetableSlot(updatedSlot);

      // The real-time stream will update the list automatically
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Mark slot as completed/incomplete
  Future<void> toggleSlotCompletion(String slotId, bool isCompleted) async {
    try {
      if (_currentUser == null) {
        throw Exception('User not logged in');
      }

      await _timetableService.toggleSlotCompletion(slotId, isCompleted);
    } catch (e) {
      rethrow;
    }
  }

  // Delete a timetable slot
  Future<void> deleteTimetableSlot(String slotId) async {
    try {
      if (_currentUser == null) {
        throw Exception('User not logged in');
      }

      _isLoading = true;
      _error = null;
      notifyListeners();

      await _timetableService.deleteTimetableSlot(slotId);

      // The real-time stream will update the list automatically
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Bulk add slots (for AI suggestions)
  Future<void> bulkAddTimetableSlots(List<TimetableSlot> slots) async {
    try {
      if (_currentUser == null) {
        throw Exception('User not logged in');
      }

      _isLoading = true;
      _error = null;
      notifyListeners();

      await _timetableService.bulkAddTimetableSlots(slots);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Get timetable statistics
  Future<TimetableStats> getStats({int daysBack = 30}) async {
    try {
      if (_currentUser == null) {
        throw Exception('User not logged in');
      }

      return await _timetableService.getTimetableStats(daysBack: daysBack);
    } catch (e) {
      rethrow;
    }
  }

  // Check for slot conflicts
  Future<bool> hasSlotConflict(
      DateTime date,
      TimeOfDay startTime,
      TimeOfDay endTime, {
        String? excludeSlotId,
      }) async {
    if (_currentUser == null) {
      throw Exception('User not logged in');
    }

    return await _timetableService.hasSlotConflict(
      date,
      startTime,
      endTime,
      excludeSlotId: excludeSlotId,
    );
  }

  // Get slots by course ID
  Future<List<TimetableSlot>> getSlotsByCourse(String courseId) async {
    try {
      if (_currentUser == null) {
        throw Exception('User not logged in');
      }

      return await _timetableService.getSlotsByCourse(courseId);
    } catch (e) {
      rethrow;
    }
  }

  // Get completed slots count
  Future<int> getCompletedSlotsCount({DateTime? startDate, DateTime? endDate}) async {
    if (_currentUser == null) {
      throw Exception('User not logged in');
    }

    return await _timetableService.getCompletedSlotsCount(
      startDate: startDate,
      endDate: endDate,
    );
  }

  // Get recurring slots
  Future<List<TimetableSlot>> getRecurringSlots() async {
    if (_currentUser == null) {
      throw Exception('User not logged in');
    }

    return await _timetableService.getRecurringSlots();
  }

  // Clear all user timetable data
  Future<void> clearUserTimetable() async {
    try {
      if (_currentUser == null) {
        throw Exception('User not logged in');
      }

      await _timetableService.clearUserTimetable();
    } catch (e) {
      rethrow;
    }
  }

  // AI-generated timetable suggestions based on enrolled courses
  Future<List<TimetableSlot>> generateAISuggestions({
    required List<String> courseIds,
    required int preferredStudyHoursPerDay,
    required List<int> preferredDays,
    required TimeOfDay preferredStartTime,
    int weeks = 4,
  }) async {
    try {
      if (_currentUser == null) {
        throw Exception('User not logged in');
      }

      return await _timetableService.generateAISuggestions(
        courseIds: courseIds,
        preferredStudyHoursPerDay: preferredStudyHoursPerDay,
        preferredDays: preferredDays,
        preferredStartTime: preferredStartTime,
        weeks: weeks,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Clear all data
  void _clearData() {
    print('TimetableProvider: Clearing all data');
    _timetableSlots.clear();
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  // Clean up resources
  void disposeProvider() {
    print('TimetableProvider: Disposing provider');
    _timetableSubscription?.cancel();
    _authStateSubscription?.cancel();
    _clearData();
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Mon';
      case 2: return 'Tue';
      case 3: return 'Wed';
      case 4: return 'Thu';
      case 5: return 'Fri';
      case 6: return 'Sat';
      case 7: return 'Sun';
      default: return '';
    }
  }
}

// Extension for copyWith method
extension TimetableSlotExtension on TimetableSlot {
  TimetableSlot copyWith({
    String? id,
    String? userId,
    DateTime? date,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    String? title,
    String? description,
    String? courseId,
    String? colorHex,
    bool? isCompleted,
    bool? isRecurring,
    List<int>? recurringDays,
    DateTime? recurringEndDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TimetableSlot(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      title: title ?? this.title,
      description: description ?? this.description,
      courseId: courseId ?? this.courseId,
      colorHex: colorHex ?? this.colorHex,
      isCompleted: isCompleted ?? this.isCompleted,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringDays: recurringDays ?? this.recurringDays,
      recurringEndDate: recurringEndDate ?? this.recurringEndDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}