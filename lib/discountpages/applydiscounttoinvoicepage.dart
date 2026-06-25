import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/models/discount.dart';
import '/models/invoice.dart';

class ApplyDiscountToInvoicePage extends StatelessWidget {
  final GrantedDiscount discount;
  const ApplyDiscountToInvoicePage({Key? key, required this.discount}) : super(key: key);
  Future<List<Invoice>> fetchUserInvoices() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return [];
    final snapshot = await FirebaseFirestore.instance
        .collection('invoices')
        .where('userId', isEqualTo: userId)
        .where('isPaid', isEqualTo: false)
        .get();
    return snapshot.docs.map((doc) => Invoice.fromDocument(doc)).toList();
  }

  void applyDiscountToInvoice(BuildContext context, Invoice invoice) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final originalAmount = invoice.amount;
    final discountAmount = originalAmount * (discount.discountPercent / 100);
    final newAmount = originalAmount - discountAmount;

    // Onaylama penceresi
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('İndirimi Onayla'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Fatura: ${invoice.title}'),
            Text('Orijinal Tutar: ₺${originalAmount.toStringAsFixed(2)}'),
            Text('İndirim (%${discount.discountPercent}): ₺${discountAmount.toStringAsFixed(2)}'),
            const Divider(),
            Text(
              'Yeni Tutar: ₺${newAmount.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('İptal'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Onayla'),
            onPressed: () async {
             
              await FirebaseFirestore.instance
                  .collection('invoices')
                  .doc(invoice.id)
                  .update({'amount': newAmount});

             
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .collection('discounts')
                  .doc(discount.id)
                  .update({'used': true});

              Navigator.pop(context); 
              Navigator.pop(context, true); 

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('İndirim başarıyla uygulandı.')),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('İndirimi Uygula')),
      body: FutureBuilder<List<Invoice>>(
        future: fetchUserInvoices(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final invoices = snapshot.data ?? [];

          if (invoices.isEmpty) {
            return const Center(child: Text('Uygulanabilecek fatura bulunamadı.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: invoices.length,
            itemBuilder: (context, index) {
              final invoice = invoices[index];

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text(invoice.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tutar: ₺${invoice.amount.toStringAsFixed(2)}'),
                      const SizedBox(height: 4),
                      Builder(
                        builder: (_) {
                          final now = DateTime.now();
                          final diff = invoice.dueDate.difference(now).inDays;
                          if (diff < 0) {
                            return const Text(
                              'Son ödeme tarihi geçti',
                              style: TextStyle(color: Colors.redAccent),
                            );
                          } else if (diff == 0) {
                            return const Text(
                              'Son ödeme tarihi bugün',
                              style: TextStyle(color: Colors.orange),
                            );
                          } else {
                            return Text(
                              'Son ödemeye $diff gün kaldı',
                              style: const TextStyle(color: Colors.green),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () => applyDiscountToInvoice(context, invoice),
                    child: const Text('Uygula'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
