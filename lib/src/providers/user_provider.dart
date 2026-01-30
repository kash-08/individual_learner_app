import 'package:flutter/foundation.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String? profileImageUrl;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profileImageUrl,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      profileImageUrl: map['profileImageUrl'],
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
    );
  }
}

class UserProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  Future<void> initialize(User authUser) async {
    _isLoading = true;
    notifyListeners();

    try {
      // You can fetch additional user data from Firestore here
      // For now, we'll create a basic user from auth data
      _currentUser = User(
        id: authUser.id,
        name: authUser.name,
        email: authUser.email,
        profileImageUrl: authUser.profileImageUrl,
        createdAt: DateTime.now(),
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing UserProvider: $e');
      }
      _currentUser = User(
        id: authUser.id,
        name: authUser.name,
        email: authUser.email,
        profileImageUrl: null,
        createdAt: DateTime.now(),
      );
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUserProfile({
    String? name,
    String? email,
    String? profileImageUrl,
  }) async {
    if (_currentUser == null) return;

    final updatedUser = User(
      id: _currentUser!.id,
      name: name ?? _currentUser!.name,
      email: email ?? _currentUser!.email,
      profileImageUrl: profileImageUrl ?? _currentUser!.profileImageUrl,
      createdAt: _currentUser!.createdAt,
    );

    _currentUser = updatedUser;
    notifyListeners();
  }

  void clearUser() {
    _currentUser = null;
    notifyListeners();
  }
}