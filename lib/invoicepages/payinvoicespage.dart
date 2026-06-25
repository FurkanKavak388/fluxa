import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/models/invoice.dart';
import '/models/payment.dart';

class PayInvoicesPage extends StatefulWidget {
  const PayInvoicesPage({Key? key}) : super(key: key);

  @override
  State<PayInvoicesPage> createState() => _PayInvoicesPageState();
}

class _PayInvoicesPageState extends State<PayInvoicesPage> {
  late final String currentUserId;
  final Color primaryColor = const Color(0xFFE53935);

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  Stream<List<Invoice>> _myUnpaidInvoices() {
    return FirebaseFirestore.instance
        .collection('invoices')
        .where('userId', isEqualTo: currentUserId)
        .where('isPaid', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Invoice.fromDocument(doc)).toList());
  }

  
  Widget _buildInvoiceCard(Invoice invoice) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        title: Text(
          invoice.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 17,
            color: Colors.black,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tutar: ₺${invoice.amount.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 14, color: Colors.black87)),
              Text('Kesim Tarihi: ${invoice.cutOffDate.toLocal().toString().split(' ')[0]}',
                  style: const TextStyle(fontSize: 14, color: Colors.black87)),
              Text('Son Ödeme Tarihi: ${invoice.dueDate.toLocal().toString().split(' ')[0]}',
                  style: const TextStyle(fontSize: 14, color: Colors.black87)),
            ],
          ),
        ),
    trailing: ElevatedButton(
  onPressed: () async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentPage(invoice: invoice),
      ),
    );

   
    if (result == true) {
      setState(() {});
    }
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.green.shade600,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    elevation: 0,
  ),
  child: const Text(
    'Öde',
    style: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 14,
      color: Colors.white,
    ),
  ),
),

      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Fatura Öde',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<List<Invoice>>(
        stream: _myUnpaidInvoices(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Hata: ${snapshot.error}', style: TextStyle(color: textColor)),
            );
          }
          final invoices = snapshot.data;
          if (invoices == null || invoices.isEmpty) {
            return Center(
                child: Text('Ödenmemiş fatura bulunamadı.',
                    style: TextStyle(color: Colors.grey.shade500)));
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: invoices.length,
            itemBuilder: (context, index) => _buildInvoiceCard(invoices[index]),
          );
        },
      ),
    );
  }
}
