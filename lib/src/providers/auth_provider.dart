// lib/providers/auth_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? _user;
  bool _isLoading = false;
  String? _error;
  String? _successMessage;

  // Getter for user - BOTH are now available
  User? get user => _user;
  User? get currentUser => _user; // Add this line
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get successMessage => _successMessage;

  AuthProvider() {
    // Listen to auth state changes
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }


  // ========== EMAIL/PASSWORD SIGN IN ==========
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _error = null;
    _successMessage = null;

    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Check if email is verified (optional)
      // if (!_auth.currentUser!.emailVerified) {
      //   await _auth.signOut();
      //   throw FirebaseAuthException(
      //     code: 'email-not-verified',
      //     message: 'Please verify your email first',
      //   );
      // }

    } on FirebaseAuthException catch (e) {
      _error = _getErrorMessage(e.code);
      notifyListeners();
      rethrow;
    } catch (e) {
      _error = 'An error occurred: $e';
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  // ========== UPDATE USER ==========
  void updateUser(User? user) {
    _user = user;
    notifyListeners();
  }

  // ========== EMAIL/PASSWORD SIGN UP ==========
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    bool requireEmailVerification = false, // Set to true if you want email verification
  }) async {
    _setLoading(true);
    _error = null;
    _successMessage = null;

    try {
      // 1. Create user account
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // 2. Update display name in Firebase Auth
      await userCredential.user!.updateDisplayName(name);

      // 3. Create user document in Firestore
      await _createUserDocument(
        userCredential.user!,
        name: name,
        email: email,
      );

      if (requireEmailVerification) {
        // 4. Send verification email
        await userCredential.user!.sendEmailVerification();

        // 5. Sign out so user needs to verify email first
        await _auth.signOut();

        _successMessage = 'Registration successful! Please check your email to verify your account before logging in.';
      } else {
        // If not requiring verification, keep user signed in
        _successMessage = 'Registration successful! Welcome to the app.';
      }

    } on FirebaseAuthException catch (e) {
      // If there's an error, clean up any partial user creation
      try {
        if (_auth.currentUser != null &&
            await _auth.currentUser!.getIdToken() != null) {
          await _auth.currentUser!.delete();
        }
      } catch (deleteError) {
        print('Error cleaning up user: $deleteError');
      }

      _error = _getErrorMessage(e.code);
      notifyListeners();
      rethrow;
    } catch (e) {
      _error = 'An error occurred during registration: $e';
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // ========== GOOGLE SIGN IN ==========
  Future<void> signInWithGoogle() async {
    _setLoading(true);
    _error = null;
    _successMessage = null;

    try {
      // 1. Trigger Google Sign In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        _setLoading(false);
        return;
      }

      // 2. Get authentication details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 3. Create Firebase credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Sign in to Firebase with Google credential
      UserCredential userCredential = await _auth.signInWithCredential(credential);

      // 5. Check if new user and create document if needed
      if (userCredential.additionalUserInfo?.isNewUser == true) {
        await _createUserDocument(
          userCredential.user!,
          name: userCredential.user!.displayName ?? 'User',
          email: userCredential.user!.email ?? '',
          profileImage: userCredential.user!.photoURL,
        );
        _successMessage = 'Welcome to the app!';
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

  // ========== PASSWORD RESET ==========
  Future<void> resetPassword(String email) async {
    _setLoading(true);
    _error = null;
    _successMessage = null;

    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      _successMessage = 'Password reset email sent! Check your inbox.';
    } on FirebaseAuthException catch (e) {
      _error = _getErrorMessage(e.code);
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // ========== SIGN OUT ==========
  Future<void> signOut() async {
    try {
      // Sign out from Google if signed in with Google
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      // Sign out from Firebase
      await _auth.signOut();

      _successMessage = 'Signed out successfully';
    } catch (e) {
      _error = 'Error signing out: $e';
      notifyListeners();
      rethrow;
    }
  }

  // ========== CREATE USER DOCUMENT ==========
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
        'accountType': 'student', // or 'teacher' based on your logic
      }, SetOptions(merge: true)); // Use merge to avoid overwriting existing data
    } catch (e) {
      print('Error creating user document: $e');
      // Don't throw here - auth succeeded even if document creation fails
    }
  }

  // ========== GET USER DATA ==========
  Future<Map<String, dynamic>?> getUserData() async {
    if (_user == null) return null;

    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(_user!.uid).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }

  // ========== UPDATE PROFILE ==========
  Future<void> updateProfile({
    required String name,
    String? profileImageUrl,
  }) async {
    if (_user == null) return;

    _setLoading(true);
    _error = null;

    try {
      await _firestore.collection('users').doc(_user!.uid).update({
        'name': name,
        if (profileImageUrl != null) 'profileImage': profileImageUrl,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      // Update display name in Firebase Auth
      await _user!.updateDisplayName(name);

      _successMessage = 'Profile updated successfully';

    } catch (e) {
      _error = 'Failed to update profile: $e';
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // ========== SEND EMAIL VERIFICATION ==========
  Future<void> sendEmailVerification() async {
    if (_user == null) return;

    try {
      await _user!.sendEmailVerification();
      _successMessage = 'Verification email sent! Please check your inbox.';
      notifyListeners();
    } catch (e) {
      _error = 'Failed to send verification email: $e';
      notifyListeners();
    }
  }

  // ========== CHECK EMAIL VERIFICATION ==========
  Future<bool> checkEmailVerified() async {
    if (_user == null) return false;

    // Reload user to get latest email verification status
    await _user!.reload();
    _user = _auth.currentUser;

    return _user?.emailVerified ?? false;
  }

  // ========== DELETE ACCOUNT ==========
  Future<void> deleteAccount() async {
    if (_user == null) return;

    _setLoading(true);
    _error = null;

    try {
      // Delete from Firestore
      await _firestore.collection('users').doc(_user!.uid).delete();

      // Delete from Firebase Auth
      await _user!.delete();

      _successMessage = 'Account deleted successfully';

    } catch (e) {
      _error = 'Failed to delete account: $e';
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // ========== HELPER METHODS ==========
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearSuccessMessage() {
    _successMessage = null;
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
      case 'account-exists-with-different-credential':
        return 'Account already exists with different sign-in method';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled';
      case 'email-not-verified':
        return 'Please verify your email first';
      default:
        return 'Authentication failed. Error: $code';
    }
  }
}