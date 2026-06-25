
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String surname;
  final String email;
  final String birthDate;
  final String phone;
  final int points;
  final DateTime? createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.surname,
    required this.email,
    required this.birthDate,
    required this.phone,
    this.points = 0,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'surname': surname,
      'email': email,
      'birthDate': birthDate,
      'phone': phone,
      'points': points,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      surname: map['surname'] ?? '',
      email: map['email'] ?? '',
      birthDate: map['birthDate'] ?? '',
      phone: map['phone'] ?? '',
      points: map['points'] ?? 0,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : map['createdAt'],
    );
  }
}
