import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/pages/dashboardpage.dart';

class MailVerificationPage extends StatefulWidget {
  const MailVerificationPage({Key? key}) : super(key: key);

  @override
  State<MailVerificationPage> createState() => _MailVerificationPageState();
}

class _MailVerificationPageState extends State<MailVerificationPage> {
  bool _isEmailVerified = false;
  bool _canResendEmail = true;
  bool _isLoading = false;
  Timer? _checkTimer;
  Timer? _resendTimer;

  int _resendCooldown = 0;
  double _resendProgress = 0.0;

  final Color primaryColor = Colors.red.shade600;
  final Color primaryColorDark = Colors.red.shade900;

  @override
  void initState() {
    super.initState();
    _checkEmailVerified();
    _checkTimer = Timer.periodic(const Duration(seconds: 5), (_) => _checkEmailVerified());
  }

  Future<void> _checkEmailVerified() async {
    User? user = FirebaseAuth.instance.currentUser;
    await user?.reload();
    setState(() {
      _isEmailVerified = user?.emailVerified ?? false;
    });

    if (_isEmailVerified) {
      _checkTimer?.cancel();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardPage()),
      );
    }
  }

  Future<void> _sendVerificationEmail() async {
    try {
      setState(() {
        _isLoading = true;
        _canResendEmail = false;
        _resendCooldown = 30;
        _resendProgress = 1.0; 
      });

      final user = FirebaseAuth.instance.currentUser;
      await user?.sendEmailVerification();

     
      _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (_resendCooldown > 1) {
            _resendCooldown--;
            _resendProgress = _resendCooldown / 30;
          } else {
            _resendCooldown = 0;
            _resendProgress = 0.0;
            _canResendEmail = true;
            timer.cancel();
          }
        });
      });
    } catch (e) {
      print("⚠️ Hata: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _animatedButton({required String text, required VoidCallback? onTap}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 52,
      decoration: BoxDecoration(
        color: onTap == null ? Colors.red.shade100 : primaryColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: onTap,
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                  )
                : Text(
                    text,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    _resendTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('E-Posta Doğrulama'),
        backgroundColor: Colors.amber,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              Icon(Icons.email_outlined, size: 90, color: primaryColor),
              const SizedBox(height: 24),
              const Text(
                "E-posta adresinizi doğrulayın",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                "Size gönderdiğimiz doğrulama e-postasına tıklayın.\nDoğrulayınca otomatik yönlendirileceksiniz.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              _animatedButton(
                text: "Doğrulama Mailini Gönder",
                onTap: _canResendEmail ? _sendVerificationEmail : null,
              ),
              const SizedBox(height: 16),
              if (!_canResendEmail)
                Column(
                  children: [
                    LinearProgressIndicator(
                      value: _resendProgress,
                      backgroundColor: Colors.red.shade100,
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                      minHeight: 6,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Tekrar göndermek için $_resendCooldown saniye bekleyin.",
                      style: TextStyle(color: primaryColorDark),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
