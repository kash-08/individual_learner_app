// AI Short Answer Service
// Handles API integration and response generation logic

import 'dart:convert';
import 'package:http/http.dart' as http;

class AIShortAnswerService {
  // For production, use your actual API endpoints
  // This example uses a mock implementation with options for real APIs

  static const String _mockApiUrl = 'https://api.example.com/ai/answer';
  static const String _openAiUrl = 'https://api.openai.com/v1/completions';

  // Mock responses for development (remove for production)
  static final Map<String, String> _mockResponses = {
    'machine learning': 'Machine learning is a subset of artificial intelligence that enables systems to learn and improve from experience without being explicitly programmed. It focuses on developing algorithms that can process data, identify patterns, and make decisions.',
    'flutter': 'Flutter is Google\'s open-source UI software development kit for building natively compiled applications for mobile, web, and desktop from a single codebase. It uses the Dart programming language.',
    'algorithm': 'An algorithm is a finite sequence of well-defined instructions, typically used to solve a class of problems or perform a computation. Algorithms are fundamental to computer science and data processing.',
  };

  // Generate a short answer (definition or summary)
  Future<String> generateShortAnswer({
    required String query,
    required AnswerType type,
    int maxLength = 150,
    String language = 'English',
  }) async {
    try {
      // In production, replace with actual API calls
      // Example with OpenAI:
      // return await _callOpenAI(query, type, maxLength);

      // For development, use mock responses
      await Future.delayed(const Duration(seconds: 1)); // Simulate API delay

      final key = query.toLowerCase();
      if (_mockResponses.containsKey(key)) {
        return _mockResponses[key]!;
      }

      // Fallback response
      return _generateFallbackResponse(query, type);

    } catch (e) {
      print('AI Service Error: $e');
      return 'Sorry, I couldn\'t generate a response at the moment. Please try again.';
    }
  }

  // Call OpenAI API (example implementation)
  Future<String> _callOpenAI(String query, AnswerType type, int maxLength) async {
    const apiKey = 'YOUR_OPENAI_API_KEY'; // Store securely in environment variables

    final response = await http.post(
      Uri.parse(_openAiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo-instruct',
        'prompt': _buildPrompt(query, type, maxLength),
        'max_tokens': maxLength,
        'temperature': 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['text'].trim();
    } else {
      throw Exception('Failed to fetch AI response: ${response.statusCode}');
    }
  }

  String _buildPrompt(String query, AnswerType type, int maxLength) {
    switch (type) {
      case AnswerType.definition:
        return 'Provide a concise definition of "$query" in under $maxLength characters. Focus on clarity and key characteristics.';
      case AnswerType.summary:
        return 'Summarize the concept "$query" in under $maxLength characters. Highlight main points and significance.';
      case AnswerType.explanation:
        return 'Explain "$query" in simple terms suitable for a student, in under $maxLength characters.';
    }
  }

  String _generateFallbackResponse(String query, AnswerType type) {
    switch (type) {
      case AnswerType.definition:
        return '"$query" refers to a fundamental concept in its field. In essence, it involves key principles and applications that are studied across various disciplines.';
      case AnswerType.summary:
        return 'A summary of "$query" would cover its main components, typical applications, and importance in modern contexts. It\'s a valuable concept to understand for comprehensive knowledge.';
      case AnswerType.explanation:
        return '"$query" can be understood as a core idea that plays a significant role in its domain. Students typically learn about its applications and theoretical foundations.';
    }
  }

  // Get related terms for a query
  Future<List<String>> getRelatedTerms(String query) async {
    // Mock related terms - replace with actual API in production
    final relatedMap = {
      'machine learning': ['neural networks', 'deep learning', 'supervised learning', 'unsupervised learning'],
      'flutter': ['dart', 'widget', 'state management', 'material design'],
      'algorithm': ['data structure', 'complexity', 'sorting', 'searching'],
    };

    await Future.delayed(const Duration(milliseconds: 500));
    return relatedMap[query.toLowerCase()] ?? ['No related terms found'];
  }
}

// Answer type enum
enum AnswerType {
  definition,
  summary,
  explanation,
}