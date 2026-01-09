import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TimetableSlot {
  final String id;
  final String userId;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String title;
  final String description;
  final String courseId; // Optional: link to a specific course
  final String colorHex;
  final bool isCompleted;
  final bool isRecurring;
  final List<int> recurringDays; // 1=Monday, 7=Sunday
  final DateTime? recurringEndDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  TimetableSlot({
    required this.id,
    required this.userId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.title,
    this.description = '',
    this.courseId = '',
    this.colorHex = '#4361EE',
    this.isCompleted = false,
    this.isRecurring = false,
    this.recurringDays = const [],
    this.recurringEndDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TimetableSlot.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return TimetableSlot(
      id: doc.id,
      userId: data['userId'],
      date: (data['date'] as Timestamp).toDate(),
      startTime: _timeFromMap(data['startTime']),
      endTime: _timeFromMap(data['endTime']),
      title: data['title'],
      description: data['description'] ?? '',
      courseId: data['courseId'] ?? '',
      colorHex: data['colorHex'] ?? '#4361EE',
      isCompleted: data['isCompleted'] ?? false,
      isRecurring: data['isRecurring'] ?? false,
      recurringDays: List<int>.from(data['recurringDays'] ?? []),
      recurringEndDate: data['recurringEndDate'] != null
          ? (data['recurringEndDate'] as Timestamp).toDate()
          : null,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'startTime': _timeToMap(startTime),
      'endTime': _timeToMap(endTime),
      'title': title,
      'description': description,
      'courseId': courseId,
      'colorHex': colorHex,
      'isCompleted': isCompleted,
      'isRecurring': isRecurring,
      'recurringDays': recurringDays,
      'recurringEndDate': recurringEndDate != null
          ? Timestamp.fromDate(recurringEndDate!)
          : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  static TimeOfDay _timeFromMap(Map<String, dynamic> map) {
    return TimeOfDay(hour: map['hour'] ?? 0, minute: map['minute'] ?? 0);
  }

  static Map<String, dynamic> _timeToMap(TimeOfDay time) {
    return {'hour': time.hour, 'minute': time.minute};
  }

  Duration get duration => Duration(
    hours: endTime.hour - startTime.hour,
    minutes: endTime.minute - startTime.minute,
  );

  bool isToday() {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool isUpcoming() {
    final now = DateTime.now();
    final slotDateTime = DateTime(
        date.year, date.month, date.day,
        startTime.hour, startTime.minute
    );
    return slotDateTime.isAfter(now);
  }
}

class TimetableStats {
  final int totalSlots;
  final int completedSlots;
  final int upcomingSlots;
  final double totalStudyHours;
  final double averageStudyTimePerDay;
  final Map<String, int> studyTimeByDay; // Day name -> minutes

  TimetableStats({
    required this.totalSlots,
    required this.completedSlots,
    required this.upcomingSlots,
    required this.totalStudyHours,
    required this.averageStudyTimePerDay,
    required this.studyTimeByDay,
  });
}