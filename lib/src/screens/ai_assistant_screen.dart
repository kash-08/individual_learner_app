// lib/screens/ai_assistant_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ai_message_model.dart';
import '../providers/ai_assistant_provider.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isInitializing = false;
  bool _showDebugInfo = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProvider();
    });
  }

  Future<void> _initializeProvider() async {
    if (_isInitializing) return;

    setState(() => _isInitializing = true);

    try {
      final provider = Provider.of<AIAssistantProvider>(context, listen: false);
      await provider.initialize();
    } catch (e) {
      debugPrint('Screen init error: $e');
    } finally {
      setState(() => _isInitializing = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final provider = Provider.of<AIAssistantProvider>(context, listen: false);

    if (provider.state != AIAssistantState.ready) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('AI Assistant is not ready yet. Please wait.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    provider.sendMessage(text);
    _messageController.clear();
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  void _showQuickActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.count(
                padding: const EdgeInsets.all(16),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
                children: AIAssistantProvider.quickPrompts.map((prompt) {
                  return _buildQuickActionCard(
                    icon: prompt['icon'],
                    title: prompt['title'],
                    color: Color(prompt['color'] as int),
                    onTap: () {
                      Navigator.pop(context);
                      _messageController.text = prompt['prompt'].toString();
                      _sendMessage();
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required String icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                icon,
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF4361EE),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.smart_toy,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE9ECEF)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4361EE)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Thinking...',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(AIMessage message) {
    final isAI = message.isAI;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isAI)
            const SizedBox(width: 52),

          Expanded(
            child: Column(
              crossAxisAlignment: isAI ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isAI ? const Color(0xFFF8F9FA) : const Color(0xFF4361EE),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(isAI ? 0 : 16),
                      topRight: Radius.circular(isAI ? 16 : 0),
                      bottomLeft: const Radius.circular(16),
                      bottomRight: const Radius.circular(16),
                    ),
                    border: isAI ? Border.all(color: const Color(0xFFE9ECEF)) : null,
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: isAI ? Colors.black : Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(message.timestamp),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          if (isAI)
            Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(left: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF4361EE),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.smart_toy,
                color: Colors.white,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildEmptyState() {
    final provider = Provider.of<AIAssistantProvider>(context, listen: false);
    final isTestMode = provider.state == AIAssistantState.ready &&
        provider.messages.isNotEmpty &&
        provider.messages.any((m) => m.text.contains('test mode'));

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: isTestMode ? Colors.amber.withOpacity(0.1) : const Color(0xFF4361EE).withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                isTestMode ? Icons.warning : Icons.smart_toy,
                size: 60,
                color: isTestMode ? Colors.amber : const Color(0xFF4361EE),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isTestMode ? 'Test Mode Active' : 'AI Learning Assistant',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isTestMode ? Colors.amber : const Color(0xFF4361EE),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              isTestMode
                  ? 'Running without Firebase. AI responses are simulated.'
                  : 'Ask me anything about your studies! I can help with explanations, problem-solving, study plans, and more.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
                height: 1.5,
              ),
            ),
            if (isTestMode) ...[
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber),
                ),
                child: const Text(
                  'To use real Firebase, set testMode = false in provider',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 30),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: AIAssistantProvider.quickPrompts.map((prompt) {
                return ActionChip(
                  label: Text(
                    prompt['title'],
                    style: TextStyle(
                      color: Color(prompt['color'] as int),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  avatar: Text(prompt['icon']),
                  backgroundColor: Color(prompt['color'] as int).withOpacity(0.1),
                  onPressed: () {
                    _messageController.text = prompt['prompt'].toString();
                    _sendMessage();
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: () => _showQuickActions(context),
              icon: const Icon(Icons.bolt),
              label: const Text('More Quick Actions'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                setState(() => _showDebugInfo = !_showDebugInfo);
              },
              child: const Text('Toggle Debug Info'),
            ),
            if (_showDebugInfo) ...[
              const SizedBox(height: 20),
              Consumer<AIAssistantProvider>(
                builder: (context, provider, child) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Debug Info:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('State: ${provider.state}'),
                        Text('Messages: ${provider.messages.length}'),
                        Text('Loading: ${provider.isLoading}'),
                        Text('Error: ${provider.errorMessage ?? "None"}'),
                      ],
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String errorMessage) {
    final provider = Provider.of<AIAssistantProvider>(context, listen: false);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.error_outline,
                size: 50,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Failed to Initialize',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  Text(
                    errorMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Solutions:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildSolutionStep('1. Check Firestore Rules',
                      'Go to Firebase Console → Firestore → Rules\nSet to allow read/write for testing'),
                  _buildSolutionStep('2. Create Collections',
                      'Create "ai_conversations" collection in Firestore'),
                  _buildSolutionStep('3. Enable Test Mode',
                      'Set testMode = true in AIAssistantProvider'),
                  _buildSolutionStep('4. Check Firebase Setup',
                      'Verify firebase_core is initialized in main.dart'),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    setState(() => _isInitializing = true);
                    await _initializeProvider();
                    setState(() => _isInitializing = false);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    // Toggle test mode
                    provider.clearError();
                    _initializeProvider();
                  },
                  icon: const Icon(Icons.swap_horiz),
                  label: const Text('Use Test Mode'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Firebase Setup Guide'),
                    content: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('1. Update Firestore Rules:'),
                          SelectableText(
                            'rules_version = \'2\';\nservice cloud.firestore {\n  match /databases/{database}/documents {\n    match /{document=**} {\n      allow read, write: if true;\n    }\n  }\n}',
                            style: const TextStyle(fontFamily: 'monospace'),
                          ),
                          const SizedBox(height: 10),
                          const Text('2. Create Collection:'),
                          const Text('- Go to Firestore Database'),
                          const Text('- Click "Start Collection"'),
                          const Text('- Name: "ai_conversations"'),
                          const SizedBox(height: 10),
                          const Text('3. In AIAssistantProvider:'),
                          const Text('Change: static const bool _testMode = false;'),
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
              },
              child: const Text('View Setup Instructions'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSolutionStep(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.only(top: 2, right: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF4361EE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                '✓',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF4361EE),
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.smart_toy, size: 24),
            SizedBox(width: 12),
            Text(
              'AI Assistant',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _showQuickActions(context),
            icon: const Icon(Icons.bolt),
            tooltip: 'Quick Actions',
          ),
          IconButton(
            onPressed: () {
              final provider = Provider.of<AIAssistantProvider>(context, listen: false);
              provider.createNewConversation();
            },
            icon: const Icon(Icons.add),
            tooltip: 'New Chat',
          ),
        ],
      ),
      body: Consumer<AIAssistantProvider>(
        builder: (context, provider, child) {
          // Show loading
          if (_isInitializing || provider.state == AIAssistantState.initializing) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('Loading AI Assistant...'),
                ],
              ),
            );
          }

          // Show error
          if (provider.state == AIAssistantState.error) {
            return _buildErrorState(
              provider.errorMessage ?? 'An unknown error occurred',
            );
          }

          // Main chat
          return Column(
            children: [
              Expanded(
                child: provider.messages.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(top: 16, bottom: 16),
                  itemCount: provider.messages.length + (provider.isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index < provider.messages.length) {
                      return _buildMessageBubble(provider.messages[index]);
                    } else {
                      return _buildLoadingIndicator();
                    }
                  },
                ),
              ),

              // Message input
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.grey[300]!)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Type your message...',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: const BorderSide(color: Color(0xFF4361EE)),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          suffixIcon: IconButton(
                            onPressed: _sendMessage,
                            icon: Icon(
                              Icons.send,
                              color: _messageController.text.trim().isEmpty
                                  ? Colors.grey[400]
                                  : const Color(0xFF4361EE),
                            ),
                          ),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}