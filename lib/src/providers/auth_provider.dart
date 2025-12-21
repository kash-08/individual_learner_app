// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AuthProvider() {
    // Listen to auth state changes
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  // Email/Password Sign In
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      _error = _getErrorMessage(e.code);
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Email/Password Sign Up
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Create user document in Firestore
      await _createUserDocument(
        userCredential.user!,
        name: name,
        email: email,
      );

    } on FirebaseAuthException catch (e) {
      _error = _getErrorMessage(e.code);
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // ADD THIS: Google Sign-In Method
  Future<void> signInWithGoogle() async {
    _setLoading(true);
    _error = null;

    try {
      // Create GoogleAuthProvider
      GoogleAuthProvider googleProvider = GoogleAuthProvider();

      // Sign in with Google
      UserCredential userCredential = await _auth.signInWithPopup(googleProvider);

      // Check if new user
      if (userCredential.additionalUserInfo?.isNewUser == true) {
        await _createUserDocument(
          userCredential.user!,
          name: userCredential.user!.displayName ?? 'User',
          email: userCredential.user!.email ?? '',
          profileImage: userCredential.user!.photoURL,
        );
      }

    } on FirebaseAuthException catch (e) {
      _error = _getErrorMessage(e.code);
      notifyListeners();
      rethrow;
    } catch (e) {
      _error = 'Failed to sign in with Google: $e';
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Password Reset
  Future<void> resetPassword(String email) async {
    _setLoading(true);
    _error = null;

    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      _error = _getErrorMessage(e.code);
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Create User Document in Firestore
  Future<void> _createUserDocument(
      User user, {
        required String name,
        required String email,
        String? profileImage,
      }) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': name,
        'email': email,
        'profileImage': profileImage,
        'createdAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
        'dayStreak': 0,
        'studyTimeThisWeek': 0.0,
        'xpPoints': 0,
        'enrolledCourses': [],
        'completedQuizzes': [],
        'isEmailVerified': user.emailVerified,
      });
    } catch (e) {
      print('Error creating user document: $e');
      // Don't throw here - auth succeeded even if document creation fails
    }
  }

  // Get User Data from Firestore
  Future<Map<String, dynamic>?> getUserData() async {
    if (_user == null) return null;

    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(_user!.uid).get();
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }

  // Update User Profile
  Future<void> updateProfile({
    required String name,
    String? profileImageUrl,
  }) async {
    if (_user == null) return;

    _setLoading(true);

    try {
      await _firestore.collection('users').doc(_user!.uid).update({
        'name': name,
        if (profileImageUrl != null) 'profileImage': profileImageUrl,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      // Update display name in Firebase Auth
      await _user!.updateDisplayName(name);

    } catch (e) {
      _error = 'Failed to update profile';
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Helper Methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered';
      case 'invalid-email':
        return 'Invalid email address';
      case 'weak-password':
        return 'Password is too weak (min. 6 characters)';
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'too-many-requests':
        return 'Too many failed attempts. Try again later';
      case 'network-request-failed':
        return 'Network error. Check your connection';
      case 'popup-blocked-by-browser':
        return 'Popup blocked. Please allow popups for Google sign-in';
      case 'cancelled-popup-request':
        return 'Google sign-in cancelled';
      default:
        return 'Authentication failed. Error code: $code';
    }
  }
}