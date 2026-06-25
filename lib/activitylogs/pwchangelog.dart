
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PasswordChangeLogger {
  /// Kullanıcı şifre değiştirdiğinde log kaydı oluşturur
  
  static Future<void> logPasswordChange({String? description}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final log = {
      "type": "password_change",
      "description": description ?? "Kullanıcı şifresini değiştirdi",
      "timestamp": FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("logs")
        .add(log);
  }
}
