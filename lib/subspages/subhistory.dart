import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/models/subscription.dart';

class SubHistoryPage extends StatefulWidget {
  const SubHistoryPage({super.key});

  @override
  State<SubHistoryPage> createState() => _SubHistoryPageState();
}

class _SubHistoryPageState extends State<SubHistoryPage> {
  String searchQuery = '';
  DateTime? filterDate;

  Stream<List<Subscription>> _getUserExpiredSubscriptions() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('subscriptions')
        .where('userIsActive', isEqualTo: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Subscription.fromFirestore(doc)).toList());
  }

  List<Subscription> _filterAndSearch(List<Subscription> subs) {
    return subs.where((sub) {
      final matchesName = sub.name.toLowerCase().contains(searchQuery.toLowerCase().trim());
      final matchesDate = filterDate == null
    ? true
    : sub.expiresAt != null &&
      sub.expiresAt!.toDate().year == filterDate!.year &&
      sub.expiresAt!.toDate().month == filterDate!.month &&
      sub.expiresAt!.toDate().day == filterDate!.day;

      return matchesName && matchesDate;
    }).toList();
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: filterDate ?? now,
      firstDate: DateTime(2000),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        filterDate = picked;
      });
    }
  }

  void _clearDateFilter() {
    setState(() {
      filterDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Abonelik Geçmişim'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Arama ve tarih filtresi
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Abonelik ara...',
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                      prefixIcon: const Icon(Icons.search, color: Colors.red),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => _pickDate(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(
                          filterDate != null
                              ? '${filterDate!.day}.${filterDate!.month}.${filterDate!.year}'
                              : 'Tarih filtresi',
                          style: const TextStyle(color: Colors.black87),
                        ),
                        if (filterDate != null) ...[
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: _clearDateFilter,
                            child: const Icon(Icons.clear, size: 18, color: Colors.red),
                          )
                        ]
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: StreamBuilder<List<Subscription>>(
              stream: _getUserExpiredSubscriptions(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text('Geçmiş aboneliğiniz bulunmamaktadır.'));
                }

                final subs = _filterAndSearch(snapshot.data!);

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: subs.length,
                  itemBuilder: (context, index) {
                    final sub = subs[index];
                    final endDate = sub.expiresAt != null
                        ? sub.expiresAt!.toDate().toString().split(" ").first
                        : "—";

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                            child: sub.imageUrl.isNotEmpty
                                ? Image.network(
                                    sub.imageUrl,
                                    height: 140,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    height: 140,
                                    color: Colors.grey.shade300,
                                    child: const Icon(Icons.history,
                                        size: 50, color: Colors.red),
                                  ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sub.name,
                                  style: const TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Bitiş tarihi: $endDate',
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
          ),
        ],
      ),
    );
  }
}
