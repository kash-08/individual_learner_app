// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ADD THIS
import 'package:provider/provider.dart';
import 'package:individual_learner_app/src/providers/auth_provider.dart';
import 'package:individual_learner_app/src/providers/achievement_provider.dart';
import 'package:individual_learner_app/src/providers/exam_provider.dart';
import 'package:individual_learner_app/src/screens/home_screen.dart';
import 'package:individual_learner_app/src/screens/login_screen.dart';
import 'package:individual_learner_app/src/screens/main_screen.dart';
import 'package:individual_learner_app/src/providers/course_provider.dart';
import 'package:individual_learner_app/src/providers/updates_provider.dart';
import 'package:individual_learner_app/src/services/session_service.dart';
import 'package:individual_learner_app/src/firebase/firebase_options.dart';
import 'package:individual_learner_app/src/services/firebase_service.dart';
import 'package:individual_learner_app/src/services/assesment_service.dart';

// NEW: Import AI Assistant
import 'package:individual_learner_app/src/providers/ai_assistant_provider.dart';
import 'package:individual_learner_app/src/screens/ai_assistant_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // FIX YELLOW/BLACK AREA: Set system UI colors
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Color(0xFF4361EE), // Status bar color (top)
    statusBarBrightness: Brightness.light,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.white, // Navigation bar color (bottom)
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  // Initialize Firebase with platform-specific options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Firebase sample data (courses, weekly updates)
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

        // NEW: AI Assistant Provider (initialize immediately)
        ChangeNotifierProvider(
          create: (_) => AIAssistantProvider(),
          lazy: false, // Initialize immediately
        ),

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

        // NEW: Add AI Assistant screen to routes
        routes: {
          '/ai-assistant': (context) => const AIAssistantScreen(),
        },
      ),
    );
  }
}

// Authentication Wrapper Widget - UPDATED with AI initialization
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _aiInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeAI();
  }

  Future<void> _initializeAI() async {
    try {
      // Initialize AI Assistant when user is authenticated
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user != null) {
        final aiProvider = Provider.of<AIAssistantProvider>(context, listen: false);
        await aiProvider.initialize();
      }

      setState(() {
        _aiInitialized = true;
      });
    } catch (e) {
      print('AI initialization error: $e');
      setState(() {
        _aiInitialized = true; // Continue even if AI fails
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Show loading screen while checking auth state or initializing AI
    if (authProvider.isLoading || !_aiInitialized) {
      return _buildLoadingScreen();
    }

    // Redirect based on auth state
    return authProvider.user != null ? const MainScreen() : const LoginScreen();
  }

  Widget _buildLoadingScreen() {
    // REMOVED SafeArea to fix yellow/black areas
    return Scaffold(
      backgroundColor: const Color(0xFF4361EE), // Full blue background
      body: Container(
        color: const Color(0xFF4361EE), // Ensure full coverage
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated loading indicator
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
                    child: const Icon(
                      Icons.smart_toy,
                      color: Color(0xFF4361EE),
                      size: 40,
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
              const Text(
                'Initializing AI Assistant...',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 30),
              // Loading animation dots
              _buildLoadingDots(),
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
}

// Optional: Add a global error handler for AI
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

// Optional: Global AI shortcut helper
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
      // Create a temporary conversation for quick answers
      await aiProvider.sendMessage(question);

      // Wait for response
      await Future.delayed(const Duration(seconds: 1));

      // Get the latest AI message
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