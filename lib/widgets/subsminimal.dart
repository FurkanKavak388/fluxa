import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/subspages/allsubsplans.dart'; 

class SubscriptionPlansWidget extends StatelessWidget {
  const SubscriptionPlansWidget({super.key});

  Stream<int> _plansCount() {
    return FirebaseFirestore.instance
        .collection('subscriptions')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: _plansCount(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        final count = snapshot.data ?? 0;
        if (count == 0) return const SizedBox.shrink();

        return Card(
          elevation: 4,
          margin: const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AllSubscriptionPlansPage(),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: Container(
                    height: 90,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.red, Colors.amber],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Center(
                      child: Icon(Icons.subscriptions,
                          size: 40, color: Colors.white),
                    ),
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Abonelik Planları",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "$count aktif plan mevcut",
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Detayları görüntüle",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
