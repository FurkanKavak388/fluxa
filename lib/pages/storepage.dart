
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/models/product.dart';
import '/models/usermodel.dart';

class StorePage extends StatefulWidget {
  const StorePage({Key? key}) : super(key: key);

  @override
  _StorePageState createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  String searchQuery = '';
  String sortOption = 'Fiyata Göre Artan';

  Stream<UserModel> fetchUser() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => UserModel.fromMap(doc.data()!));
  }

  Stream<List<Product>> fetchProducts() {
    return FirebaseFirestore.instance
        .collection('products')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromMap(doc.data(), doc.id))
            .toList());
  }

  String generateRandomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random();
    String block(int length) =>
        List.generate(length, (_) => chars[rand.nextInt(chars.length)]).join();
    return '${block(4)}-${block(4)}-${block(4)}';
  }

  Future<void> buyProduct(UserModel user, Product product) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    if (user.points < product.price) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('❌ Yetersiz puan!')),
      );
      return;
    }

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);

    try {
      await userRef.update({'points': user.points - product.price});

      if (product.type == ProductType.discountCoupon) {
        final expiryDate = DateTime.now().add(const Duration(days: 7));
        await userRef.collection('discounts').add({
          'productId': product.id,
          'productName': product.name,
          'discount': product.extraData?['discount'] ?? 0,
          'expiryDate': expiryDate,
          'used': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else if (product.type == ProductType.singleUseCode) {
        final randomCode = generateRandomCode();
        await userRef.collection('codes').add({
          'productId': product.id,
          'productName': product.name,
          'code': randomCode,
          'createdAt': FieldValue.serverTimestamp(),
        });
        if (!mounted) return;
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('✅ Kodunuz: $randomCode')),
        );
      }

      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('✅ ${product.name} satın alındı!')),
      );
    } catch (e) {
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('❌ Satın alma hatası: $e')),
      );
    }
  }

  List<Product> filterAndSortProducts(List<Product> products) {
    List<Product> filtered = products
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
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return StreamBuilder<UserModel>(
      stream: fetchUser(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) {
          return const Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final user = userSnapshot.data!;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            children: [
             
              SizedBox(height: statusBarHeight * 0.2),

              // Puan Kartı
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Card(
                  color: Colors.red,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.monetization_on,
                                color: Colors.amber, size: 20),
                            const SizedBox(width: 6),
                            Text(
                              '${user.points} Puan',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.help_outline,
                              color: Colors.white, size: 20),
                          splashRadius: 20,
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                title: const Text('Puan Sistemi'),
                                content: const Text(
                                    'Puanlarınızı mağazada ürün almak için kullanabilirsiniz.'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context),
                                    child: const Text('Tamam'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Arama ve Sıralama
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Ürün ara...',
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.9),
                          prefixIcon:
                              const Icon(Icons.search, color: Colors.amber),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 16),
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
                        color: Colors.white.withOpacity(0.9),
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
                          icon: const Icon(Icons.arrow_drop_down,
                              color: Colors.amber),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Ürün Listesi
              Expanded(
                child: StreamBuilder<List<Product>>(
                  stream: fetchProducts(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                          child: Text('Henüz ürün eklenmemiş.'));
                    }

                    final products =
                        filterAndSortProducts(snapshot.data!);

                    return GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.78,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    Colors.black.withOpacity(0.03),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 16),
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Image.network(product.imageUrl,
                                  height: 56,
                                  errorBuilder:
                                      (context, error, stackTrace) {
                                return const Icon(
                                    Icons.image_not_supported,
                                    size: 56,
                                    color: Colors.grey);
                              }),
                              const SizedBox(height: 8),
                              Text(
                                product.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                product.type ==
                                        ProductType.discountCoupon
                                    ? '💰 ${product.price} puan\n%${product.extraData?['discount'] ?? 0} indirim'
                                    : '💰 ${product.price} puan',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Colors.amber.shade700,
                                    foregroundColor: Colors.white,
                                    padding:
                                        const EdgeInsets.symmetric(
                                            vertical: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(20),
                                    ),
                                    textStyle:
                                        const TextStyle(fontSize: 13),
                                  ),
                                  onPressed: () =>
                                      buyProduct(user, product),
                                  child: const Text('Satın Al'),
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
              const SizedBox(height: 60),
            ],
          ),
        );
      },
    );
  }
}
