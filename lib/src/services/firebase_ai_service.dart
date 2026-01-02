// lib/services/firebase_ai_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/ai_message_model.dart';
import '../firebase/firebase_config.dart';

class FirebaseAIService {
  static final FirebaseAIService _instance = FirebaseAIService._internal();
  factory FirebaseAIService() => _instance;
  FirebaseAIService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final http.Client _httpClient = http.Client();

  // Collections
  static const String conversationsCollection = 'ai_conversations';
  static const String messagesCollection = 'messages';
  static const String usersCollection = 'users';

  // Initialize service
  Future<void> initialize() async {
    if (kDebugMode) {
      // Use emulator for development
      _firestore.useFirestoreEmulator('localhost', 8080);
    }
  }

  // Get AI response via HTTP (Direct API call)
  Future<Map<String, dynamic>> getAIResponse({
    required String message,
    String? conversationId,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User must be logged in');
    }

    try {
      // Option 1: Direct call to your backend API
      // Replace with your actual backend URL
      final response = await _httpClient.post(
        Uri.parse('${FirebaseConfig.baseUrl}/aiAssistant'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await user.getIdToken()}',
        },
        body: jsonEncode({
          'message': message,
          'conversationId': conversationId,
          'userId': user.uid,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get AI response: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('AI Response Error: $e');

      // Fallback: Use mock response when backend is down
      return _getMockAIResponse(message);
    }
  }

  // Mock AI response for development
  Map<String, dynamic> _getMockAIResponse(String message) {
    final responses = [
      "I'd be happy to help you learn! What topic interests you today?",
      "That's a great question! Let me explain it step by step...",
      "Based on your question, I recommend starting with the basics.",
      "Here's a simple analogy to help you understand...",
      "Let me break this down into smaller, manageable parts.",
      "This concept is fundamental. Understanding it will help you with more advanced topics.",
      "Practice makes perfect! Try these exercises to reinforce your understanding.",
      "Here are some resources that might help you learn more about this topic.",
      "Great question! This shows you're thinking critically about the subject.",
    ];

    final randomIndex = DateTime.now().millisecondsSinceEpoch % responses.length;

    return {
      'response': responses[randomIndex],
      'timestamp': DateTime.now().toIso8601String(),
      'isMock': true,
    };
  }

  // Create new conversation
  Future<String> createConversation({
    required String title,
    List<String> tags = const [],
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final docRef = _firestore.collection(conversationsCollection).doc();

    await docRef.set({
      'id': docRef.id,
      'userId': user.uid,
      'title': title,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'messageCount': 0,
      'isArchived': false,
      'tags': tags,
    });

    return docRef.id;
  }

  // Save message to Firestore
  Future<void> saveMessage({
    required String conversationId,
    required String text,
    required String senderId,
    required String senderName,
    bool isAI = false,
    AIMessageType type = AIMessageType.text,
    Map<String, dynamic>? metadata,
  }) async {
    final messageRef = _firestore
        .collection(conversationsCollection)
        .doc(conversationId)
        .collection(messagesCollection)
        .doc();

    final message = AIMessage(
      id: messageRef.id,
      text: text,
      senderId: senderId,
      senderName: senderName,
      timestamp: DateTime.now(),
      type: type,
      metadata: metadata,
      isAI: isAI,
    );

    await messageRef.set(message.toFirestore());

    // Update conversation
    await _firestore
        .collection(conversationsCollection)
        .doc(conversationId)
        .update({
      'updatedAt': FieldValue.serverTimestamp(),
      'messageCount': FieldValue.increment(1),
      if (!isAI) 'lastUserMessage': text,
      if (isAI) 'lastAIMessage': text,
    });
  }

  // Get conversation messages stream
  Stream<List<AIMessage>> getMessagesStream(String conversationId) {
    return _firestore
        .collection(conversationsCollection)
        .doc(conversationId)
        .collection(messagesCollection)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => AIMessage.fromFirestore(doc))
        .toList());
  }

  // Get user conversations
  Stream<List<AIConversation>> getUserConversations() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection(conversationsCollection)
        .where('userId', isEqualTo: user.uid)
        .where('isArchived', isEqualTo: false)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => AIConversation.fromFirestore(doc))
        .toList());
  }

  // Health check
  Future<bool> healthCheck() async {
    try {
      final response = await _httpClient.get(
        Uri.parse(FirebaseConfig.healthCheckUrl),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Health Check Error: $e');
      return false;
    }
  }

  // Quick prompts for AI
  static final List<Map<String, dynamic>> quickPrompts = [
    {
      'id': 'explain_concept',
      'title': 'Explain a Concept',
      'prompt': 'Can you explain the concept of {topic} in simple terms?',
      'icon': '🧠',
      'color': 0xFF4361EE,
    },
    {
      'id': 'solve_math',
      'title': 'Solve Math Problem',
      'prompt': 'Help me solve this math problem: {problem}',
      'icon': '🔢',
      'color': 0xFF4CC9F0,
    },
    {
      'id': 'study_plan',
      'title': 'Create Study Plan',
      'prompt': 'Create a study plan for {topic} for {duration}',
      'icon': '📅',
      'color': 0xFF7209B7,
    },
    {
      'id': 'practice_questions',
      'title': 'Practice Questions',
      'prompt': 'Generate practice questions about {topic}',
      'icon': '❓',
      'color': 0xFFF72585,
    },
    {
      'id': 'learning_tips',
      'title': 'Learning Tips',
      'prompt': 'Give me learning tips for {subject}',
      'icon': '💡',
      'color': 0xFF2EC4B6,
    },
    {
      'id': 'code_help',
      'title': 'Code Help',
      'prompt': 'Help me understand this code: {code}',
      'icon': '💻',
      'color': 0xFFFF9F1C,
    },
  ];

  // Dispose HTTP client
  void dispose() {
    _httpClient.close();
  }
}