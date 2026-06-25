import 'package:cloud_firestore/cloud_firestore.dart';

class Campaign {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final DateTime endDate;

  Campaign({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.endDate,
  });

  factory Campaign.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Campaign(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      endDate: (data['endDate'] as Timestamp).toDate(),
    );
  }
}
