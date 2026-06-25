import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DeleteProfilePage extends StatelessWidget {
  const DeleteProfilePage({super.key});

  /// Kullanıcı hesabını ve alt koleksiyonlarını sil
  Future<void> _deleteUserAccount(BuildContext context) async {
    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;
    final user = auth.currentUser;

    if (user == null) return;

    final userDocRef = firestore.collection('users').doc(user.uid);

    // Silinecek alt koleksiyonlar
    final subcollections = ['subscriptions', 'discounts', 'logs'];

    try {
      // Alt koleksiyonları sil
      for (final sub in subcollections) {
        final snap = await userDocRef.collection(sub).get();
        for (final doc in snap.docs) {
          await doc.reference.delete();
        }
      }

      // Ana kullanıcı dokümanını sil
      await userDocRef.delete();

      // Firebase Auth hesabını sil
      await user.delete();

      
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Hata: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDarkMode ? Colors.white : Colors.black,
        ),
        title: Text(
          "Hesabı Sil",
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_forever,
                size: 100, color: Colors.red.withOpacity(0.8)),
            const SizedBox(height: 20),
            Text(
              "Hesabınızı kalıcı olarak silmek üzeresiniz.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Bu işlem geri alınamaz. Tüm verileriniz silinecek.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.warning_amber_rounded),
                label: const Text(
                  "Hesabı Kalıcı Olarak Sil",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Emin misiniz?"),
                      content: const Text(
                          "Bu işlem geri alınamaz. Tüm verileriniz kalıcı olarak silinecek."),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("İptal"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text(
                            "Sil",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    await _deleteUserAccount(context);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
