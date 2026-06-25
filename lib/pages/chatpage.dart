import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<Map<String, String>> messages = [];
  late Future<List<Map<String, String>>> qaFuture;
  String userName = "Kullanıcı"; 

  @override
  void initState() {
    super.initState();
    _loadUserName(); 
    qaFuture = getChatData();
  }

  Future<void> _loadUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final data = doc.data();
    if (data != null) {
      setState(() {
        userName = data['name'] ?? "Kullanıcı";
        // Hoşgeldiniz mesajını ekle
        messages.add({"type": "bot", "text": "Hoşgeldin $userName!😊"});
      });
    }
  }

  Future<List<Map<String, String>>> getChatData() async {
    final snapshot = await FirebaseFirestore.instance.collection("chat").get();
    return snapshot.docs.map((doc) {
      return {
        "question": doc["question"] as String,
        "answer": doc["answer"] as String,
      };
    }).toList();
  }

  /// Kullanıcı bir soruya tıklayınca hem mesajlara ekler hem Firestore log kaydeder
  void handleQuestion(Map<String, String> qa) async {
    setState(() {
      messages.add({"type": "user", "text": qa["question"]!});
      messages.add({"type": "bot", "text": qa["answer"]!});
    });

    // Firestore log kaydı
    await _logQuestionClick(qa["question"]!);
  }

  Future<void> _logQuestionClick(String question) async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final logRef = FirebaseFirestore.instance.collection("chatlogs").doc(today);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(logRef);

      if (!snapshot.exists) {
        // Eğer bugün için döküman yoksa, yeni oluştur
        transaction.set(logRef, {
          question: 1,
        });
      } else {
        final data = snapshot.data()!;
        final currentCount = (data[question] ?? 0) as int;
        transaction.update(logRef, {
          question: currentCount + 1,
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Fluxa Asistan",
          style: TextStyle(fontWeight: FontWeight.bold,
          color : Colors.white,
          ),
        
        ),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE53935), Color(0xFFFF7043)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Mesaj Listesi
            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  final isUser = msg["type"] == "user";

                  return Align(
                    alignment: isUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7),
                      decoration: BoxDecoration(
                        gradient: isUser
                            ? const LinearGradient(
                                colors: [Color(0xFFE53935), Color(0xFFFF7043)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: isUser ? null : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: Radius.circular(isUser ? 16 : 0),
                          bottomRight: Radius.circular(isUser ? 0 : 16),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        msg["text"]!,
                        style: TextStyle(
                          color: isUser ? Colors.white : Colors.black87,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            FutureBuilder<List<Map<String, String>>>(
              future: qaFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text(
                    "Henüz soru eklenmemiş.",
                    style: TextStyle(color: Colors.black54),
                  );
                }

                final qaPairs = snapshot.data!;

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: qaPairs.map((qa) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: OutlinedButton(
                          onPressed: () => handleQuestion(qa),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: Color(0xFFE53935), width: 1.5),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFFE53935),
                            textStyle: const TextStyle(
                                fontWeight: FontWeight.w600),
                          ),
                          child: Text(qa["question"]!),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
