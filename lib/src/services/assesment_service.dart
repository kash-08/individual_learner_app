import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/assesment_model.dart';
import '../models/result_model.dart';

class AssessmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all assessments by type
  Stream<List<Assessment>> getAssessmentsByType(AssessmentType type) {
    return _firestore
        .collection('assessments')
        .where('type', isEqualTo: type.toString().split('.').last)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Assessment.fromFirestore(doc))
        .toList());
  }

  // Get single assessment by ID
  Future<Assessment?> getAssessmentById(String assessmentId) async {
    try {
      DocumentSnapshot doc =
      await _firestore.collection('assessments').doc(assessmentId).get();
      if (doc.exists) {
        return Assessment.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting assessment: $e');
      return null;
    }
  }

  // Save assessment result
  Future<String?> saveAssessmentResult(AssessmentResult result) async {
    try {
      DocumentReference docRef =
      await _firestore.collection('results').add(result.toMap());

      // Update user progress
      await _updateUserProgress(result);

      return docRef.id;
    } catch (e) {
      print('Error saving result: $e');
      return null;
    }
  }

  // Get user's assessment results
  Stream<List<AssessmentResult>> getUserResults(String userId) {
    return _firestore
        .collection('results')
        .where('userId', isEqualTo: userId)
        .orderBy('completedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => AssessmentResult.fromFirestore(doc))
        .toList());
  }

  // Get user statistics
  Future<Map<String, dynamic>> getUserStatistics(String userId) async {
    try {
      QuerySnapshot resultsSnapshot = await _firestore
          .collection('results')
          .where('userId', isEqualTo: userId)
          .get();

      List<AssessmentResult> results = resultsSnapshot.docs
          .map((doc) => AssessmentResult.fromFirestore(doc))
          .toList();

      int totalExams = results.length;
      int passedExams = results.where((r) => r.passed).length;
      int failedExams = totalExams - passedExams;
      double avgScore = totalExams > 0
          ? results.map((r) => r.scorePercentage).reduce((a, b) => a + b) /
          totalExams
          : 0.0;

      // Count challenges (coding challenges)
      int totalChallenges = results
          .where((r) => r.assessmentType == 'challenge')
          .length;

      return {
        'totalExams': totalExams,
        'passedExams': passedExams,
        'failedExams': failedExams,
        'avgScore': avgScore,
        'totalChallenges': totalChallenges,
      };
    } catch (e) {
      print('Error getting statistics: $e');
      return {
        'totalExams': 0,
        'passedExams': 0,
        'failedExams': 0,
        'avgScore': 0.0,
        'totalChallenges': 0,
      };
    }
  }

  // Update user progress after completing assessment
  Future<void> _updateUserProgress(AssessmentResult result) async {
    try {
      DocumentReference userProgressRef =
      _firestore.collection('userProgress').doc(result.userId);

      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(userProgressRef);

        if (!snapshot.exists) {
          // Create new user progress document
          transaction.set(userProgressRef, {
            'userId': result.userId,
            'totalXP': result.earnedPoints,
            'assessmentsCompleted': 1,
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        } else {
          // Update existing user progress
          Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
          int currentXP = data['totalXP'] ?? 0;
          int currentAssessments = data['assessmentsCompleted'] ?? 0;

          transaction.update(userProgressRef, {
            'totalXP': currentXP + result.earnedPoints,
            'assessmentsCompleted': currentAssessments + 1,
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (e) {
      print('Error updating user progress: $e');
    }
  }

  // Check if user has already attempted an assessment
  Future<bool> hasUserAttempted(String userId, String assessmentId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('results')
          .where('userId', isEqualTo: userId)
          .where('assessmentId', isEqualTo: assessmentId)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking attempt: $e');
      return false;
    }
  }

  // Get user's best result for an assessment
  Future<AssessmentResult?> getUserBestResult(
      String userId, String assessmentId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('results')
          .where('userId', isEqualTo: userId)
          .where('assessmentId', isEqualTo: assessmentId)
          .orderBy('scorePercentage', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return AssessmentResult.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      print('Error getting best result: $e');
      return null;
    }
  }
}
