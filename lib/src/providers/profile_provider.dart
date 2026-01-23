// lib/providers/profile_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/profile_model.dart';
import '../models/settings_model.dart';
import '../services/profile_service.dart';

class ProfileProvider with ChangeNotifier {
  UserProfile? _userProfile;
  AppSettings _appSettings = AppSettings();
  LearningAnalytics? _learningAnalytics;
  bool _isLoading = false;
  String? _error;

  // Getters
  UserProfile? get userProfile => _userProfile;
  AppSettings get appSettings => _appSettings;
  LearningAnalytics? get learningAnalytics => _learningAnalytics;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Profile Service
  final ProfileService _profileService = ProfileService();

  // Load user profile
  Future<void> loadUserProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _userProfile = await _profileService.getUserProfile();
      _appSettings = await _profileService.getAppSettings();
      _learningAnalytics = await _profileService.getLearningAnalytics();
      _error = null;
    } catch (e) {
      _error = 'Failed to load profile: $e';
      if (kDebugMode) {
        print('Error loading profile: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update profile
  Future<void> updateProfile({
    String? name,
    String? email,
    String? bio,
    String? studyFocus,
    String? educationLevel,
    String? preferredLanguage,
    List<String>? interests,
  }) async {
    if (_userProfile == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final updatedProfile = UserProfile(
        userId: _userProfile!.userId,
        name: name ?? _userProfile!.name,
        email: email ?? _userProfile!.email,
        profileImageUrl: _userProfile!.profileImageUrl,
        bio: bio ?? _userProfile!.bio,
        studyFocus: studyFocus ?? _userProfile!.studyFocus,
        educationLevel: educationLevel ?? _userProfile!.educationLevel,
        preferredLanguage: preferredLanguage ?? _userProfile!.preferredLanguage,
        joinDate: _userProfile!.joinDate,
        preferences: _userProfile!.preferences,
        interests: interests ?? _userProfile!.interests,
      );

      await _profileService.updateUserProfile(updatedProfile);
      _userProfile = updatedProfile;
      _error = null;
    } catch (e) {
      _error = 'Failed to update profile: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update settings
  Future<void> updateSettings(AppSettings newSettings) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _profileService.updateAppSettings(newSettings);
      _appSettings = newSettings;
      _error = null;
    } catch (e) {
      _error = 'Failed to update settings: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update profile picture
  Future<void> updateProfilePicture(String imageUrl) async {
    if (_userProfile == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _profileService.updateProfilePicture(_userProfile!.userId, imageUrl);
      _userProfile = UserProfile(
        userId: _userProfile!.userId,
        name: _userProfile!.name,
        email: _userProfile!.email,
        profileImageUrl: imageUrl,
        bio: _userProfile!.bio,
        studyFocus: _userProfile!.studyFocus,
        educationLevel: _userProfile!.educationLevel,
        preferredLanguage: _userProfile!.preferredLanguage,
        joinDate: _userProfile!.joinDate,
        preferences: _userProfile!.preferences,
        interests: _userProfile!.interests,
      );
      _error = null;
    } catch (e) {
      _error = 'Failed to update profile picture: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}