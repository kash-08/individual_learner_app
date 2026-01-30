import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'ai_assistant_screen.dart';
import 'challenges_exams_screen.dart';
import 'profile_screen.dart'; // Changed from analytics_screen.dart
import 'progress_updates_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // List of screens for bottom navigation
  final List<Widget> _screens = [
    const HomeScreen(),
    const AIAssistantScreen(),
    const ChallengesExamsScreen(),
    const ProfileScreen(), // Changed from AnalyticsScreen()
    const ProgressUpdatesScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF4361EE),
        unselectedItemColor: Colors.grey[600],
        selectedLabelStyle: const TextStyle(fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy),
            label: 'AI Assistant',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.quiz),
            label: 'Challenges',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person), // Changed from Icons.analytics
            label: 'Profile', // Changed from 'Analytics'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timeline),
            label: 'Progress',
          ),
        ],
      ),
    );
  }
}