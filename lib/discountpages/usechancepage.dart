import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '/models/discount.dart';

class UseChancePage extends StatefulWidget {
  const UseChancePage({Key? key}) : super(key: key);

  @override
  State<UseChancePage> createState() => _UseChancePageState();
}

class _UseChancePageState extends State<UseChancePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  final Random _random = Random();

  int _finalDiscount = 0;
  Color _finalCardColor = Colors.red;

  bool _showResult = false;

  final List<Color> _cardColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
  ];

  final int _numCards = 5;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 3000));
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);

    _controller.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        final discountPercent = _generateDiscount();
        final cardColor = _cardColors[_random.nextInt(_cardColors.length)];

        setState(() {
          _showResult = true;
          _finalDiscount = discountPercent;
          _finalCardColor = cardColor;
        });

        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final expiryDate = DateTime.now().add(const Duration(days: 7));

          final discount = GrantedDiscount(
            id: '', 
            discountPercent: discountPercent,
            used: false,
            expiryDate: expiryDate,
          );

          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('discounts')
              .add(discount.toMap());

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('%${discount.discountPercent} indirim kazandınız!'),
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int _generateDiscount() => 5 + _random.nextInt(46); 

  void _startAnimation() {
    setState(() {
      _showResult = false;
    });
    _controller.reset();
    _controller.forward();
  }

  Widget _buildCard(Color color, String text, double offsetX, double rotation, double scale) {
    return Transform.translate(
      offset: Offset(offsetX, 0),
      child: Transform.rotate(
        angle: rotation,
        child: Transform.scale(
          scale: scale.clamp(0.0, 1.0),
          child: Container(
            width: 200,
            height: 300,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('')),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 250,
                height: 320,
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    if (_showResult) {
                      return _buildCard(
                        _finalCardColor,
                        '%$_finalDiscount İNDİRİM',
                        0,
                        0,
                        1,
                      );
                    }

                    double progress = _animation.value;
                    List<Widget> cards = [];

                    for (int i = 0; i < _numCards; i++) {
                      double offsetX = 40 * (i - progress * (_numCards - 1));
                      double rotation = 0.05 * (i - progress * (_numCards - 1));
                      double scale = 1 - 0.1 * (i - progress * (_numCards - 1));

                      Color cardColor = _cardColors[(i + (progress * _numCards).floor()) % _cardColors.length];

                      cards.add(Positioned(
                        left: 25,
                        top: 0,
                        child: _buildCard(
                          cardColor,
                          'Şans Kartı',
                          offsetX,
                          rotation,
                          scale,
                        ),
                      ));
                    }

                    return Stack(children: cards);
                  },
                ),
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: _controller.isAnimating ? null : _startAnimation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  _controller.isAnimating ? 'Döndürülüyor...' : 'ŞANSINI DENE',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color.fromARGB(221, 255, 255, 255)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
