import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '/models/discount.dart'; 
import 'applydiscounttoinvoicepage.dart';

class GrantedDiscountsPage extends StatefulWidget {
  const GrantedDiscountsPage({Key? key}) : super(key: key);

  @override
  State<GrantedDiscountsPage> createState() => _GrantedDiscountsPageState();
}

class _GrantedDiscountsPageState extends State<GrantedDiscountsPage>
    with SingleTickerProviderStateMixin {
  List<GrantedDiscount> discounts = [];
  bool loading = true;

  final User? user = FirebaseAuth.instance.currentUser;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);

    if (user != null) {
      fetchDiscounts();
    } else {
      loading = false;
    }
  }

  Future<void> fetchDiscounts() async {
    setState(() {
      loading = true;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('discounts')
          .orderBy('expiryDate')
          .get();

      final loadedDiscounts =
          snapshot.docs.map((doc) => GrantedDiscount.fromFirestore(doc)).toList();

      setState(() {
        discounts = loadedDiscounts;
        loading = false;
      });

      
      
        
      
    } catch (e) {
      print('İndirimler yüklenirken hata oluştu: $e');
      setState(() {
        discounts = [];
        loading = false;
      });
    }
  }

  Future<void> markDiscountUsed(GrantedDiscount discount) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('discounts')
        .doc(discount.id)
        .update({'used': true});

    setState(() {
      discounts = discounts.map((d) {
        return d.id == discount.id ? d.copyWith(used: true) : d;
      }).toList();
    });
  }

  Widget _buildDiscountCard(GrantedDiscount discount) {
    final expired = discount.expiryDate.isBefore(DateTime.now());
    final canUse = !discount.used && !expired;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      color: discount.used
          ? Colors.grey[300]
          : expired
              ? Colors.grey[200]
              : Colors.white,
      child: ListTile(
        leading: Icon(
          discount.used
              ? Icons.check_circle
              : expired
                  ? Icons.timer_off
                  : Icons.local_offer,
          color: discount.used
              ? Colors.green
              : expired
                  ? Colors.grey
                  : Colors.blue,
          size: 32,
        ),
        title: Text(
          '%${discount.discountPercent} İndirim',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: discount.used || expired ? Colors.grey : Colors.black,
          ),
        ),
        subtitle: Text(
          'Son Kullanma Tarihi: ${discount.expiryDate.toLocal().toString().split(' ')[0]}',
          style: TextStyle(
            color: discount.used || expired ? Colors.grey : Colors.black54,
          ),
        ),
        trailing: ElevatedButton(
          onPressed: canUse
              ? () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ApplyDiscountToInvoicePage(discount: discount),
                    ),
                  );

                  if (result == true) {
                    await fetchDiscounts();
                  }
                }
              : null,
          child: const Text('Kullan'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('İndirimler')),
        body: const Center(child: Text('Lütfen giriş yapınız.')),
      );
    }

    // İndirimleri kesinlikle iki listeye ayır
    final usedDiscounts = discounts.where((d) => d.used == true).toList();
    final unusedDiscounts = discounts.where((d) => d.used == false).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kazanılan İndirimler'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Kullanılmamış'),
            Tab(text: 'Kullanılmış'),
          ],
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                unusedDiscounts.isEmpty
                    ? const Center(child: Text('Kullanılmamış indirim bulunamadı.'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: unusedDiscounts.length,
                        itemBuilder: (context, index) =>
                            _buildDiscountCard(unusedDiscounts[index]),
                      ),
                usedDiscounts.isEmpty
                    ? const Center(child: Text('Kullanılmış indirim bulunamadı.'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: usedDiscounts.length,
                        itemBuilder: (context, index) =>
                            _buildDiscountCard(usedDiscounts[index]),
                      ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
