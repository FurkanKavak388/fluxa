import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/models/subscription.dart';

class AllSubscriptionPlansPage extends StatefulWidget {
  const AllSubscriptionPlansPage({super.key});

  @override
  State<AllSubscriptionPlansPage> createState() =>
      _AllSubscriptionPlansPageState();
}

class _AllSubscriptionPlansPageState extends State<AllSubscriptionPlansPage> {
  String searchQuery = '';
  String sortOption = 'Fiyata Göre Artan';

  Stream<List<Subscription>> _getAvailablePlans() {
    return FirebaseFirestore.instance
        .collection('subscriptions')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Subscription.fromFirestore(doc)).toList());
  }

  Future<void> _purchasePlan(BuildContext context, Subscription plan) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Lütfen giriş yapın.")),
        );
      }
      return;
    }

    final userSubsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('subscriptions');

    final existingSubQuery = await userSubsRef
        .where('planId', isEqualTo: plan.id)
        .where('userIsActive', isEqualTo: true)
        .get();

    if (existingSubQuery.docs.isNotEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Bu abonelik zaten aktif!")),
        );
      }
      return;
    }

    final now = DateTime.now();
    final endDate = now.add(Duration(days: plan.durationDays));

    await userSubsRef.add({
      'planId': plan.id,
      'name': plan.name,
      'price': plan.price,
      'durationDays': plan.durationDays,
      'imageUrl': plan.imageUrl,
      'createdAt': plan.createdAt,
      'updatedAt': Timestamp.now(),
      'userIsActive': true,
      'startedAt': Timestamp.fromDate(now),
      'expiresAt': Timestamp.fromDate(endDate),
    });

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${plan.name} aboneliği başlatıldı!")),
      );
    }
  }

  List<Subscription> _filterAndSort(List<Subscription> plans) {
    List<Subscription> filtered = plans
        .where((p) =>
            p.name.toLowerCase().contains(searchQuery.toLowerCase().trim()))
        .toList();

    if (sortOption == 'Fiyata Göre Artan') {
      filtered.sort((a, b) => a.price.compareTo(b.price));
    } else if (sortOption == 'Fiyata Göre Azalan') {
      filtered.sort((a, b) => b.price.compareTo(a.price));
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Tüm Abonelik Planları'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Arama ve Sıralama
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Plan ara...',
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.search, color: Colors.red),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: sortOption,
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      items: [
                        'Fiyata Göre Artan',
                        'Fiyata Göre Azalan'
                      ]
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            sortOption = value;
                          });
                        }
                      },
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Plan Listesi
          Expanded(
            child: StreamBuilder<List<Subscription>>(
              stream: _getAvailablePlans(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child:
                        Text('Satın alınabilir abonelik planı bulunmamaktadır.'),
                  );
                }

                final plans = _filterAndSort(snapshot.data!);

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: plans.length,
                  itemBuilder: (context, index) {
                    final plan = plans[index];
                    return Card(
                      margin:
                          const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
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
                            child: plan.imageUrl.isNotEmpty
                                ? Image.network(
                                    plan.imageUrl,
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
                                  plan.name,
                                  style: const TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${plan.price.toStringAsFixed(2)} ₺ / ${plan.durationDays} gün',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 12),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 12),
                                    ),
                                    onPressed: () => _purchasePlan(context, plan),
                                    child: const Text(
                                      'Aboneliği Başlat',
                                      style: TextStyle(fontSize: 14),
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
          ),
        ],
      ),
    );
  }
}
