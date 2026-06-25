import 'package:cloud_firestore/cloud_firestore.dart';

class Story {
  final String id;
  final String title;
  final String imageUrl;
  final DateTime createdAt;
  final String buttonText;  
  final String buttonUrl;  

  Story({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.createdAt,
    required this.buttonText,
    required this.buttonUrl,
  });

  factory Story.fromMap(Map<String, dynamic> map) {
    final createdAtData = map['createdAt'];

    DateTime createdAt;
    if (createdAtData is Timestamp) {
      createdAt = createdAtData.toDate();
    } else if (createdAtData is String) {
      createdAt = DateTime.tryParse(createdAtData) ?? DateTime.now();
    } else {
      createdAt = DateTime.now();
    }

    return Story(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      createdAt: createdAt,
      buttonText: map['buttonText'] ?? 'Daha fazla',
      buttonUrl: map['buttonUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'buttonText': buttonText,
      'buttonUrl': buttonUrl,
    };
  }
}
