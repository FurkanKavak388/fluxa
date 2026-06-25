import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/models/subscription.dart';

class DeleteSubsPage extends StatelessWidget {
  const DeleteSubsPage({super.key});

  /// Giriş yapan kullanıcının aktif aboneliklerini çeker
  Stream<List<Subscription>> _getUserActiveSubscriptions() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('subscriptions')
        .where('userIsActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Subscription.fromFirestore(doc)).toList());
  }

  /// Abonelik iptal etme (userIsActive -> false + expiresAt -> now)
  Future<void> _cancelSubscription(BuildContext context, String subId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('subscriptions')
        .doc(subId)
        .update({
      'userIsActive': false,
      'expiresAt': Timestamp.now(),
    });

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Abonelik iptal edildi')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Abonelik İptal'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<List<Subscription>>(
        stream: _getUserActiveSubscriptions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('İptal edilecek abonelik yok.'));
          }

          final subs = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: subs.length,
            itemBuilder: (context, index) {
              final sub = subs[index];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Büyük görsel
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      child: sub.imageUrl.isNotEmpty
                          ? Image.network(
                              sub.imageUrl,
                              height: 180,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              height: 180,
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.subscriptions,
                                  size: 60, color: Colors.red),
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sub.name,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Bitiş: ${sub.expiresAt != null ? sub.expiresAt!.toDate().toString().split(" ").first : "—"}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14),
                              ),
                              onPressed: () =>
                                  _cancelSubscription(context, sub.id),
                              child: const Text(
                                'İptal Et',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
