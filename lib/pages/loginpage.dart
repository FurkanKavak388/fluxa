import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/loginpages/registerpage.dart';
import '/loginpages/forgotpasswordpage.dart';
import 'dashboardpage.dart';
import '/loginpages/emailverification.dart';
import 'package:fluxa/models/logo.dart';
import '/activitylogs/loginlog.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  final Color primaryColor = Colors.red;

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      User? user = userCredential.user;
      if (user != null) {
        await user.reload();
        user = FirebaseAuth.instance.currentUser;

        if (user!.emailVerified) {
          await LoginLogger.logLogin(success: true);
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DashboardPage()),
          );
        } else {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MailVerificationPage()),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message ?? "Bir hata oluştu.";
      });
      await LoginLogger.logLogin(success: false, description: e.message);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  OutlineInputBorder _inputBorder(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color, width: 1.4),
      );

  InputDecoration _inputDecoration(String label, Color fillColor) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: fillColor,
      border: _inputBorder(Colors.transparent),
      enabledBorder: _inputBorder(Colors.transparent),
      focusedBorder: _inputBorder(primaryColor),
      errorBorder: _inputBorder(Colors.redAccent),
      focusedErrorBorder: _inputBorder(const Color(0xFFFFD752)),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
      labelStyle: const TextStyle(fontWeight: FontWeight.w600),
    );
  }

  Widget _gradientButton({
    required String text,
    required VoidCallback? onTap,
    double? width,
  }) {
    final bool disabled = onTap == null;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 52,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: disabled
            ? LinearGradient(
                colors: [Colors.red.withOpacity(0.5), Colors.amber.withOpacity(0.5)],
              )
            : const LinearGradient(
                colors: [Colors.amber, Colors.red],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          splashColor: Colors.white24,
          highlightColor: Colors.white10,
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: width != null ? width * 0.045 : 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _linkButton(
      {required String text, required VoidCallback onTap, double? fontSize}) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        minimumSize: const Size(double.infinity, 44),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        alignment: Alignment.center,
        foregroundColor: primaryColor,
        overlayColor: primaryColor.withOpacity(0.1),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: fontSize ?? 15,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final screenWidth = media.size.width;
    final screenHeight = media.size.height;
    final fillColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[850]!
        : Colors.red.shade50;

    return Scaffold(
      backgroundColor:
          Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: screenHeight * 0.05),

               
                SizedBox(
                  width: screenWidth * 0.4,
                  height: screenWidth * 0.4,
                  child: const AnimatedLogo(),
                ),

                SizedBox(height: screenHeight * 0.06),

                
                TextField(
                  controller: _emailController,
                  decoration: _inputDecoration('E-posta', fillColor),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: screenHeight * 0.025),

                
                TextField(
                  controller: _passwordController,
                  decoration: _inputDecoration('Şifre', fillColor),
                  obscureText: true,
                ),

                SizedBox(height: screenHeight * 0.015),

              
                Align(
                  alignment: Alignment.centerRight,
                  child: _linkButton(
                    text: "Şifrenizi mi unuttunuz?",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ForgotPasswordPage()),
                      );
                    },
                    fontSize: screenWidth * 0.038,
                  ),
                ),

                SizedBox(height: screenHeight * 0.03),

               
                if (_errorMessage != null)
                  Padding(
                    padding: EdgeInsets.only(bottom: screenHeight * 0.02),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                
                _gradientButton(
                  text: _isLoading ? "Yükleniyor..." : "Giriş Yap",
                  onTap: _isLoading ? null : _signIn,
                  width: screenWidth,
                ),

                SizedBox(height: screenHeight * 0.03),

                
                Center(
                  child: _linkButton(
                    text: "Hesabın yok mu? Kayıt ol",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterPage()),
                      );
                    },
                    fontSize: screenWidth * 0.04,
                  ),
                ),

                SizedBox(height: screenHeight * 0.05),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
