// lib/providers/ai_assistant_provider.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../models/ai_message_model.dart';

enum AIAssistantState {
  initializing,
  ready,
  loading,
  error,
}

class AIAssistantProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ========== ADD THIS ==========
  // TEST MODE - Set to TRUE to bypass Firebase index errors
  static const bool _testMode = true; // <-- CHANGE THIS TO FALSE LATER

  // Debug mode
  static const bool _debugMode = true;

  // State variables
  AIAssistantState _state = AIAssistantState.initializing;
  List<AIMessage> _messages = [];
  String? _currentConversationId;
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription? _messagesSubscription;
  StreamSubscription? _authSubscription;

  // Getters
  AIAssistantState get state => _state;
  List<AIMessage> get messages => _messages;
  String? get currentConversationId => _currentConversationId;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Debug helper
  void _debugPrint(String message) {
    if (_debugMode) {
      debugPrint('🤖 AIAssistant: $message');
    }
  }

  // Quick Prompts
  static final List<Map<String, dynamic>> quickPrompts = [
    {
      'title': 'Explain Physics',
      'prompt': 'Explain the basics of physics in simple terms',
      'icon': '🧠',
      'color': 0xFF4361EE,
    },
    {
      'title': 'Math Help',
      'prompt': 'Solve 2x + 5 = 15 step by step',
      'icon': '🔢',
      'color': 0xFF4CC9F0,
    },
    {
      'title': 'Study Plan',
      'prompt': 'Create a 7-day study plan for science',
      'icon': '📅',
      'color': 0xFF7209B7,
    },
    {
      'title': 'Practice Questions',
      'prompt': 'Give me 3 practice questions about gravity',
      'icon': '❓',
      'color': 0xFFF72585,
    },
  ];

  List<Map<String, dynamic>> get getQuickPrompts => quickPrompts;

  // Constructor
  AIAssistantProvider() {
    if (!_testMode) {
      _setupAuthListener();
    }
    // Auto-initialize
    Future.delayed(const Duration(milliseconds: 100), () {
      initialize();
    });
  }

  // Setup auth listener (only for real mode)
  void _setupAuthListener() {
    if (_testMode) return;

    _authSubscription = _auth.authStateChanges().listen((user) {
      _debugPrint('Auth state changed: ${user?.uid ?? "No user"}');

      if (user != null && _state == AIAssistantState.error) {
        // Retry initialization if user logs in while in error state
        _debugPrint('User logged in, retrying initialization...');
        initialize();
      } else if (user == null && _state != AIAssistantState.initializing) {
        _debugPrint('User logged out, clearing data');
        _clearData();
        _updateState(AIAssistantState.error);
        _errorMessage = 'Please sign in to use AI Assistant';
        notifyListeners();
      }
    });
  }

  // Clear data when logged out
  void _clearData() {
    _messages.clear();
    _currentConversationId = null;
    _messagesSubscription?.cancel();
    _messagesSubscription = null;
  }

  // Initialize
  Future<void> initialize() async {
    try {
      _debugPrint('=== INITIALIZING AI ASSISTANT ===');
      _updateState(AIAssistantState.initializing);
      _errorMessage = null;
      notifyListeners();

      // ========== TEST MODE ==========
      if (_testMode) {
        _debugPrint('🔧 RUNNING IN TEST MODE (No Firebase)');

        await Future.delayed(const Duration(seconds: 1)); // Simulate loading

        // Create test messages
        _messages = [
          AIMessage(
            id: 'test-1',
            text: '👋 Hello! I am your AI Learning Assistant.',
            senderId: 'ai',
            senderName: 'AI Assistant',
            timestamp: DateTime.now(),
            type: AIMessageType.text,
            isAI: true,
          ),
          AIMessage(
            id: 'test-2',
            text: 'I can help with physics, math, study plans, and practice questions!',
            senderId: 'ai',
            senderName: 'AI Assistant',
            timestamp: DateTime.now().add(const Duration(seconds: 1)),
            type: AIMessageType.text,
            isAI: true,
          ),
        ];

        _debugPrint('✅ Test mode initialized successfully');
        _updateState(AIAssistantState.ready);
        _errorMessage = null;
        notifyListeners();
        return;
      }
      // ========== END TEST MODE ==========

      // ========== REAL MODE (Firebase) ==========
      _debugPrint('🔧 RUNNING IN REAL MODE (With Firebase)');

      // Wait a moment for Firebase to initialize
      await Future.delayed(const Duration(milliseconds: 500));

      _debugPrint('1. Checking Firebase Auth...');
      final user = _auth.currentUser;
      _debugPrint('User ID: ${user?.uid ?? "NULL"}');
      _debugPrint('User email: ${user?.email ?? "NULL"}');

      if (user == null) {
        _debugPrint('❌ No user found! User must be signed in.');
        _updateState(AIAssistantState.error);
        _errorMessage = 'Please sign in to use the AI Assistant';
        notifyListeners();
        return;
      }

      // Check if email is verified (optional)
      if (!user.emailVerified) {
        _debugPrint('⚠️ Email not verified, but continuing anyway...');
      }

      // ========== FIX: Remove Firestore test (causes errors) ==========
      _debugPrint('2. Setting up conversations...');

      try {
        // ========== FIX: Use simpler query to avoid index error ==========
        // Get all conversations for this user
        final conversationsSnapshot = await _firestore
            .collection('ai_conversations')
            .where('userId', isEqualTo: user.uid)
            .get()
            .timeout(const Duration(seconds: 10));

        // Filter and sort manually to avoid index requirement
        final activeConversations = conversationsSnapshot.docs
            .where((doc) {
          final data = doc.data();
          return data['isArchived'] != true; // Check if not archived
        })
            .toList();

        // Sort by updatedAt manually
        activeConversations.sort((a, b) {
          final aTime = a.data()['updatedAt'] as Timestamp?;
          final bTime = b.data()['updatedAt'] as Timestamp?;
          return (bTime?.millisecondsSinceEpoch ?? 0)
              .compareTo(aTime?.millisecondsSinceEpoch ?? 0);
        });

        _debugPrint('Found ${activeConversations.length} active conversations');

        if (activeConversations.isNotEmpty) {
          final conversationId = activeConversations.first.id;
          _debugPrint('Loading conversation: $conversationId');
          await _switchConversation(conversationId);
        } else {
          _debugPrint('Creating new conversation...');
          await _createInitialConversation();
        }

      } on FirebaseException catch (e) {
        // If there's an error, try to create a new conversation anyway
        _debugPrint('⚠️ Firestore query error: ${e.code} - ${e.message}');
        _debugPrint('Creating new conversation despite error...');
        await _createInitialConversation();
      }

      _debugPrint('✅ Initialization complete');
      _updateState(AIAssistantState.ready);
      _errorMessage = null;

    } on TimeoutException catch (e) {
      _debugPrint('❌ Timeout during initialization: $e');
      _updateState(AIAssistantState.error);
      _errorMessage = 'Connection timeout. Please check your internet connection.';
    } on FirebaseException catch (e) {
      _debugPrint('❌ Firebase Exception: ${e.code} - ${e.message}');
      _updateState(AIAssistantState.error);

      if (e.code == 'permission-denied') {
        _errorMessage = 'Permission denied. Check Firestore rules.';
      } else if (e.code == 'unavailable') {
        _errorMessage = 'Service unavailable. Please try again later.';
      } else if (e.code.contains('index')) {
        _errorMessage = 'Firestore needs an index. Click the link in the error to create it.';
      } else {
        _errorMessage = 'Firebase error: ${e.message}';
      }
    } catch (e, stack) {
      _debugPrint('❌ Unexpected error: $e');
      _debugPrint('Stack trace: $stack');
      _updateState(AIAssistantState.error);
      _errorMessage = 'Failed to initialize: ${e.toString()}';
    }

    notifyListeners();
  }

  // Create initial conversation
  Future<void> _createInitialConversation() async {
    if (_testMode) return;

    final user = _auth.currentUser;
    if (user == null) return;

    _debugPrint('Creating initial conversation...');
    final conversationId = await _createConversation(
      userId: user.uid,
      title: 'AI Assistant',
    );

    await _switchConversation(conversationId);

    // Add welcome message
    await _saveMessage(
      conversationId: conversationId,
      text: '👋 Hello! I am your AI Learning Assistant. How can I help you today?',
      senderId: 'ai',
      senderName: 'AI Assistant',
      isAI: true,
    );

    _debugPrint('Welcome message added');
  }

  // Switch conversation
  Future<void> _switchConversation(String conversationId) async {
    if (_testMode) return;

    _debugPrint('Switching to conversation: $conversationId');

    _currentConversationId = conversationId;
    _messages.clear();
    _messagesSubscription?.cancel();

    _messagesSubscription = _getMessagesStream(conversationId).listen((messages) {
      _messages = messages;
      _debugPrint('Messages updated: ${messages.length} messages');
      notifyListeners();
    }, onError: (error) {
      _debugPrint('Error in messages stream: $error');
      // Don't go to error state for stream errors
    });

    notifyListeners();
  }

  // Send message
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    _debugPrint('Sending: ${text.length > 30 ? "${text.substring(0, 30)}..." : text}');

    // ========== TEST MODE ==========
    if (_testMode) {
      _isLoading = true;
      notifyListeners();

      // Add user message
      _messages.add(AIMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: text,
        senderId: 'test-user',
        senderName: 'You',
        timestamp: DateTime.now(),
        type: AIMessageType.text,
        isAI: false,
      ));
      notifyListeners();

      // Simulate AI thinking
      await Future.delayed(const Duration(seconds: 1));

      // Generate test AI response
      String aiResponse = _getTestAIResponse(text);

      // Add AI response
      _messages.add(AIMessage(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        text: aiResponse,
        senderId: 'ai',
        senderName: 'AI Assistant',
        timestamp: DateTime.now().add(const Duration(seconds: 1)),
        type: AIMessageType.text,
        isAI: true,
      ));

      _isLoading = false;
      notifyListeners();
      return;
    }
    // ========== END TEST MODE ==========

    // ========== REAL MODE ==========
    final user = _auth.currentUser;
    if (user == null) {
      _errorMessage = 'Please log in to send messages';
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _debugPrint('Sending message: ${text.length > 50 ? '${text.substring(0, 50)}...' : text}');

      // Create conversation if none exists
      if (_currentConversationId == null) {
        _debugPrint('No conversation found, creating new one...');
        final conversationId = await _createConversation(
          userId: user.uid,
          title: text.length > 20 ? '${text.substring(0, 20)}...' : text,
        );
        await _switchConversation(conversationId);
      }

      // Save user message
      await _saveMessage(
        conversationId: _currentConversationId!,
        text: text,
        senderId: user.uid,
        senderName: 'You',
        isAI: false,
      );

      // Get AI response
      final aiResponse = await _getAIResponse(text);

      // Save AI response
      await _saveMessage(
        conversationId: _currentConversationId!,
        text: aiResponse,
        senderId: 'ai',
        senderName: 'AI Assistant',
        isAI: true,
      );

      _errorMessage = null;
      _debugPrint('Message sent successfully');

    } catch (e) {
      _debugPrint('Send message error: $e');
      _errorMessage = 'Failed to send message: ${e.toString()}';

      // Add fallback message if something goes wrong
      if (!_testMode && _currentConversationId != null) {
        await _saveMessage(
          conversationId: _currentConversationId!,
          text: 'I encountered an error processing your request. Please try again.',
          senderId: 'ai',
          senderName: 'AI Assistant',
          isAI: true,
        );
      } else if (_testMode) {
        // Test mode fallback
        _messages.add(AIMessage(
          id: 'error-${DateTime.now().millisecondsSinceEpoch}',
          text: 'I encountered an error. Please try again.',
          senderId: 'ai',
          senderName: 'AI Assistant',
          timestamp: DateTime.now(),
          type: AIMessageType.text,
          isAI: true,
        ));
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ========== ADD THIS METHOD ==========
  // Test mode AI response generator
  String _getTestAIResponse(String userMessage) {
    final lower = userMessage.toLowerCase();

    if (lower.contains('physics') || lower.contains('science')) {
      return '''Physics Basics:
• Motion: How objects move
• Forces: Pushes and pulls
• Energy: Ability to do work
• Gravity: Pulls objects together

Example: When you throw a ball, force makes it move, gravity brings it down.''';
    } else if (lower.contains('math') || lower.contains('solve')) {
      return '''Math Solution:
2x + 5 = 15

Step 1: 2x + 5 - 5 = 15 - 5
Step 2: 2x = 10
Step 3: x = 10 ÷ 2
✅ Answer: x = 5''';
    } else if (lower.contains('study') || lower.contains('plan')) {
      return '''7-Day Study Plan:
Day 1: Review basics
Day 2: Difficult topics
Day 3: Practice problems
Day 4: Review mistakes
Day 5: Practice test
Day 6: Weak areas
Day 7: Final review

Study 1-2 hours daily with breaks!''';
    } else if (lower.contains('hello') || lower.contains('hi')) {
      return '''Hello! 👋 I'm your AI Learning Assistant. I can help with:
• Subject explanations
• Problem solving
• Study planning
• Practice questions

What would you like to learn?''';
    } else {
      return '''I can help you with:
1. Subject explanations (Physics, Math, Science)
2. Problem solving with step-by-step solutions
3. Study planning and time management
4. Practice questions and quizzes

Try asking: "Explain gravity" or "Help me solve 3x - 7 = 8"''';
    }
  }

  // Get AI response (real mode)
  Future<String> _getAIResponse(String userMessage) async {
    try {
      _debugPrint('Getting AI response via DeepSeek API...');

      // Try DeepSeek API
      final response = await http.post(
        Uri.parse('https://api.deepseek.com/chat/completions'),
        headers: {
          'Authorization': 'Bearer sk-or-v1-8d1e6b54b2f04c48a3f3f8e8f7b1a2c3',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'deepseek-chat',
          'messages': [
            {'role': 'system', 'content': 'You are a helpful AI learning assistant.'},
            {'role': 'user', 'content': userMessage}
          ],
          'temperature': 0.7,
          'max_tokens': 500,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        _debugPrint('API response received (${content.length} chars)');
        return content;
      } else {
        _debugPrint('API error status: ${response.statusCode}');
        _debugPrint('Response body: ${response.body}');
        // Fallback to test response
        return _getTestAIResponse(userMessage);
      }
    } on TimeoutException {
      _debugPrint('API request timeout');
      return _getTestAIResponse(userMessage);
    } catch (e) {
      _debugPrint('API error: $e');
      return _getTestAIResponse(userMessage);
    }
  }

  // Helper methods
  Future<String> _createConversation({
    required String userId,
    required String title,
  }) async {
    if (_testMode) {
      return 'test-conversation-${DateTime.now().millisecondsSinceEpoch}';
    }

    final docRef = _firestore.collection('ai_conversations').doc();
    final conversationId = docRef.id;

    await docRef.set({
      'id': conversationId,
      'userId': userId,
      'title': title,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'messageCount': 0,
      'isArchived': false,
    });

    _debugPrint('Created conversation: $conversationId');
    return conversationId;
  }

  Future<void> _saveMessage({
    required String conversationId,
    required String text,
    required String senderId,
    required String senderName,
    bool isAI = false,
  }) async {
    if (_testMode) return;

    final messageRef = _firestore
        .collection('ai_conversations')
        .doc(conversationId)
        .collection('messages')
        .doc();

    final message = AIMessage(
      id: messageRef.id,
      text: text,
      senderId: senderId,
      senderName: senderName,
      timestamp: DateTime.now(),
      type: AIMessageType.text,
      isAI: isAI,
    );

    await messageRef.set(message.toFirestore());

    // Update conversation
    await _firestore
        .collection('ai_conversations')
        .doc(conversationId)
        .update({
      'updatedAt': FieldValue.serverTimestamp(),
      'messageCount': FieldValue.increment(1),
    });

    _debugPrint('Saved ${isAI ? 'AI' : 'User'} message');
  }

  Stream<List<AIMessage>> _getMessagesStream(String conversationId) {
    return _firestore
        .collection('ai_conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => AIMessage.fromFirestore(doc))
        .toList());
  }

  // Public methods
  Future<void> createNewConversation() async {
    if (_testMode) {
      _messages.clear();
      _messages.add(AIMessage(
        id: 'new-chat',
        text: '👋 New chat started! How can I help you?',
        senderId: 'ai',
        senderName: 'AI Assistant',
        timestamp: DateTime.now(),
        type: AIMessageType.text,
        isAI: true,
      ));
      notifyListeners();
      return;
    }

    final user = _auth.currentUser;
    if (user == null) return;

    final conversationId = await _createConversation(
      userId: user.uid,
      title: 'New Chat',
    );

    await _switchConversation(conversationId);

    // Add welcome message to new conversation
    await _saveMessage(
      conversationId: conversationId,
      text: '👋 Hello! I am your AI Learning Assistant. How can I help you today?',
      senderId: 'ai',
      senderName: 'AI Assistant',
      isAI: true,
    );
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _updateState(AIAssistantState newState) {
    _state = newState;
    _debugPrint('State changed to: $newState');
    notifyListeners();
  }

  @override
  void dispose() {
    _debugPrint('Disposing AIAssistantProvider...');
    _messagesSubscription?.cancel();
    if (!_testMode) {
      _authSubscription?.cancel();
    }
    super.dispose();
  }
}