// lib/models/user_profile.dart
class UserProfile {
  final String? id;
  final String? name;
  final String? email;
  final String? profileImageUrl;
  final String? bio;
  final String? studyFocus;
  final String? educationLevel;
  final List<String>? interests;
  final DateTime? memberSince;
  final String? language;

  UserProfile({
    this.id,
    this.name,
    this.email,
    this.profileImageUrl,
    this.bio,
    this.studyFocus,
    this.educationLevel,
    this.interests,
    this.memberSince,
    this.language,
  });

// ... other methods ...
}