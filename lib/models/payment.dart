
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/models/invoice.dart';

class PaymentPage extends StatefulWidget {
  final Invoice invoice;

  const PaymentPage({Key? key, required this.invoice}) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  bool isProcessing = false;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Future<void> _processPayment() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => isProcessing = true);

    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(userId);

    
      await FirebaseFirestore.instance
          .collection('invoices')
          .doc(widget.invoice.id)
          .update({'isPaid': true});

    
      final userSnapshot = await userRef.get();
      final currentPoints = (userSnapshot.data()?['points'] ?? 0) as int;

     
      final addedPoints = (widget.invoice.amount * 0.05).floor();
      await userRef.update({'points': currentPoints + addedPoints});

      setState(() => isProcessing = false);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                '💳 Ödeme başarıyla tamamlandı! +$addedPoints puan kazandınız.')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      setState(() => isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    }
  }

  void onCreditCardModelChange(CreditCardModel data) {
    setState(() {
      cardNumber = data.cardNumber;
      expiryDate = data.expiryDate;
      cardHolderName = data.cardHolderName;
      cvvCode = data.cvvCode;
      isCvvFocused = data.isCvvFocused;
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryGradient = const LinearGradient(
      colors: [Colors.red, Colors.amber],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            children: [
              
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(gradient: primaryGradient),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        "Kart ile Ödeme",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

             
              Padding(
                padding: const EdgeInsets.all(16),
                child: CreditCardWidget(
                  cardNumber:
                      cardNumber.isEmpty ? '0000 0000 0000 0000' : cardNumber,
                  expiryDate: expiryDate.isEmpty ? '00/00' : expiryDate,
                  cardHolderName:
                      cardHolderName.isEmpty ? 'KART SAHİBİ' : cardHolderName,
                  cvvCode: cvvCode.isEmpty ? '000' : cvvCode,
                  showBackView: isCvvFocused,
                  isHolderNameVisible: true,
                  cardBgColor: Colors.amber,
                  textStyle:
                      const TextStyle(color: Colors.white, fontSize: 18),
                  labelCardHolder: 'KART SAHİBİ',
                  labelValidThru: 'VALID THRU',
                  onCreditCardWidgetChange: (_) {},
                  customCardTypeIcons: const [],
                ),
              ),

             
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CreditCardForm(
                  formKey: formKey,
                  cardNumber: cardNumber,
                  expiryDate: expiryDate,
                  cardHolderName: cardHolderName,
                  cvvCode: cvvCode,
                  onCreditCardModelChange: onCreditCardModelChange,
                  obscureCvv: true,
                  obscureNumber: false,
                  inputConfiguration: InputConfiguration(
                    cardNumberDecoration: _inputDecoration("Kart Numarası"),
                    expiryDateDecoration:
                        _inputDecoration("Son Kullanma Tarihi (AA/YY)"),
                    cvvCodeDecoration: _inputDecoration("CVV"),
                    cardHolderDecoration: _inputDecoration("Kart Sahibi"),
                  ),
                ),
              ),

              const SizedBox(height: 20),

        
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  height: 55,
                  width: double.infinity,
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: primaryGradient,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: isProcessing ? null : _processPayment,
                      child: Center(
                        child: isProcessing
                            ? const SizedBox(
                                width: 26,
                                height: 26,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                "₺${widget.invoice.amount.toStringAsFixed(2)} Öde",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey[50],
      labelStyle: const TextStyle(fontSize: 14, color: Colors.black87),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }
}
