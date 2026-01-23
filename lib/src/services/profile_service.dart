// lib/services/profile_service.dart
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/profile_model.dart';
import '../models/settings_model.dart';

class ProfileService {
  // Mock data - replace with actual API calls
  Future<UserProfile> getUserProfile() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // For now, return mock data
    return UserProfile(
      userId: '1',
      name: 'Alex Johnson',
      email: 'alex@example.com',
      profileImageUrl: 'https://ui-avatars.com/api/?name=Alex+Johnson&background=4361EE&color=fff',
      bio: 'Passionate learner focused on technology and science. Always looking to expand knowledge.',
      studyFocus: 'Computer Science & Data Analysis',
      educationLevel: 'Bachelor\'s Degree',
      preferredLanguage: 'English',
      joinDate: DateTime(2024, 1, 1),
      preferences: {
        'dailyGoal': 60,
        'weeklyTarget': 420,
        'difficulty': 'intermediate',
      },
      interests: ['Programming', 'Data Science', 'AI', 'Mathematics', 'Physics'],
    );
  }

  Future<AppSettings> getAppSettings() async {
    await Future.delayed(const Duration(milliseconds: 300));

    return AppSettings(
      notificationsEnabled: true,
      emailNotifications: true,
      darkMode: false,
      autoPlayVideos: true,
      downloadOverWifiOnly: true,
      studyReminderTime: '18:00',
      dailyGoalMinutes: 60,
      difficultyPreference: 'intermediate',
      contentLanguage: 'en',
      preferredCategories: ['Technology', 'Science', 'Mathematics'],
      accessibilityOptions: {
        'highContrast': false,
        'textToSpeech': false,
        'reducedMotion': false,
      },
    );
  }

  Future<LearningAnalytics> getLearningAnalytics() async {
    await Future.delayed(const Duration(milliseconds: 700));

    // Generate mock weekly performance data
    final now = DateTime.now();
    final weeklyPerformance = List.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index));
      return PerformanceMetric(
        date: date,
        score: 70 + (index * 5) + (DateTime.now().microsecondsSinceEpoch % 20),
        studyMinutes: 45 + (index * 10) + (DateTime.now().microsecondsSinceEpoch % 30),
        completedLessons: 2 + (index ~/ 2) + (DateTime.now().microsecondsSinceEpoch % 3),
        xpEarned: 150 + (index * 25) + (DateTime.now().microsecondsSinceEpoch % 50),
      );
    });

    return LearningAnalytics(
      averageScore: 82.5,
      totalStudyHours: 48,
      totalLessonsCompleted: 35,
      totalXpEarned: 1247,
      consistencyScore: 88.3,
      categoryBreakdown: {
        'Programming': 40,
        'Mathematics': 25,
        'Science': 20,
        'Languages': 15,
      },
      weeklyPerformance: weeklyPerformance,
    );
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    await Future.delayed(const Duration(milliseconds: 800));
    // In real app, make API call to update profile
    print('Profile updated: ${profile.name}');
  }

  Future<void> updateAppSettings(AppSettings settings) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // In real app, make API call to update settings
    print('Settings updated');
  }

  Future<void> updateProfilePicture(String userId, String imageUrl) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    // In real app, upload image and update profile
    print('Profile picture updated for user: $userId');
  }
}