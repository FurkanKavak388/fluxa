import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  bool _isEditing = false;
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  Map<String, dynamic>? _userData;

  final Color primaryColor = Colors.red.shade600;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadUserData();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final data = doc.data();
    if (data != null) {
      setState(() {
        _userData = data;
        _nameController.text = data['name'] ?? '';
        _surnameController.text = data['surname'] ?? '';
      });
      _animController.forward();
    }
  }

  Future<void> _saveChanges() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'name': _nameController.text.trim(),
      'surname': _surnameController.text.trim(),
    });

    setState(() {
      _isEditing = false;
      _userData!['name'] = _nameController.text.trim();
      _userData!['surname'] = _surnameController.text.trim();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Bilgiler güncellendi!")),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil"),
        backgroundColor: Colors.amber,
      ),
      body: _userData == null
          ? const Center(child: CircularProgressIndicator())
          : FadeTransition(
              opacity: _fadeAnimation,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: primaryColor,
                      child: const Icon(Icons.person, size: 50, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Düzenle/Kaydet butonu
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (_isEditing) {
                          _saveChanges();
                        } else {
                          setState(() {
                            _isEditing = true;
                          });
                        }
                      },
                      icon: Icon(
                        _isEditing ? Icons.check : Icons.edit,
                        size: 20,
                        color: Colors.white, // ikon beyaz
                      ),
                      label: Text(
                        _isEditing ? "Kaydet" : "Düzenle",
                        style: const TextStyle(color: Colors.white), // yazı beyaz
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _animatedCard(
                    child: _isEditing
                        ? _editableTile("İsim", _nameController)
                        : _infoTile("İsim", _userData!['name']),
                  ),
                  _animatedCard(
                    child: _isEditing
                        ? _editableTile("Soyisim", _surnameController)
                        : _infoTile("Soyisim", _userData!['surname']),
                  ),
                  _animatedCard(child: _infoTile("Email", _userData!['email'])),
                  _animatedCard(child: _infoTile("Doğum Tarihi", _userData!['birthDate'])),
                  _animatedCard(child: _infoTile("Telefon", "+${_userData!['phone']}")),
                ],
              ),
            ),
    );
  }

  Widget _animatedCard({required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }

  Widget _infoTile(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget _editableTile(String title, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: title,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
    );
  }
}
