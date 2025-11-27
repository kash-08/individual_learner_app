import 'package:cloud_firestore/cloud_firestore.dart';

class Update {
  final String id;
  final String title;
  final String description;
  final String type; // 'course', 'article', 'news'
  final String? imageUrl;
  final DateTime publishDate;
  final String? category;
  final String? author;
  final String? readTime;
  final bool isNew;
  final Map<String, dynamic>? metadata;

  Update({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.imageUrl,
    required this.publishDate,
    this.category,
    this.author,
    this.readTime,
    this.isNew = true,
    this.metadata,
  });

  factory Update.fromMap(Map<String, dynamic> data) {
    return Update(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      type: data['type'] ?? 'news',
      imageUrl: data['imageUrl'],
      publishDate: data['publishDate'] != null
          ? (data['publishDate'] as Timestamp).toDate()
          : DateTime.now(),
      category: data['category'],
      author: data['author'],
      readTime: data['readTime'],
      isNew: data['isNew'] ?? true,
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'imageUrl': imageUrl,
      'publishDate': Timestamp.fromDate(publishDate),
      'category': category,
      'author': author,
      'readTime': readTime,
      'isNew': isNew,
      'metadata': metadata,
    };
  }
}