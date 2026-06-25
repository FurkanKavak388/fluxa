import 'package:cloud_firestore/cloud_firestore.dart';

class Subscription {
  final String id;              // Firestore doc id
  final String name;            // Abonelik adı
  final double price;           // Ücret
  final int durationDays;       // Süre (gün)
  final bool isActive;          // Plan aktif mi? (yeni alım yapılabilir mi?)
  final String imageUrl;        // Görsel URL'si
  final Timestamp createdAt;    // Oluşturulma
  final Timestamp updatedAt;    // Güncelleme

  
  final bool userIsActive;      // Kullanıcı aboneliği aktif mi?
  final Timestamp? startedAt;   // Kullanıcı abonelik başlangıcı
  final Timestamp? expiresAt;   // Kullanıcı abonelik bitiş tarihi

  Subscription({
    required this.id,
    required this.name,
    required this.price,
    required this.durationDays,
    required this.isActive,
    required this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.userIsActive,
    this.startedAt,
    this.expiresAt,
  });

  /// Firestore'dan veri çekerken
  factory Subscription.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return Subscription(
      id: doc.id,
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      durationDays: (data['durationDays'] ?? 30).toInt(),
      isActive: data['isActive'] ?? true,
      imageUrl: data['imageUrl'] ?? '',
      createdAt: (data['createdAt'] is Timestamp)
          ? data['createdAt']
          : Timestamp.now(),
      updatedAt: (data['updatedAt'] is Timestamp)
          ? data['updatedAt']
          : Timestamp.now(),
      userIsActive: data['userIsActive'] ?? false,
      startedAt: (data['startedAt'] is Timestamp)
          ? data['startedAt']
          : null,
      expiresAt: (data['expiresAt'] is Timestamp)
          ? data['expiresAt']
          : null,
    );
  }

  /// Abonelik bitmiş mi?
  bool get isExpired {
    if (expiresAt == null) return false;
    return expiresAt!.toDate().isBefore(DateTime.now());
  }

  /// Firestore'a kaydetmek için map formatı
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'durationDays': durationDays,
      'isActive': isActive,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'userIsActive': userIsActive,
      'startedAt': startedAt,
      'expiresAt': expiresAt,
    };
  }
}
