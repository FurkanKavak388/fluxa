import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/activitylogs/pwchangelog.dart'; 

class PassChangePage extends StatefulWidget {
  const PassChangePage({Key? key}) : super(key: key);

  @override
  State<PassChangePage> createState() => _PassChangePageState();
}

class _PassChangePageState extends State<PassChangePage> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  final Color primaryColor = Colors.red.shade600;

  Future<void> _changePassword() async {
    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        _errorMessage = "Lütfen tüm alanları doldurun.";
      });
      return;
    }

    if (newPassword != confirmPassword) {
      setState(() {
        _errorMessage = "Yeni şifre ve tekrar şifre eşleşmiyor.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        setState(() {
          _errorMessage = "Kullanıcı oturumu bulunamadı.";
        });
        return;
      }

      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPassword);

      
      await PasswordChangeLogger.logPasswordChange();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Şifre başarıyla değiştirildi.')),
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String msg;
      if (e.code == 'wrong-password') {
        msg = "Mevcut şifre yanlış.";
      } else if (e.code == 'weak-password') {
        msg = "Yeni şifre çok zayıf.";
      } else {
        msg = e.message ?? "Bir hata oluştu.";
      }
      setState(() {
        _errorMessage = msg;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Beklenmeyen bir hata oluştu.";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.red.shade300),
      filled: true,
      fillColor: Colors.red.shade50,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade700, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade900, width: 2),
      ),
    );
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _currentPasswordController,
              decoration: _inputDecoration('Mevcut Şifrenizi Girin'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _newPasswordController,
              decoration: _inputDecoration('Yeni Şifrenizi Girin'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              decoration: _inputDecoration('Yeni Şifrenizi Tekrar Girin'),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.w600),
              ),
            if (_errorMessage != null) const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isLoading ? null : _changePassword,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.red)
                    : const Text(
                        'Şifreyi Değiştir',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
