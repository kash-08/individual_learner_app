// lib/screens/ai_assistant_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ai_message_model.dart';
import '../providers/ai_assistant_provider.dart';
import '../services/firebase_ai_service.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AIAssistantProvider>(context, listen: false);
      provider.initialize();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final provider = Provider.of<AIAssistantProvider>(context, listen: false);
    provider.sendMessage(text);

    _messageController.clear();
    _scrollToBottom();
  }

  void _showQuickActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
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
                      color: Color(0xFF212529),
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
                children: FirebaseAIService.quickPrompts.map((prompt) {
                  return _buildQuickActionCard(
                    icon: prompt['icon'],
                    title: prompt['title'],
                    color: Color(prompt['color']),
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
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                icon,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF212529),
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
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        const Color(0xFF4361EE).withOpacity(0.7),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Thinking...',
                    style: TextStyle(
                      color: Color(0xFF212529),
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
            const SizedBox(width: 52), // Spacer for user messages

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
                      color: isAI ? const Color(0xFF212529) : Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(message.timestamp),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6C757D),
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
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (messageDate == today) {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 60, color: Colors.red),
            const SizedBox(height: 20),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF6C757D),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final provider = Provider.of<AIAssistantProvider>(context, listen: false);
                provider.initialize();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lightbulb_outline, size: 80, color: Color(0xFF4361EE)),
            const SizedBox(height: 20),
            const Text(
              'AI Learning Assistant',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212529),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Ask me anything about your studies!\nI can explain concepts, solve problems,\nand create study plans.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF6C757D),
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: FirebaseAIService.quickPrompts.map((prompt) {
                return ActionChip(
                  label: Text(prompt['title']),
                  avatar: Text(prompt['icon']),
                  onPressed: () {
                    _messageController.text = prompt['prompt'].toString();
                    _sendMessage();
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF4361EE),
        elevation: 4,
        title: const Row(
          children: [
            Icon(Icons.smart_toy, size: 24),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Learning Assistant',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '24/7 Study Help',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _showQuickActions(context),
            icon: const Icon(Icons.bolt, color: Colors.white),
            tooltip: 'Quick Actions',
          ),
          IconButton(
            onPressed: () {
              final provider = Provider.of<AIAssistantProvider>(context, listen: false);
              provider.createNewConversation();
            },
            icon: const Icon(Icons.add, color: Colors.white),
            tooltip: 'New Chat',
          ),
        ],
      ),
      body: Consumer<AIAssistantProvider>(
        builder: (context, provider, child) {
          // Handle different states
          switch (provider.state) {
            case AIAssistantState.initializing:
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 20),
                    const Text(
                      'Initializing AI Assistant...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF6C757D),
                      ),
                    ),
                  ],
                ),
              );

            case AIAssistantState.disconnected:
            case AIAssistantState.error:
              return _buildErrorState(provider.errorMessage ?? 'An error occurred');

            case AIAssistantState.ready:
            case AIAssistantState.loading:
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
                      border: Border(top: BorderSide(color: Colors.grey[200]!)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: InputDecoration(
                              hintText: 'Type your question here...',
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
                              suffixIcon: IconButton(
                                onPressed: _sendMessage,
                                icon: Icon(
                                  Icons.send,
                                  color: _messageController.text.trim().isNotEmpty
                                      ? const Color(0xFF4361EE)
                                      : Colors.grey[400],
                                ),
                              ),
                            ),
                            maxLines: 5,
                            minLines: 1,
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
          }
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
