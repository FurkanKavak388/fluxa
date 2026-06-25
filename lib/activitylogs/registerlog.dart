
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterLogger {
  /// Kullanıcı kayıt olduktan sonra log kaydı oluşturur
  static Future<void> logRegister({bool success = true}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final log = {
      "type": "register",
      "description": success
          ? "Kullanıcı kayıt oldu"
          : "Kullanıcı kayıt olmaya çalıştı ama hata oluştu",
      "timestamp": FieldValue.serverTimestamp(),
      "success": success,
    };

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("logs")
        .add(log);
  }
}
