import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  String? _message;
  bool _loading = false;

  final Color primaryColor = Colors.red;
  final Color primaryColorDark = Colors.red;
  final Color fillColor = Colors.red.shade50;

  Future<void> _resetPassword() async {
    setState(() {
      _loading = true;
      _message = null;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      setState(() {
        _message = "✅ Şifre sıfırlama linki e-posta adresinize gönderildi.";
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        _message = "⚠️ ${e.message}";
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  OutlineInputBorder _inputBorder(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: color, width: 2),
      );

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: fillColor,
      border: _inputBorder(Colors.transparent),
      enabledBorder: _inputBorder(Colors.transparent),
      focusedBorder: _inputBorder(primaryColor),
      errorBorder: _inputBorder(Colors.redAccent),
      focusedErrorBorder: _inputBorder(const Color(0xFFFFD752)),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      labelStyle: TextStyle(color: primaryColorDark, fontWeight: FontWeight.w600),
    );
  }

  Widget _animatedButton({required Widget child, required VoidCallback? onTap}) {
    final bool disabled = onTap == null;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 52,
      decoration: BoxDecoration(
        color: disabled ? Colors.red.shade100 : primaryColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: disabled
            ? []
            : [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: onTap,
          splashColor: primaryColorDark.withOpacity(0.3),
          highlightColor: primaryColorDark.withOpacity(0.1),
          child: Center(child: child),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Şifremi Unuttum"),
        backgroundColor: Colors.amber,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Text(
                  "E-posta adresinizi girin. Size şifre sıfırlama bağlantısı göndereceğiz.",
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration("E-posta"),
                ),
                const SizedBox(height: 24),
                _animatedButton(
                  onTap: _loading ? null : _resetPassword,
                  child: _loading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                        )
                      : const Text(
                          "Gönder",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                ),
                if (_message != null) ...[
                  const SizedBox(height: 24),
                  Text(
                    _message!,
                    style: TextStyle(color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
