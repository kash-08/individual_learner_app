// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:individual_learner_app/src/providers/auth_provider.dart';
import 'package:individual_learner_app/src/providers/achievement_provider.dart';
import 'package:individual_learner_app/src/providers/exam_provider.dart';
import 'package:individual_learner_app/src/screens/home_screen.dart';
import 'package:individual_learner_app/src/screens/login_screen.dart';
import 'package:individual_learner_app/src/providers/course_provider.dart';
import 'package:individual_learner_app/src/providers/updates_provider.dart';
import 'package:individual_learner_app/src/services/session_service.dart';
import 'package:individual_learner_app/src/firebase/firebase_options.dart';
import 'package:individual_learner_app/src/services/firebase_service.dart';
import 'package:individual_learner_app/src/services/assesment_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with platform-specific options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ✅ Initialize Firebase sample data (courses, weekly updates)
  await FirebaseService.initializeSampleData();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Authentication Provider - ADD THIS FIRST
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        // Course Management
        ChangeNotifierProvider(create: (_) => CourseProvider()),

        // Weekly Updates
        ChangeNotifierProvider(create: (_) => UpdatesProvider()),

        // Achievements
        ChangeNotifierProvider(create: (context) => AchievementProvider()),

        // Quiz/Exam Management
        ChangeNotifierProvider(create: (_) => ExamProvider()),

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
          useMaterial3: false,
        ),
        // Changed from const HomeScreen() to AuthWrapper
        home: const AuthWrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

// NEW: Authentication Wrapper Widget
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Show loading screen while checking auth state
    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Redirect based on auth state
    return authProvider.user != null ? const HomeScreen() : const LoginScreen();
  }
}