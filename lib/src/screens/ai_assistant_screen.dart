// lib/screens/ai_assistant_screen.dart
import 'package:flutter/material.dart';

class AIAssistantScreen extends StatelessWidget {
  const AIAssistantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assistant'),
        backgroundColor: const Color(0xFF6B46C1),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.smart_toy,
              size: 120,
              color: Colors.purple[200],
            ),
            const SizedBox(height: 24),
            const Text(
              'AI Assistant Coming Soon!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Your personal AI learning companion is under development. '
                    'It will help you with:\n\n'
                    '• Instant homework help\n'
                    '• Concept explanations\n'
                    '• Study plan recommendations\n'
                    '• 24/7 Q&A support',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.access_time, color: Colors.purple),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Expected release: Next submission',
                      style: TextStyle(
                        color: Colors.purple,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}