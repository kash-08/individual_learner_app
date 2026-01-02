// lib/models/ai_message_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum AIMessageType {
  text,
  image,
  question,
  answer,
  system,
  error,
}

class AIMessage {
  final String id;
  final String text;
  final String senderId;
  final String senderName;
  final DateTime timestamp;
  final AIMessageType type;
  final Map<String, dynamic>? metadata;
  final bool isAI;

  const AIMessage({
    required this.id,
    required this.text,
    required this.senderId,
    required this.senderName,
    required this.timestamp,
    this.type = AIMessageType.text,
    this.metadata,
    this.isAI = false,
  });

  factory AIMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AIMessage(
      id: doc.id,
      text: data['text'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? 'Unknown',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      type: _parseMessageType(data['type'] ?? 'text'),
      metadata: data['metadata'],
      isAI: data['senderId'] == 'ai',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'text': text,
      'senderId': senderId,
      'senderName': senderName,
      'timestamp': timestamp,
      'type': type.toString().split('.').last,
      'metadata': metadata,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  static AIMessageType _parseMessageType(String type) {
    switch (type.toLowerCase()) {
      case 'image':
        return AIMessageType.image;
      case 'question':
        return AIMessageType.question;
      case 'answer':
        return AIMessageType.answer;
      case 'system':
        return AIMessageType.system;
      case 'error':
        return AIMessageType.error;
      default:
        return AIMessageType.text;
    }
  }
}

class AIConversation {
  final String id;
  final String userId;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int messageCount;
  final bool isArchived;
  final List<String> tags;

  const AIConversation({
    required this.id,
    required this.userId,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.messageCount = 0,
    this.isArchived = false,
    this.tags = const [],
  });

  factory AIConversation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AIConversation(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? 'Untitled Conversation',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      messageCount: data['messageCount'] ?? 0,
      isArchived: data['isArchived'] ?? false,
      tags: List<String>.from(data['tags'] ?? []),
    );
  }
}