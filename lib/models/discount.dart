
import 'package:cloud_firestore/cloud_firestore.dart';

class GrantedDiscount {
  final String id;
  final int discountPercent;
  final bool used;
  final DateTime expiryDate;

  GrantedDiscount({
    required this.id,
    required this.discountPercent,
    required this.used,
    required this.expiryDate,
  });

  factory GrantedDiscount.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;

    return GrantedDiscount(
      id: doc.id,
      discountPercent: data['discount'] ?? 0,
      used: data['used'] ?? false,
      expiryDate: (data['expiryDate'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'discount': discountPercent,
      'used': used,
      'expiryDate': Timestamp.fromDate(expiryDate),
    };
  }


  GrantedDiscount copyWith({
    String? id,
    int? discountPercent,
    bool? used,
    DateTime? expiryDate,
  }) {
    return GrantedDiscount(
      id: id ?? this.id,
      discountPercent: discountPercent ?? this.discountPercent,
      used: used ?? this.used,
      expiryDate: expiryDate ?? this.expiryDate,
    );
  }
}

