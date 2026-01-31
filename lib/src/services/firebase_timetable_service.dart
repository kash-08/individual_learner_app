// lib/src/services/firebase_timetable_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/timetable_model.dart';

class FirebaseTimetableService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection references
  static const String timetableCollection = 'timetable_slots';
  static const String usersCollection = 'users';
  static const String coursesCollection = 'courses';

  // Helper method to check and create indexes
  Future<void> _handleIndexError(Function() queryFunction, String queryName) async {
    try {
      return await queryFunction();
    } catch (e) {
      if (e.toString().contains('requires an index')) {
        print('⚠️ Index required for $queryName query');
        print('ℹ️ Check Firebase Console for index creation link');
        // Try a simpler fallback query
        throw Exception('Index needed. Please wait a few minutes for it to build.');
      }
      rethrow;
    }
  }

  // CRUD Operations for Timetable Slots

  /// Get all timetable slots for the current user
  Future<List<TimetableSlot>> getUserTimetableSlots() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');

      final querySnapshot = await _firestore
          .collection(timetableCollection)
          .where('userId', isEqualTo: userId)
          .get();

      final slots = querySnapshot.docs
          .map((doc) => TimetableSlot.fromFirestore(doc))
          .toList();

      // Sort manually
      slots.sort((a, b) {
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

      return slots;
    } catch (e) {
      print('Error getting timetable slots: $e');
      rethrow;
    }
  }

  /// Get timetable slots for a specific date range
  Future<List<TimetableSlot>> getTimetableSlotsInRange(
      DateTime startDate,
      DateTime endDate,
      ) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');

      final querySnapshot = await _firestore
          .collection(timetableCollection)
          .where('userId', isEqualTo: userId)
          .get();

      // Filter manually in Dart
      final slots = querySnapshot.docs
          .map((doc) => TimetableSlot.fromFirestore(doc))
          .where((slot) =>
      slot.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
          slot.date.isBefore(endDate.add(const Duration(days: 1))))
          .toList();

      // Sort manually
      slots.sort((a, b) {
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

      return slots;
    } catch (e) {
      print('Error getting slots in range: $e');
      rethrow;
    }
  }

  /// Get today's timetable slots
  Future<List<TimetableSlot>> getTodaySlots() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return getTimetableSlotsInRange(startOfDay, endOfDay);
  }

  /// Get upcoming timetable slots (next 7 days)
  Future<List<TimetableSlot>> getUpcomingSlots({int days = 7}) async {
    final now = DateTime.now();
    final startDate = now;
    final endDate = now.add(Duration(days: days));

    return getTimetableSlotsInRange(startDate, endDate);
  }

  /// Add a new timetable slot
  Future<TimetableSlot> addTimetableSlot(TimetableSlot slot) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');

      // Generate a new document reference
      final docRef = _firestore.collection(timetableCollection).doc();

      // Create the final slot with ID
      final finalSlot = TimetableSlot(
        id: docRef.id,
        userId: userId,
        date: slot.date,
        startTime: slot.startTime,
        endTime: slot.endTime,
        title: slot.title,
        description: slot.description,
        courseId: slot.courseId,
        colorHex: slot.colorHex,
        isCompleted: slot.isCompleted,
        isRecurring: slot.isRecurring,
        recurringDays: slot.recurringDays,
        recurringEndDate: slot.recurringEndDate,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to Firestore
      await docRef.set(finalSlot.toFirestore());

      return finalSlot;
    } catch (e) {
      print('Error adding timetable slot: $e');
      rethrow;
    }
  }

  /// Update an existing timetable slot
  Future<void> updateTimetableSlot(TimetableSlot slot) async {
    try {
      final updatedSlot = TimetableSlot(
        id: slot.id,
        userId: slot.userId,
        date: slot.date,
        startTime: slot.startTime,
        endTime: slot.endTime,
        title: slot.title,
        description: slot.description,
        courseId: slot.courseId,
        colorHex: slot.colorHex,
        isCompleted: slot.isCompleted,
        isRecurring: slot.isRecurring,
        recurringDays: slot.recurringDays,
        recurringEndDate: slot.recurringEndDate,
        createdAt: slot.createdAt,
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection(timetableCollection)
          .doc(slot.id)
          .update(updatedSlot.toFirestore());
    } catch (e) {
      print('Error updating timetable slot: $e');
      rethrow;
    }
  }

  /// Delete a timetable slot
  Future<void> deleteTimetableSlot(String slotId) async {
    try {
      await _firestore.collection(timetableCollection).doc(slotId).delete();
    } catch (e) {
      print('Error deleting timetable slot: $e');
      rethrow;
    }
  }

  /// Mark a slot as completed/incompleted
  Future<void> toggleSlotCompletion(String slotId, bool isCompleted) async {
    try {
      await _firestore.collection(timetableCollection).doc(slotId).update({
        'isCompleted': isCompleted,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      print('Error toggling slot completion: $e');
      rethrow;
    }
  }

  /// Get timetable statistics for the current user
  Future<TimetableStats> getTimetableStats({
    int daysBack = 30,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');

      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: daysBack));

      final slots = await getTimetableSlotsInRange(startDate, endDate);

      // Calculate statistics
      final totalSlots = slots.length;
      final completedSlots = slots.where((slot) => slot.isCompleted).length;

      double totalStudyMinutes = 0;
      final studyTimeByDay = <String, int>{};

      for (var slot in slots) {
        final durationMinutes = slot.duration.inMinutes;
        totalStudyMinutes += durationMinutes;

        final dayName = _getDayName(slot.date.weekday);
        studyTimeByDay[dayName] = (studyTimeByDay[dayName] ?? 0) + durationMinutes;
      }

      final totalStudyHours = totalStudyMinutes / 60;
      final averageStudyTimePerDay = totalStudyMinutes / daysBack / 60;

      return TimetableStats(
        totalSlots: totalSlots,
        completedSlots: completedSlots,
        upcomingSlots: slots.where((slot) => slot.isUpcoming()).length,
        totalStudyHours: totalStudyHours,
        averageStudyTimePerDay: averageStudyTimePerDay,
        studyTimeByDay: studyTimeByDay,
      );
    } catch (e) {
      print('Error getting timetable stats: $e');
      rethrow;
    }
  }

  /// Generate AI suggestions for study schedule
  Future<List<TimetableSlot>> generateAISuggestions({
    required List<String> courseIds,
    required int preferredStudyHoursPerDay,
    required List<int> preferredDays,
    required TimeOfDay preferredStartTime,
    int weeks = 4,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');

      final now = DateTime.now();
      final suggestions = <TimetableSlot>[];

      // Get course details if available
      String sessionTitle = 'Study Session';
      String sessionDescription = 'AI-suggested study time';

      if (courseIds.isNotEmpty) {
        final courseDetails = await _getCourseDetails(courseIds.first);
        if (courseDetails != null) {
          sessionTitle = '${courseDetails['title'] ?? 'Study'} Review';
          sessionDescription = 'Focus on ${courseDetails['category'] ?? 'key concepts'}';
        }
      }

      for (int week = 0; week < weeks; week++) {
        for (var day in preferredDays) {
          final date = _getNextWeekday(day, now.add(Duration(days: week * 7)));

          // Create a study session
          final slot = TimetableSlot(
            id: '', // Will be set when saved
            userId: userId,
            date: date,
            startTime: preferredStartTime,
            endTime: TimeOfDay(
              hour: preferredStartTime.hour + preferredStudyHoursPerDay,
              minute: preferredStartTime.minute,
            ),
            title: sessionTitle,
            description: sessionDescription,
            courseId: courseIds.isNotEmpty ? courseIds.first : '',
            colorHex: _getColorForDay(day),
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
    } catch (e) {
      print('Error generating AI suggestions: $e');
      rethrow;
    }
  }

  /// Stream timetable slots for real-time updates
  Stream<List<TimetableSlot>> streamUserTimetableSlots() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return const Stream.empty();
    }

    try {
      return _firestore
          .collection(timetableCollection)
          .where('userId', isEqualTo: userId)
          .snapshots()
          .map((snapshot) {
        final slots = snapshot.docs
            .map((doc) => TimetableSlot.fromFirestore(doc))
            .toList();

        // Sort manually
        slots.sort((a, b) {
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

        return slots;
      });
    } catch (e) {
      print('Stream error (falling back to empty): $e');
      return const Stream.empty();
    }
  }

  /// Stream today's slots for real-time updates
  Stream<List<TimetableSlot>> streamTodaySlots() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return const Stream.empty();
    }

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    return _firestore
        .collection(timetableCollection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final slots = snapshot.docs
          .map((doc) => TimetableSlot.fromFirestore(doc))
          .where((slot) =>
      slot.date.year == startOfDay.year &&
          slot.date.month == startOfDay.month &&
          slot.date.day == startOfDay.day)
          .toList();

      // Sort manually
      slots.sort((a, b) {
        final aTime = a.startTime.hour * 60 + a.startTime.minute;
        final bTime = b.startTime.hour * 60 + b.startTime.minute;
        return aTime.compareTo(bTime);
      });

      return slots;
    });
  }

  /// Stream upcoming slots for real-time updates
  Stream<List<TimetableSlot>> streamUpcomingSlots({int days = 7}) {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return const Stream.empty();
    }

    final now = DateTime.now();
    final endDate = now.add(Duration(days: days));

    return _firestore
        .collection(timetableCollection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final slots = snapshot.docs
          .map((doc) => TimetableSlot.fromFirestore(doc))
          .where((slot) =>
      slot.date.isAfter(now.subtract(const Duration(hours: 1))) &&
          slot.date.isBefore(endDate))
          .toList();

      // Sort manually
      slots.sort((a, b) {
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

      return slots;
    });
  }

  /// Check for slot conflicts
  Future<bool> hasSlotConflict(
      DateTime date,
      TimeOfDay startTime,
      TimeOfDay endTime, {
        String? excludeSlotId,
      }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');

      final querySnapshot = await _firestore
          .collection(timetableCollection)
          .where('userId', isEqualTo: userId)
          .get();

      for (var doc in querySnapshot.docs) {
        final slot = TimetableSlot.fromFirestore(doc);

        // Skip if not same date
        if (slot.date.year != date.year ||
            slot.date.month != date.month ||
            slot.date.day != date.day) {
          continue;
        }

        // Skip the slot we're editing
        if (excludeSlotId != null && slot.id == excludeSlotId) continue;

        // Check for time overlap
        final newStart = DateTime(date.year, date.month, date.day,
            startTime.hour, startTime.minute);
        final newEnd = DateTime(
            date.year, date.month, date.day, endTime.hour, endTime.minute);
        final existingStart = DateTime(date.year, date.month, date.day,
            slot.startTime.hour, slot.startTime.minute);
        final existingEnd = DateTime(date.year, date.month, date.day,
            slot.endTime.hour, slot.endTime.minute);

        if ((newStart.isBefore(existingEnd) && newEnd.isAfter(existingStart))) {
          return true; // Conflict found
        }
      }

      return false; // No conflicts
    } catch (e) {
      print('Error checking slot conflict: $e');
      rethrow;
    }
  }

  /// Bulk add timetable slots (for AI suggestions or imports)
  Future<List<TimetableSlot>> bulkAddTimetableSlots(List<TimetableSlot> slots) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');

      final batch = _firestore.batch();
      final addedSlots = <TimetableSlot>[];

      for (var slot in slots) {
        final docRef = _firestore.collection(timetableCollection).doc();
        final finalSlot = TimetableSlot(
          id: docRef.id,
          userId: userId,
          date: slot.date,
          startTime: slot.startTime,
          endTime: slot.endTime,
          title: slot.title,
          description: slot.description,
          courseId: slot.courseId,
          colorHex: slot.colorHex,
          isCompleted: slot.isCompleted,
          isRecurring: slot.isRecurring,
          recurringDays: slot.recurringDays,
          recurringEndDate: slot.recurringEndDate,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        batch.set(docRef, finalSlot.toFirestore());
        addedSlots.add(finalSlot);
      }

      await batch.commit();
      return addedSlots;
    } catch (e) {
      print('Error bulk adding slots: $e');
      rethrow;
    }
  }

  /// Clear all timetable slots (for testing or reset)
  Future<void> clearUserTimetable() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');

      final querySnapshot = await _firestore
          .collection(timetableCollection)
          .where('userId', isEqualTo: userId)
          .get();

      final batch = _firestore.batch();
      for (var doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      print('Error clearing timetable: $e');
      rethrow;
    }
  }

  /// Get slots by course ID
  Future<List<TimetableSlot>> getSlotsByCourse(String courseId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');

      final querySnapshot = await _firestore
          .collection(timetableCollection)
          .where('userId', isEqualTo: userId)
          .get();

      final slots = querySnapshot.docs
          .map((doc) => TimetableSlot.fromFirestore(doc))
          .where((slot) => slot.courseId == courseId)
          .toList();

      // Sort manually
      slots.sort((a, b) {
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

      return slots;
    } catch (e) {
      print('Error getting slots by course: $e');
      rethrow;
    }
  }

  /// Get completed slots count
  Future<int> getCompletedSlotsCount({DateTime? startDate, DateTime? endDate}) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');

      final querySnapshot = await _firestore
          .collection(timetableCollection)
          .where('userId', isEqualTo: userId)
          .get();

      var slots = querySnapshot.docs
          .map((doc) => TimetableSlot.fromFirestore(doc))
          .where((slot) => slot.isCompleted);

      // Apply date filters if provided
      if (startDate != null) {
        slots = slots.where((slot) => slot.date.isAfter(startDate.subtract(const Duration(days: 1))));
      }
      if (endDate != null) {
        slots = slots.where((slot) => slot.date.isBefore(endDate.add(const Duration(days: 1))));
      }

      return slots.length;
    } catch (e) {
      print('Error getting completed slots count: $e');
      rethrow;
    }
  }

  /// Get recurring slots that need to be generated
  Future<List<TimetableSlot>> getRecurringSlots() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');

      final querySnapshot = await _firestore
          .collection(timetableCollection)
          .where('userId', isEqualTo: userId)
          .get();

      return querySnapshot.docs
          .map((doc) => TimetableSlot.fromFirestore(doc))
          .where((slot) => slot.isRecurring)
          .toList();
    } catch (e) {
      print('Error getting recurring slots: $e');
      rethrow;
    }
  }

  /// Test index creation
  Future<void> testIndexQuery() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      // This will trigger index creation if needed
      await _firestore
          .collection(timetableCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('date')
          .orderBy('startTime')
          .limit(1)
          .get();

      print('✅ Index query successful');
    } catch (e) {
      print('⚠️ Index test failed: $e');
      if (e.toString().contains('requires an index')) {
        print('🔗 Please create the index in Firebase Console');
      }
    }
  }

  // Helper Methods

  Future<Map<String, dynamic>?> _getCourseDetails(String courseId) async {
    try {
      final doc = await _firestore.collection(coursesCollection).doc(courseId).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error getting course details: $e');
      return null;
    }
  }

  String _getColorForDay(int day) {
    final colors = [
      '#4361EE', // Monday - Blue
      '#4CAF50', // Tuesday - Green
      '#FF9800', // Wednesday - Orange
      '#F44336', // Thursday - Red
      '#9C27B0', // Friday - Purple
      '#00BCD4', // Saturday - Cyan
      '#795548', // Sunday - Brown
    ];
    return colors[(day - 1) % colors.length];
  }

  DateTime _getNextWeekday(int weekday, DateTime fromDate) {
    final daysToAdd = (weekday - fromDate.weekday + 7) % 7;
    return fromDate.add(Duration(days: daysToAdd == 0 ? 7 : daysToAdd));
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      case 7: return 'Sunday';
      default: return '';
    }
  }
}

// Singleton instance for easy access
FirebaseTimetableService firebaseTimetableService = FirebaseTimetableService();