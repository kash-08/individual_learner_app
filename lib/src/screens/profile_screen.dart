// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _currentUserData;
  bool _isLoadingUser = true;
  Map<String, dynamic>? _userStats;
  int _totalCourses = 0;
  double _totalStudyTime = 0.0;
  double _progressPercentage = 0.0;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        Provider.of<ProfileProvider>(context, listen: false).loadUserProfile();
      } catch (e) {
        // Ignore if method doesn't exist
      }
    });
  }

  // ========== LOAD CURRENT USER DATA FROM FIREBASE ==========
  Future<void> _loadCurrentUserData() async {
    try {
      setState(() {
        _isLoadingUser = true;
      });

      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        // No user logged in
        setState(() {
          _isLoadingUser = false;
        });
        return;
      }

      print('Loading data for user: ${currentUser.uid}');
      print('Email: ${currentUser.email}');
      print('Display Name: ${currentUser.displayName}');

      // Get user data from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;

        // Debug print
        print('User data from Firestore: $userData');

        // Check for name field variations
        final userName = userData['name'] ??
            userData['fullName'] ??
            userData['username'] ??
            currentUser.displayName ??
            'User';

        // Check for email field variations
        final userEmail = currentUser.email ?? userData['email'] ?? '';

        // Create UserModel from Firestore data
        _currentUserData = UserModel(
          id: currentUser.uid,
          name: userName.toString(),
          email: userEmail.toString(),
          profileImageUrl: userData['profileImage'] ??
              userData['photoURL'] ??
              currentUser.photoURL,
          xpPoints: _parseInt(userData['xpPoints']),
          dayStreak: _parseInt(userData['dayStreak']),
          studyTimeThisWeek: _parseDouble(userData['studyTimeThisWeek']),
          enrolledCourses: List<String>.from(userData['enrolledCourses'] ?? []),
          completedQuizzes: List<String>.from(userData['completedQuizzes'] ?? []),
          createdAt: _parseTimestamp(userData['createdAt']),
          lastUpdated: _parseTimestamp(userData['lastUpdated']),
        );

        print('User created: ${_currentUserData!.name}');

        // Calculate user statistics
        _totalCourses = _currentUserData!.enrolledCourses.length;
        _totalStudyTime = _currentUserData!.studyTimeThisWeek;

        // Calculate progress (for demo, using XP points as progress indicator)
        _progressPercentage =
            (_currentUserData!.xpPoints / 2000).clamp(0.0, 1.0) * 100;

        // Get additional stats from Firestore if available
        await _loadUserStatistics(currentUser.uid);
      } else {
        // Create default user data if document doesn't exist
        print('User document not found, creating default');

        _currentUserData = UserModel(
          id: currentUser.uid,
          name: currentUser.displayName ?? 'User',
          email: currentUser.email ?? '',
          profileImageUrl: currentUser.photoURL,
          xpPoints: 245,
          dayStreak: 7,
          studyTimeThisWeek: 10.4,
          enrolledCourses: [],
          completedQuizzes: [],
          createdAt: DateTime.now(),
          lastUpdated: DateTime.now(),
        );

        _totalCourses = 0;
        _totalStudyTime = 0.0;
        _progressPercentage = 0.0;

        // Create the user document in Firestore
        await _createUserDocumentIfNotExists(currentUser, _currentUserData!);
      }
    } catch (e, stackTrace) {
      print('Error loading user data: $e');
      print('Stack trace: $stackTrace');

      // Fallback to Firebase Auth data
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        _currentUserData = UserModel(
          id: currentUser.uid,
          name: currentUser.displayName ?? 'User',
          email: currentUser.email ?? '',
          profileImageUrl: currentUser.photoURL,
          xpPoints: 245,
          dayStreak: 7,
          studyTimeThisWeek: 10.4,
          enrolledCourses: [],
          completedQuizzes: [],
          createdAt: DateTime.now(),
          lastUpdated: DateTime.now(),
        );
      }
    } finally {
      setState(() {
        _isLoadingUser = false;
      });
    }
  }

  // Helper method to create user document if it doesn't exist
  Future<void> _createUserDocumentIfNotExists(User user, UserModel userModel) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'name': userModel.name,
        'email': userModel.email,
        'profileImage': userModel.profileImageUrl,
        'xpPoints': userModel.xpPoints,
        'dayStreak': userModel.dayStreak,
        'studyTimeThisWeek': userModel.studyTimeThisWeek,
        'enrolledCourses': userModel.enrolledCourses,
        'completedQuizzes': userModel.completedQuizzes,
        'createdAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print('User document created in Firestore');
    } catch (e) {
      print('Error creating user document: $e');
    }
  }

  // Helper methods for parsing
  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  DateTime? _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return null;
    if (timestamp is Timestamp) return timestamp.toDate();
    if (timestamp is DateTime) return timestamp;
    return null;
  }

  // ========== LOAD USER STATISTICS ==========
  Future<void> _loadUserStatistics(String userId) async {
    try {
      // Query enrolled courses to get count
      final coursesSnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .where('enrolledUsers', arrayContains: userId)
          .get();

      _totalCourses = coursesSnapshot.docs.length;

      // Query study sessions to calculate total study time
      final sessionsSnapshot = await FirebaseFirestore.instance
          .collection('study_sessions')
          .where('userId', isEqualTo: userId)
          .get();

      double totalTime = 0.0;
      for (var doc in sessionsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        totalTime += (data['duration']?.toDouble() ?? 0.0);
      }
      _totalStudyTime = totalTime;

      // Calculate progress from completed lessons
      final completedLessonsSnapshot = await FirebaseFirestore.instance
          .collection('user_progress')
          .where('userId', isEqualTo: userId)
          .where('isCompleted', isEqualTo: true)
          .get();

      final totalLessonsSnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .get();

      int totalLessonsCount = 0;
      for (var course in totalLessonsSnapshot.docs) {
        final courseData = course.data() as Map<String, dynamic>;
        totalLessonsCount += _safeIntParse(courseData['totalLessons']);
      }

      if (totalLessonsCount > 0) {
        _progressPercentage =
        (completedLessonsSnapshot.docs.length / totalLessonsCount * 100);
      }

      setState(() {});
    } catch (e) {
      print('Error loading user statistics: $e');
    }
  }

  // ========== FORMAT DATE ==========
  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.year}/${date.month}/${date.day}';
  }

  // ========== GET USER STUDY FIELD ==========
  String _getUserStudyField() {
    // You can customize this based on user's enrolled courses
    if (_currentUserData?.enrolledCourses.isNotEmpty ?? false) {
      return 'Technology & Development';
    }
    return 'General Learning';
  }

  // ========== UPDATE DISPLAY NAME ==========
  Future<void> _updateDisplayName(String newName) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Update in Firebase Auth
        await user.updateDisplayName(newName);

        // Update in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'name': newName,
          'lastUpdated': FieldValue.serverTimestamp(),
        });

        // Reload data
        await _loadCurrentUserData();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Name updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update name: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingUser) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Profile & Analytics'),
        backgroundColor: const Color(0xFF4361EE),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              setState(() {
                _isLoadingUser = true;
              });
              await _loadCurrentUserData();
            },
            tooltip: 'Refresh Profile',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings')),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadCurrentUserData();
        },
        child: Consumer<ProfileProvider>(
          builder: (context, profileProvider, child) {
            // Try to check loading state safely
            bool isLoading = false;
            try {
              isLoading = profileProvider.isLoading == true;
            } catch (e) {
              isLoading = false;
            }

            if (isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return _buildProfileUI();
          },
        ),
      ),
    );
  }

  Widget _buildProfileUI() {
    if (_currentUserData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Unable to load profile',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please check your internet connection',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadCurrentUserData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4361EE),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final userName = _currentUserData!.name;
    final userEmail = _currentUserData!.email;
    final memberSince = _formatDate(_currentUserData!.createdAt);
    final dayStreak = _currentUserData!.dayStreak;
    final xpPoints = _currentUserData!.xpPoints;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile Header Card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFF4361EE),
                    backgroundImage: _currentUserData!.profileImageUrl != null
                        ? NetworkImage(_currentUserData!.profileImageUrl!)
                        : null,
                    child: _currentUserData!.profileImageUrl == null
                        ? const Icon(Icons.person, size: 40, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(height: 16),

                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),

                  Text(
                    userEmail,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    _getUserStudyField(),
                    style: const TextStyle(
                      color: Color(0xFF4361EE),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    'Passionate learner focused on expanding knowledge and skills. ${dayStreak > 0
                        ? 'Maintaining a $dayStreak-day streak!'
                        : 'Start your learning journey today!'}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _showEditProfileDialog(context);
                      },
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Edit Profile'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Member Information Card
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Member Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    icon: Icons.calendar_today,
                    label: 'Member Since',
                    value: memberSince,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    icon: Icons.star,
                    label: 'XP Points',
                    value: xpPoints.toString(),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    icon: Icons.local_fire_department,
                    label: 'Day Streak',
                    value: '$dayStreak days',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    icon: Icons.school,
                    label: 'Enrolled Courses',
                    value: _totalCourses.toString(),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Learning Analytics Card
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Learning Analytics',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _StatCircle(
                        value: _totalCourses.toString(),
                        label: 'Courses',
                        color: const Color(0xFF4361EE),
                      ),
                      _StatCircle(
                        value: '${_totalStudyTime.toStringAsFixed(1)}h',
                        label: 'Study Time',
                        color: const Color(0xFF4CC9F0),
                      ),
                      _StatCircle(
                        value: '${_progressPercentage.toStringAsFixed(0)}%',
                        label: 'Progress',
                        color: const Color(0xFF7209B7),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Quick Stats Card
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Learning Summary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildProgressBar('Course Completion', _progressPercentage),
                  const SizedBox(height: 12),
                  _buildProgressBar('Study Consistency', 75.0), // Example value
                  const SizedBox(height: 12),
                  _buildProgressBar('Quiz Performance', 85.0), // Example value
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Account Actions Card
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Account',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildActionTile(
                    icon: Icons.privacy_tip,
                    title: 'Privacy & Security',
                    onTap: () {
                      _showPrivacySecurity(context);
                    },
                  ),
                  _buildActionTile(
                    icon: Icons.settings,
                    title: 'Settings',
                    onTap: () {
                      _showSettings(context);
                    },
                  ),
                  _buildActionTile(
                    icon: Icons.help,
                    title: 'Help & Support',
                    onTap: () {
                      _showHelpSupport(context);
                    },
                  ),
                  _buildActionTile(
                    icon: Icons.text_snippet,
                    title: 'Terms & Policies',
                    onTap: () {
                      _showTermsPolicies(context);
                    },
                  ),
                  _buildActionTile(
                    icon: Icons.logout,
                    title: 'Log Out',
                    color: Colors.red,
                    onTap: () {
                      _showLogoutDialog(context);
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF4361EE), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(String label, double percentage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4361EE),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            Container(
              height: 6,
              width: percentage * 2.4, // 240px max for 100%
              decoration: BoxDecoration(
                color: const Color(0xFF4361EE),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    Color? color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: color ?? const Color(0xFF4361EE),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      minLeadingWidth: 0,
    );
  }

  // ========== EDIT PROFILE DIALOG ==========
  void _showEditProfileDialog(BuildContext context) {
    TextEditingController nameController = TextEditingController(text: _currentUserData?.name ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Display Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Other features coming soon:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('• Change profile picture'),
              const Text('• Modify study preferences'),
              const Text('• Set learning goals'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isNotEmpty &&
                  nameController.text != _currentUserData?.name) {
                await _updateDisplayName(nameController.text.trim());
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // ========== PRIVACY & SECURITY ==========
  void _showPrivacySecurity(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy & Security'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Your privacy is important to us:'),
              SizedBox(height: 10),
              Text('✓ Data is encrypted and secure'),
              Text('✓ We don\'t share your personal information'),
              Text('✓ You control your data'),
              Text('✓ Regular security updates'),
              SizedBox(height: 10),
              Text(
                'For more details, visit our Privacy Policy in Terms & Policies.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // ========== SETTINGS ==========
  void _showSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Settings'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('App Settings:'),
              SizedBox(height: 10),
              Text('• Notifications: ON'),
              Text('• Dark Mode: OFF'),
              Text('• Auto-play videos: OFF'),
              Text('• Download quality: Standard'),
              Text('• Study reminders: Daily'),
              SizedBox(height: 10),
              Text(
                'Full settings panel coming in next update.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // ========== HELP & SUPPORT ==========
  void _showHelpSupport(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Need help? Here are your options:'),
              SizedBox(height: 10),
              Text('📞 Contact Support: support@learnapp.com'),
              Text('📖 FAQ: app.learnapp.com/faq'),
              Text('🐛 Report Bug: app.learnapp.com/bug'),
              Text('💡 Feature Request: app.learnapp.com/request'),
              SizedBox(height: 10),
              Text(
                'We typically respond within 24 hours.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // ========== TERMS & POLICIES ==========
  void _showTermsPolicies(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms & Policies'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('By using this app, you agree to:'),
              SizedBox(height: 10),
              Text('• Use for educational purposes only'),
              Text('• Respect community guidelines'),
              Text('• Not share account credentials'),
              Text('• Complete work honestly'),
              SizedBox(height: 10),
              Text('Our policies:'),
              Text('• Privacy Policy'),
              Text('• Terms of Service'),
              Text('• Community Guidelines'),
              Text('• Refund Policy'),
              SizedBox(height: 10),
              Text(
                'Full documents available at app.learnapp.com/legal',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // ========== UPDATED LOGOUT DIALOG ==========
  Future<void> _showLogoutDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );

              try {
                final authProvider = Provider.of<AuthProvider>(
                  context,
                  listen: false,
                );

                await authProvider.signOut();

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Logged out successfully'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                      (route) => false,
                );
              } catch (e) {
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Logout failed: $e'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  // Helper method for parsing integers
  int _safeIntParse(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      try {
        return int.tryParse(value) ?? 0;
      } catch (e) {
        return 0;
      }
    }
    return 0;
  }
}

class _StatCircle extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatCircle({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

// ========== USER MODEL CLASS ==========
class UserModel {
  final String id;
  final String name;
  final String email;
  final String? profileImageUrl;
  final int xpPoints;
  final int dayStreak;
  final double studyTimeThisWeek;
  final List<String> enrolledCourses;
  final List<String> completedQuizzes;
  final DateTime? createdAt;
  final DateTime? lastUpdated;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.profileImageUrl,
    required this.xpPoints,
    required this.dayStreak,
    required this.studyTimeThisWeek,
    required this.enrolledCourses,
    required this.completedQuizzes,
    this.createdAt,
    this.lastUpdated,
  });
}