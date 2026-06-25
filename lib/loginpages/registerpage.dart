import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import '/models/usermodel.dart';
import '/activitylogs/registerlog.dart'; 

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _phoneController = TextEditingController(text: '90');

  DateTime? _selectedDate;
  bool _isLoading = false;
  String? _errorMessage;

  final Color primaryColor = Colors.redAccent;
  final Color primaryColorDark = Colors.red;
  final Color fillColor = Colors.red.shade50;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initialDate = DateTime(now.year - 18, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? initialDate,
      firstDate: DateTime(1900),
      lastDate: initialDate,
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _birthDateController.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final surname = _surnameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final birthDate = _birthDateController.text.trim();
    final phone = _phoneController.text.trim();

    if ([name, surname, email, password, confirmPassword, birthDate, phone]
        .any((e) => e.isEmpty)) {
      setState(() {
        _errorMessage = "Lütfen tüm alanları doldurun.";
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _errorMessage = "Şifreler eşleşmiyor.";
      });
      return;
    }

    if (phone.length != 12 || !RegExp(r'^90\d{10}$').hasMatch(phone)) {
      setState(() {
        _errorMessage =
            "Lütfen geçerli 12 haneli telefon numarası girin (90 ile başlamalı).";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final uid = userCredential.user?.uid;
      if (uid != null) {
        final user = UserModel(
          uid: uid,
          name: name,
          surname: surname,
          email: email,
          birthDate: birthDate,
          phone: phone,
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .set(user.toMap());

        
        await RegisterLogger.logRegister(success: true);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kayıt başarılı!')),
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });

    
      await RegisterLogger.logRegister(success: false);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  OutlineInputBorder _inputBorder(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: color, width: 2),
      );

  InputDecoration _inputDecoration(String label, {String? hintText}) {
    return InputDecoration(
      labelText: label,
      hintText: hintText,
      filled: true,
      fillColor: fillColor,
      border: _inputBorder(Colors.transparent),
      enabledBorder: _inputBorder(Colors.transparent),
      focusedBorder: _inputBorder(primaryColor),
      labelStyle:
          TextStyle(color: primaryColorDark, fontWeight: FontWeight.w600),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
    );
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
                    child:
                        CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                  )
                : Text(text,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _birthDateController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kayıt Ol'),
        backgroundColor: Colors.amber,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
                controller: _nameController,
                decoration: _inputDecoration('İsim')),
            const SizedBox(height: 14),
            TextField(
                controller: _surnameController,
                decoration: _inputDecoration('Soyisim')),
            const SizedBox(height: 14),
            TextField(
              controller: _emailController,
              decoration: _inputDecoration('Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 14),
            TextField(
                controller: _passwordController,
                decoration: _inputDecoration('Şifre'),
                obscureText: true),
            const SizedBox(height: 14),
            TextField(
                controller: _confirmPasswordController,
                decoration: _inputDecoration('Şifre Tekrar'),
                obscureText: true),
            const SizedBox(height: 14),
            TextField(
              controller: _birthDateController,
              readOnly: true,
              decoration: _inputDecoration('Doğum Tarihi').copyWith(
                suffixIcon: IconButton(
                  icon: Icon(Icons.calendar_today, color: primaryColorDark),
                  onPressed: _pickDate,
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _phoneController,
              decoration:
                  _inputDecoration('Telefon Numarası', hintText: '90XXXXXXXXXX'),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(12),
              ],
              onChanged: (value) {
                if (!value.startsWith('90')) {
                  _phoneController.text = '90';
                  _phoneController.selection =
                      TextSelection.collapsed(offset: 2);
                }
              },
            ),
            const SizedBox(height: 24),
            if (_errorMessage != null)
              Text(_errorMessage!,
                  style: const TextStyle(
                      color: Colors.red, fontWeight: FontWeight.w600)),
            if (_errorMessage != null) const SizedBox(height: 16),
            _animatedButton(
                text: 'Kayıt Ol', onTap: _isLoading ? null : _register),
          ],
        ),
      ),
    );
  }
}
