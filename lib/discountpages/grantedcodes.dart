import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GrantedCodesPage extends StatefulWidget {
  const GrantedCodesPage({Key? key}) : super(key: key);

  @override
  State<GrantedCodesPage> createState() => _GrantedCodesPageState();
}

class _GrantedCodesPageState extends State<GrantedCodesPage> {
  List<Map<String, dynamic>> codes = [];
  bool loading = true;

  final User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();

    if (user != null) {
      fetchCodes();
    } else {
      loading = false;
    }
  }

  Future<void> fetchCodes() async {
    setState(() => loading = true);

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('codes')
          .orderBy('createdAt', descending: true)
          .get();

      final loadedCodes = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'code': doc['code'],
          'productName': doc['productName'] ?? 'Bilinmeyen Ürün',
          'createdAt': (doc['createdAt'] as Timestamp).toDate(),
        };
      }).toList();

      setState(() {
        codes = loadedCodes;
        loading = false;
      });
    } catch (e) {
      print('Kodlar yüklenirken hata: $e');
      setState(() {
        codes = [];
        loading = false;
      });
    }
  }

  Widget _buildCodeCard(Map<String, dynamic> codeData) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ListTile(
        leading: const Icon(Icons.qr_code, color: Colors.blue, size: 32),
        title: Text(
          codeData['code'] ?? 'Bilinmeyen Kod',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(
          'Ürün: ${codeData['productName']}\n'
          'Oluşturulma: ${codeData['createdAt'].toLocal().toString().split(' ')[0]}',
          style: const TextStyle(color: Colors.black54),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.copy, color: Colors.grey),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: codeData['code']));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Kod kopyalandı ✅')),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Kodlarım')),
        body: const Center(child: Text('Lütfen giriş yapınız.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Satın Alınan Kodlar')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : codes.isEmpty
              ? const Center(child: Text('Hiç kod bulunamadı.'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: codes.length,
                  itemBuilder: (context, index) =>
                      _buildCodeCard(codes[index]),
                ),
    );
  }
}
