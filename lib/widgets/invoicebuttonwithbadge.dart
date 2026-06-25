import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/invoicepages/payinvoicespage.dart';

class UnpaidInvoiceCountWidget extends StatelessWidget {
  const UnpaidInvoiceCountWidget({super.key});

  Stream<int> _unpaidInvoiceCount() {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    return FirebaseFirestore.instance
        .collection('invoices')
        .where('userId', isEqualTo: currentUserId)
        .where('isPaid', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: _unpaidInvoiceCount(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
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
                MaterialPageRoute(builder: (_) => const PayInvoicesPage()),
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
                        colors: [Color.fromARGB(255, 255, 109, 98), Color.fromARGB(255, 177, 0, 0)], // red -> dark red
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Center(
                      child: Icon(Icons.receipt_long, size: 40, color: Colors.white),
                    ),
                  ),
                ),
               
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Faturalar",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "$count adet ödenmemiş fatura",
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Hemen ödeyebilirsiniz",
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
