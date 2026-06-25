import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/models/invoice.dart';
import '/models/invoicepdf.dart';

class AllInvoices extends StatefulWidget {
  const AllInvoices({Key? key}) : super(key: key);

  @override
  State<AllInvoices> createState() => _AllInvoicesState();
}

class _AllInvoicesState extends State<AllInvoices> {
  late final String userId;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  Stream<List<Invoice>> _fetchInvoices() {
    return FirebaseFirestore.instance
        .collection('invoices')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Invoice.fromDocument(doc)).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Faturalarım',
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
        stream: _fetchInvoices(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }

          final invoices = snapshot.data;

          if (invoices == null || invoices.isEmpty) {
            return const Center(child: Text('Fatura bulunamadı.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: invoices.length,
            itemBuilder: (context, index) {
              final invoice = invoices[index];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 10),
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                     
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              invoice.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color:
                                  invoice.isPaid ? Colors.green : Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              invoice.isPaid ? 'Ödendi' : 'Ödenmedi',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      
                      Text(
                        'Tutar: ₺${invoice.amount.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Kesim Tarihi: ${invoice.cutOffDate.toLocal().toString().split(' ')[0]}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Son Ödeme Tarihi: ${invoice.dueDate.toLocal().toString().split(' ')[0]}',
                        style: const TextStyle(fontSize: 16),
                      ),

                      const SizedBox(height: 16),

                      
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 3,
                          ),
                          icon: const Icon(Icons.picture_as_pdf, size: 22),
                          label: const Text(
                            "PDF İndir",
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                          onPressed: () {
                            generateInvoicePdf(invoice);
                          },
                        ),
                      ),
                    ],
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
