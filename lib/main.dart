// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:individual_learner_app/src/providers/achievement_provider.dart';
import 'package:provider/provider.dart';
import 'package:individual_learner_app/src/screens/home_screen.dart';
import 'package:individual_learner_app/src/providers/course_provider.dart';
import 'package:individual_learner_app/src/providers/updates_provider.dart';
import 'package:individual_learner_app/src/services/session_service.dart';
import 'package:individual_learner_app/src/firebase/firebase_options.dart';
import 'package:individual_learner_app/src/services/assesment_service.dart';
import 'package:individual_learner_app/src/services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with platform-specific options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ✅ NEW: Initialize all sample data from JSON file
  // This will create assessments, courses, exams, and weekly updates
  // Only runs once - prevents duplicates by checking if data already exists
  await FirebaseService.initializeSampleData();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CourseProvider()),
        ChangeNotifierProvider(create: (_) => UpdatesProvider()),
        ChangeNotifierProvider(create: (context) => AchievementProvider()),
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
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
