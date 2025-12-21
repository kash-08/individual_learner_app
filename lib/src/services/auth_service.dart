import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // 1. Email/Password Sign Up
  Future<User?> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document in Firestore
      await _createUserDocument(userCredential.user!, name: name, email: email);

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseException(e);
    } catch (e) {
      throw AuthException(message: 'An unexpected error occurred');
    }
  }

  // 2. Email/Password Sign In
  Future<User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseException(e);
    }
  }

  // 3. Google Sign In
  Future<User?> signInWithGoogle() async {
    try {
      // Trigger Google Sign In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      // Get authentication details
      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      // Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      UserCredential userCredential = await _auth.signInWithCredential(credential);

      // Check if user document exists, if not create one
      if (userCredential.additionalUserInfo!.isNewUser) {
        await _createUserDocument(
          userCredential.user!,
          name: userCredential.user!.displayName ?? 'User',
          email: userCredential.user!.email ?? '',
          profileImage: userCredential.user!.photoURL,
        );
      }

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseException(e);
    } catch (e) {
      throw AuthException(message: 'Failed to sign in with Google');
    }
  }

  // 4. Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  // 5. Password Reset
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseException(e);
    }
  }

  // 6. Create User Document in Firestore
  Future<void> _createUserDocument(
      User user, {
        required String name,
        required String email,
        String? profileImage,
      }) async {
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
    }, SetOptions(merge: true));
  }

  // 7. Update User Profile
  Future<void> updateProfile({
    String? name,
    String? profileImage,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw AuthException(message: 'No user logged in');

      // Update in Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'name': name,
        'profileImage': profileImage,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      // Update in Firebase Auth (for display name)
      if (name != null) {
        await user.updateDisplayName(name);
      }
    } catch (e) {
      throw AuthException(message: 'Failed to update profile');
    }
  }

  // 8. Delete Account
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw AuthException(message: 'No user logged in');

      // Delete from Firestore
      await _firestore.collection('users').doc(user.uid).delete();

      // Delete from Firebase Auth
      await user.delete();
    } catch (e) {
      throw AuthException(message: 'Failed to delete account');
    }
  }
}

// Custom Exception Class
class AuthException implements Exception {
  final String message;
  final String? code;

  AuthException({required this.message, this.code});

  factory AuthException.fromFirebaseException(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return AuthException(
          message: 'This email is already registered',
          code: e.code,
        );
      case 'invalid-email':
        return AuthException(message: 'Invalid email address', code: e.code);
      case 'operation-not-allowed':
        return AuthException(
          message: 'Email/password accounts are not enabled',
          code: e.code,
        );
      case 'weak-password':
        return AuthException(
          message: 'Password is too weak',
          code: e.code,
        );
      case 'user-disabled':
        return AuthException(message: 'This account has been disabled', code: e.code);
      case 'user-not-found':
        return AuthException(message: 'No account found with this email', code: e.code);
      case 'wrong-password':
        return AuthException(message: 'Incorrect password', code: e.code);
      case 'too-many-requests':
        return AuthException(
          message: 'Too many failed attempts. Try again later',
          code: e.code,
        );
      default:
        return AuthException(message: e.message ?? 'Authentication failed', code: e.code);
    }
  }

  @override
  String toString() => 'AuthException: $message';
}