
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginLogger {
  /// Kullanıcı login olduğunda log kaydı oluşturur
  /// success: login başarılı mı?
  
  static Future<void> logLogin({bool success = true, String? description}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final log = {
      "type": "login",
      "description": description ??
          (success ? "Kullanıcı giriş yaptı" : "Kullanıcı giriş yapmaya çalıştı ama hata oluştu"),
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
