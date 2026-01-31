// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:individual_learner_app/src/models/exam_model.dart';
import 'package:individual_learner_app/src/models/profile_model.dart';
import 'package:individual_learner_app/src/models/settings_model.dart';
import 'package:individual_learner_app/src/providers/profile_provider.dart';
import 'package:individual_learner_app/src/providers/user_provider.dart';
import 'package:individual_learner_app/src/screens/result_details_screen.dart';
import 'package:individual_learner_app/src/services/ai_short_answer_service.dart';
import 'package:provider/provider.dart';
import 'package:individual_learner_app/src/providers/auth_provider.dart';
import 'package:individual_learner_app/src/providers/achievement_provider.dart';
import 'package:individual_learner_app/src/providers/exam_provider.dart';
import 'package:individual_learner_app/src/screens/home_screen.dart';
import 'package:individual_learner_app/src/screens/login_screen.dart';
import 'package:individual_learner_app/src/screens/main_screen.dart';
import 'package:individual_learner_app/src/providers/course_provider.dart';
import 'package:individual_learner_app/src/providers/updates_provider.dart';
import 'package:individual_learner_app/src/providers/timetable_provider.dart';
import 'package:individual_learner_app/src/services/session_service.dart';
import 'package:individual_learner_app/src/firebase/firebase_options.dart';
import 'package:individual_learner_app/src/services/firebase_service.dart';
import 'package:individual_learner_app/src/services/assesment_service.dart';

// Import AI Assistant
import 'package:individual_learner_app/src/providers/ai_assistant_provider.dart';
import 'package:individual_learner_app/src/screens/ai_assistant_screen.dart';

// Import Smart Timetable Screen
import 'package:individual_learner_app/src/screens/smart_timetable_screen.dart';

// Import AI Short Answer
import 'package:individual_learner_app/src/providers/short_answer_provider.dart';
import 'package:individual_learner_app/src/screens/ai_short_answer_screen.dart';

// Import Profile Screen
import 'package:individual_learner_app/src/screens/profile_screen.dart';

// Import Challenges & Exams Screen
import 'package:individual_learner_app/src/screens/challenges_exams_screen.dart';
import 'package:individual_learner_app/src/screens/take_assesment_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI colors
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Color(0xFF4361EE),
    statusBarBrightness: Brightness.light,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Firebase sample data
  await FirebaseService.initializeSampleData();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Authentication Provider
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        // User Provider (for user data access)
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
          lazy: false,
        ),

        // AI Assistant Provider
        ChangeNotifierProvider(
          create: (_) => AIAssistantProvider(),
          lazy: false,
        ),

        // AI Short Answer Provider
        ChangeNotifierProvider(
          create: (_) => ShortAnswerProvider(),
          lazy: false,
        ),

        // Course Management
        ChangeNotifierProvider(create: (_) => CourseProvider()),

        // Weekly Updates
        ChangeNotifierProvider(create: (_) => UpdatesProvider()),

        // Smart Timetable Provider
        ChangeNotifierProvider(
          create: (_) => TimetableProvider(),
          lazy: false,
        ),

        // Achievements
        ChangeNotifierProvider(create: (context) => AchievementProvider()),

        // Quiz/Exam Management
        ChangeNotifierProvider(create: (_) => ExamProvider()),

        // Profile Provider
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(),
          lazy: false,
        ),

        // Services
        Provider<SessionService>(create: (_) => SessionService()),
        Provider<AssessmentService>(create: (_) => AssessmentService()),
      ],
      child: MaterialApp(
        title: 'AI Learning App',
        theme: ThemeData(
          primaryColor: const Color(0xFF4361EE),
          scaffoldBackgroundColor: const Color(0xFFF8F9FA),
          textTheme: const TextTheme(
            headlineLarge: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212529),
            ),
            headlineMedium: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212529),
            ),
            headlineSmall: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF212529),
            ),
            bodyLarge: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: Color(0xFF212529),
            ),
            bodyMedium: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: Color(0xFF6C757D),
            ),
            bodySmall: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: Color(0xFF6C757D),
            ),
          ),
          cardTheme: const CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF4361EE),
            elevation: 4,
            iconTheme: IconThemeData(color: Colors.white),
            titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4361EE),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF4361EE),
              side: const BorderSide(color: Color(0xFF4361EE)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Colors.white,
            selectedItemColor: Color(0xFF4361EE),
            unselectedItemColor: Color(0xFF6C757D),
            selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            unselectedLabelStyle: TextStyle(fontSize: 12),
            elevation: 8,
            type: BottomNavigationBarType.fixed,
            showSelectedLabels: true,
            showUnselectedLabels: true,
          ),
          useMaterial3: false,
        ),
        home: const AuthWrapper(),
        debugShowCheckedModeBanner: false,
        routes: {
          '/ai-assistant': (context) => const AIAssistantScreen(),
          '/smart-timetable': (context) => const SmartTimetableScreen(),
          '/ai-short-answer': (context) => const AIShortAnswerScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/challenges': (context) => const ChallengesExamsScreen(),
          // ResultDetailsScreen is created with parameters, not in routes
        },
      ),
    );
  }
}

// Authentication Wrapper Widget
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _aiInitialized = false;
  bool _timetableInitialized = false;
  bool _shortAnswerInitialized = false;
  bool _profileInitialized = false;
  bool _userProviderInitialized = false;
  bool _examProviderInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeProviders();
  }

  Future<void> _initializeProviders() async {
    try {
      // Initialize providers when user is authenticated
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user != null) {
        // Initialize User Provider (sets current user)
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.initialize(authProvider.user! as User);

        // Initialize Exam Provider
        final examProvider = Provider.of<ExamProvider>(context, listen: false);
        await examProvider.loadUserResults();

        // Initialize AI Assistant
        final aiProvider = Provider.of<AIAssistantProvider>(context, listen: false);
        await aiProvider.initialize();

        // Initialize Timetable
        final timetableProvider = Provider.of<TimetableProvider>(context, listen: false);
        await timetableProvider.loadTimetableSlots();

        // Initialize Profile Provider
        final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
        await profileProvider.loadUserProfile();

        // Initialize AI Short Answer Provider
        final shortAnswerProvider = Provider.of<ShortAnswerProvider>(context, listen: false);
        print('AI Short Answer Provider initialized');
      }

      setState(() {
        _userProviderInitialized = true;
        _examProviderInitialized = true;
        _aiInitialized = true;
        _timetableInitialized = true;
        _shortAnswerInitialized = true;
        _profileInitialized = true;
      });
    } catch (e) {
      print('Provider initialization error: $e');
      setState(() {
        _userProviderInitialized = true;
        _examProviderInitialized = true;
        _aiInitialized = true;
        _timetableInitialized = true;
        _shortAnswerInitialized = true;
        _profileInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Show loading screen while checking auth state or initializing providers
    if (authProvider.isLoading ||
        !_userProviderInitialized ||
        !_examProviderInitialized ||
        !_aiInitialized ||
        !_timetableInitialized ||
        !_shortAnswerInitialized ||
        !_profileInitialized) {
      return _buildLoadingScreen();
    }

    // Redirect based on auth state
    return authProvider.user != null ? const MainScreen() : const LoginScreen();
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF4361EE),
      body: Container(
        color: const Color(0xFF4361EE),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(
                          Icons.smart_toy,
                          color: Color(0xFF4361EE),
                          size: 40,
                        ),
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.schedule,
                              color: Colors.white,
                              size: 12,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 2,
                          right: 2,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.teal,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(
                              Icons.question_answer,
                              color: Colors.white,
                              size: 10,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 2,
                          left: 2,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.purple,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 10,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 2,
                          left: 2,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(
                              Icons.quiz,
                              color: Colors.white,
                              size: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              const Text(
                'AI Learning App',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 15),
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  if (authProvider.isLoading) {
                    return const Text(
                      'Checking authentication...',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    );
                  } else if (!_userProviderInitialized) {
                    return const Text(
                      'Initializing user data...',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    );
                  } else if (!_examProviderInitialized) {
                    return const Text(
                      'Loading your quiz results...',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    );
                  } else if (!_aiInitialized) {
                    return const Text(
                      'Initializing AI Assistant...',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    );
                  } else if (!_timetableInitialized) {
                    return const Text(
                      'Loading your timetable...',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    );
                  } else if (!_shortAnswerInitialized) {
                    return const Text(
                      'Initializing AI Short Answer...',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    );
                  } else if (!_profileInitialized) {
                    return const Text(
                      'Loading your profile...',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 30),
              _buildLoadingDots(),
              const SizedBox(height: 20),
              _buildFeatureHighlights(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildDot(0),
        const SizedBox(width: 10),
        _buildDot(1),
        const SizedBox(width: 10),
        _buildDot(2),
      ],
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: (DateTime.now().millisecondsSinceEpoch ~/ 400 % 3 == index)
            ? Colors.white
            : Colors.white.withOpacity(0.3),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildFeatureHighlights() {
    return Column(
      children: [
        _buildFeatureItem(
          icon: Icons.person,
          text: 'User Profile & Data',
        ),
        const SizedBox(height: 12),
        _buildFeatureItem(
          icon: Icons.quiz,
          text: 'Quizzes & Assessments',
        ),
        const SizedBox(height: 12),
        _buildFeatureItem(
          icon: Icons.question_answer,
          text: 'AI Short Answers',
        ),
        const SizedBox(height: 12),
        _buildFeatureItem(
          icon: Icons.auto_awesome,
          text: 'AI-Powered Learning',
        ),
        const SizedBox(height: 12),
        _buildFeatureItem(
          icon: Icons.schedule,
          text: 'Smart Timetable',
        ),
        const SizedBox(height: 12),
        _buildFeatureItem(
          icon: Icons.analytics,
          text: 'Progress Analytics',
        ),
      ],
    );
  }

  Widget _buildFeatureItem({required IconData icon, required String text}) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: 0.8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Colors.white70,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// Global error handler for AI
class AIErrorHandler {
  static void handleError(BuildContext context, String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'AI Assistant: $error',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

// Global AI shortcut helper
class AIHelper {
  static void navigateToAssistant(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AIAssistantScreen(),
      ),
    );
  }

  static Future<String> quickAnswer(BuildContext context, String question) async {
    final aiProvider = Provider.of<AIAssistantProvider>(context, listen: false);
    try {
      await aiProvider.sendMessage(question);
      await Future.delayed(const Duration(seconds: 1));
      final messages = aiProvider.messages;
      if (messages.isNotEmpty && messages.last.isAI) {
        return messages.last.text;
      }
      return "I'm processing your question...";
    } catch (e) {
      return "Sorry, I couldn't process that right now.";
    }
  }
}

// User Provider Model
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

// Updated UserProvider class
class UserProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  // Updated initialize method to accept dynamic auth user
  Future<void> initialize(dynamic authUser) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Handle different auth user types
      if (authUser is Map<String, dynamic>) {
        _currentUser = User(
          id: authUser['uid'] ?? authUser['id'] ?? '',
          name: authUser['displayName'] ?? authUser['name'] ?? 'User',
          email: authUser['email'] ?? '',
          profileImageUrl: authUser['photoURL'] ?? authUser['profileImageUrl'],
          createdAt: DateTime.now(),
        );
      } else if (authUser is User) {
        _currentUser = authUser;
      } else {
        // Fallback for unknown types
        _currentUser = User(
          id: 'unknown_id',
          name: 'User',
          email: '',
          createdAt: DateTime.now(),
        );
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error initializing UserProvider: $e');
      _currentUser = User(
        id: 'error_id',
        name: 'User',
        email: '',
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

  // Helper method to get user data for ResultDetailsScreen
  Map<String, String> getUserData() {
    return {
      'name': _currentUser?.name ?? 'Learner',
      'email': _currentUser?.email ?? '',
    };
  }
}

// Updated ProfileHelper for ResultDetailsScreen
class ProfileHelper {
  static String getUserName(BuildContext context) {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      return userProvider.currentUser?.name ?? 'Learner';
    } catch (e) {
      return 'Learner';
    }
  }

  static String getUserEmail(BuildContext context) {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      return userProvider.currentUser?.email ?? '';
    } catch (e) {
      return '';
    }
  }

  static void navigateToProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfileScreen(),
      ),
    );
  }

  static Future<void> updateUserProfile(BuildContext context, {
    String? name,
    String? bio,
    String? studyFocus,
    String? educationLevel,
    String? preferredLanguage,
    List<String>? interests,
  }) async {
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    try {
      await profileProvider.updateProfile(
        name: name,
        bio: bio,
        studyFocus: studyFocus,
        educationLevel: educationLevel,
        preferredLanguage: preferredLanguage,
        interests: interests,
      );

      if (name != null) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.updateUserProfile(name: name);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  static Future<void> updateUserSettings(BuildContext context, AppSettings settings) async {
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    try {
      await profileProvider.updateSettings(settings);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings updated successfully'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update settings: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}

// Global AI Short Answer helper
class AIShortAnswerHelper {
  static void navigateToShortAnswer(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AIShortAnswerScreen(),
      ),
    );
  }
}

// Global Timetable helper
class TimetableHelper {
  static void navigateToTimetable(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SmartTimetableScreen(),
      ),
    );
  }
}

// UPDATED: Global Quiz/Exam Helper with proper navigation
class QuizHelper {
  static void navigateToChallenges(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ChallengesExamsScreen(),
      ),
    );
  }

  static void navigateToTakeAssessment(
      BuildContext context, {
        required String quizId,
        required String quizName,
        required String quizType,
        required bool isDemo,
        String difficulty = 'Beginner',
        int? totalDuration,
        int? totalQuestions,
        int? totalPoints,
      }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TakeAssessmentScreen(
          quizId: quizId,
          quizName: quizName,
          quizType: quizType,
          isDemo: isDemo,
          difficulty: difficulty,
          totalDuration: totalDuration,
          totalQuestions: totalQuestions,
          totalPoints: totalPoints,
        ),
      ),
    );
  }

  // UPDATED: Fixed navigation to ResultDetailsScreen
  static void navigateToResultDetails(BuildContext context, QuizResult result) {
    // Get user data before navigation
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userName = userProvider.currentUser?.name ?? 'Learner';
    final userEmail = userProvider.currentUser?.email ?? '';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultDetailsScreen(
          result: result,
          userName: userName,
          userEmail: userEmail,
        ),
      ),
    );
  }

  // Alternative method using Provider wrapper
  static void navigateToResultDetailsWithProvider(BuildContext context, QuizResult result) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Provider<UserProvider>.value(
          value: Provider.of<UserProvider>(context, listen: false),
          child: ResultDetailsScreen(
            result: result,
            userName: '', // Will be fetched from provider in the screen
            userEmail: '',
          ),
        ),
      ),
    );
  }
}