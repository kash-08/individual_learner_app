// lib/models/ai_message_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum AIMessageType { text, image, code }

class AIMessage {
  final String id;
  final String text;
  final String senderId;
  final String senderName;
  final DateTime timestamp;
  final AIMessageType type;
  final Map<String, dynamic>? metadata;
  final bool isAI;

  AIMessage({
    required this.id,
    required this.text,
    required this.senderId,
    required this.senderName,
    required this.timestamp,
    this.type = AIMessageType.text,
    this.metadata,
    required this.isAI,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'text': text,
      'senderId': senderId,
      'senderName': senderName,
      'timestamp': Timestamp.fromDate(timestamp),
      'type': type.name,
      'metadata': metadata ?? {},
      'isAI': isAI,
    };
  }

  static AIMessage fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AIMessage(
      id: data['id'],
      text: data['text'],
      senderId: data['senderId'],
      senderName: data['senderName'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      type: AIMessageType.values.firstWhere(
            (e) => e.name == data['type'],
        orElse: () => AIMessageType.text,
      ),
      metadata: data['metadata'],
      isAI: data['isAI'] ?? false,
    );
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

  AIConversation({
    required this.id,
    required this.userId,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.messageCount,
    required this.isArchived,
    required this.tags,
  });

  static AIConversation fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AIConversation(
      id: data['id'],
      userId: data['userId'],
      title: data['title'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      messageCount: data['messageCount'] ?? 0,
      isArchived: data['isArchived'] ?? false,
      tags: List<String>.from(data['tags'] ?? []),
    );
  }
}