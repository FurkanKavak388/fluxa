import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/models/subscription.dart';

class ActiveSubsPage extends StatelessWidget {
  const ActiveSubsPage({super.key});

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

  int _remainingDays(Timestamp? expiresAt) {
    if (expiresAt == null) return 0;
    final now = DateTime.now();
    final expDate = expiresAt.toDate();
    return expDate.difference(now).inDays;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Aktif Aboneliklerim'),
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
            return const Center(
              child: Text('Aktif aboneliğiniz bulunmamaktadır.'),
            );
          }

          final activeSubs = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: activeSubs.length,
            itemBuilder: (context, index) {
              final sub = activeSubs[index];
              final remaining = _remainingDays(sub.expiresAt);

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                  
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
                            'Bitiş: ${sub.expiresAt != null ? sub.expiresAt!.toDate().toString().split(" ").first : "—"}\nKalan gün: $remaining',
                            style: const TextStyle(fontSize: 14),
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
