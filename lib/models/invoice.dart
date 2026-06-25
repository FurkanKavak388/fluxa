import 'package:cloud_firestore/cloud_firestore.dart';

class Invoice {
  String? id;
  String userId;
  String title;
  double amount;
  DateTime cutOffDate; 
  DateTime dueDate;
  bool isPaid;

  Invoice({
    this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.cutOffDate, 
    required this.dueDate,
    this.isPaid = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'amount': amount,
      'cutOffDate': Timestamp.fromDate(cutOffDate), 
      'dueDate': Timestamp.fromDate(dueDate),
      'isPaid': isPaid,
    };
  }

  factory Invoice.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Invoice(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      amount: (data['amount'] as num).toDouble(),
      cutOffDate: (data['cutOffDate'] as Timestamp).toDate(), 
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      isPaid: data['isPaid'] ?? false,
    );
  }
}
