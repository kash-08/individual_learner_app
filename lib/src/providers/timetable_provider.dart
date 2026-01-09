import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/timetable_model.dart';

class TimetableProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<TimetableSlot> _timetableSlots = [];
  bool _isLoading = false;
  String? _error;

  List<TimetableSlot> get timetableSlots => _timetableSlots;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get slots for a specific date
  List<TimetableSlot> getSlotsForDate(DateTime date) {
    return _timetableSlots.where((slot) {
      return slot.date.year == date.year &&
          slot.date.month == date.month &&
          slot.date.day == date.day;
    }).toList();
  }

  // Get today's slots
  List<TimetableSlot> getTodaySlots() {
    final today = DateTime.now();
    return getSlotsForDate(today);
  }

  // Get upcoming slots (from now onwards)
  List<TimetableSlot> getUpcomingSlots() {
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
      _isLoading = true;
      _error = null;
      notifyListeners();

      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');

      final querySnapshot = await _firestore
          .collection('timetable_slots')
          .where('userId', isEqualTo: userId)
          .orderBy('date')
          .orderBy('startTime')
          .get();

      _timetableSlots = querySnapshot.docs
          .map((doc) => TimetableSlot.fromFirestore(doc))
          .toList();

      // Generate recurring slots for the next 30 days
      _generateRecurringSlots();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Generate recurring slots for the next 30 days
  void _generateRecurringSlots() {
    final recurringSlots = _timetableSlots.where((slot) => slot.isRecurring);
    final now = DateTime.now();
    final endDate = now.add(const Duration(days: 30));

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
              id: '${slot.id}_${currentDate.toIso8601String()}',
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
      _isLoading = true;
      notifyListeners();

      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');

      // Generate a unique ID for the slot
      final docRef = _firestore.collection('timetable_slots').doc();

      final newSlot = slot.copyWith(
        id: docRef.id,
        userId: userId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await docRef.set(newSlot.toFirestore());

      _timetableSlots.add(newSlot);
      _generateRecurringSlots();

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
      _isLoading = true;
      notifyListeners();

      await _firestore
          .collection('timetable_slots')
          .doc(updatedSlot.id)
          .update(updatedSlot.toFirestore());

      final index = _timetableSlots.indexWhere((slot) => slot.id == updatedSlot.id);
      if (index != -1) {
        _timetableSlots[index] = updatedSlot;
        _generateRecurringSlots();
      }

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
      final slot = _timetableSlots.firstWhere((s) => s.id == slotId);
      final updatedSlot = slot.copyWith(isCompleted: isCompleted);

      await updateTimetableSlot(updatedSlot);
    } catch (e) {
      rethrow;
    }
  }

  // Delete a timetable slot
  Future<void> deleteTimetableSlot(String slotId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firestore
          .collection('timetable_slots')
          .doc(slotId)
          .delete();

      _timetableSlots.removeWhere((slot) => slot.id == slotId);
      _generateRecurringSlots();

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
  TimetableStats getStats() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekAgo = today.subtract(const Duration(days: 7));

    final recentSlots = _timetableSlots.where((slot) =>
    slot.date.isAfter(weekAgo) && slot.date.isBefore(today.add(const Duration(days: 1))));

    double totalMinutes = 0;
    final studyTimeByDay = <String, int>{};
    int completedCount = 0;

    for (var slot in recentSlots) {
      final dayName = _getDayName(slot.date.weekday);
      final durationMinutes = slot.duration.inMinutes;

      totalMinutes += durationMinutes;
      studyTimeByDay[dayName] = (studyTimeByDay[dayName] ?? 0) + durationMinutes;

      if (slot.isCompleted) completedCount++;
    }

    return TimetableStats(
      totalSlots: _timetableSlots.length,
      completedSlots: completedCount,
      upcomingSlots: getUpcomingSlots().length,
      totalStudyHours: totalMinutes / 60,
      averageStudyTimePerDay: totalMinutes / 7 / 60, // Average per day over last 7 days
      studyTimeByDay: studyTimeByDay,
    );
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

  // AI-generated timetable suggestions based on enrolled courses
  Future<List<TimetableSlot>> generateAISuggestions({
    required List<String> courseIds,
    required int preferredStudyHoursPerDay,
    required List<int> preferredDays,
    required TimeOfDay preferredStartTime,
    int weeks = 4,
  }) async {
    // This is a simplified version - you can integrate with actual AI service
    final suggestions = <TimetableSlot>[];
    final now = DateTime.now();

    for (int week = 0; week < weeks; week++) {
      for (var day in preferredDays) {
        final date = now.add(Duration(days: (week * 7) + day - 1));

        final slot = TimetableSlot(
          id: 'ai_suggestion_${date.toIso8601String()}',
          userId: _auth.currentUser?.uid ?? '',
          date: date,
          startTime: preferredStartTime,
          endTime: TimeOfDay(
            hour: preferredStartTime.hour + preferredStudyHoursPerDay,
            minute: preferredStartTime.minute,
          ),
          title: 'Study Session',
          description: 'AI-suggested study time',
          colorHex: '#4CAF50',
          isCompleted: false,
          isRecurring: true,
          recurringDays: preferredDays,
          recurringEndDate: now.add(Duration(days: weeks * 7)),
          createdAt: now,
          updatedAt: now,
        );

        suggestions.add(slot);
      }
    }

    return suggestions;
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