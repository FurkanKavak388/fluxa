import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '/models/discount.dart';

class MemoryShuffleGamePage extends StatefulWidget {
  const MemoryShuffleGamePage({Key? key}) : super(key: key);

  @override
  State<MemoryShuffleGamePage> createState() => _MemoryShuffleGamePageState();
}

class _MemoryShuffleGamePageState extends State<MemoryShuffleGamePage> {
  final List<_CardItem> _cards = [];
  final List<Offset> _positions = [];
  int? firstSelectedIndex;
  bool gameStarted = false;
  bool gameEnded = false;
  bool isShuffling = false;

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    _generateCards();
    _generatePositions();
    _startGameSequence();
  }

  void _generateCards() {
    List<String> icons = ["🍎", "🍌", "🍇", "🍉", "🍒", "🍍"];
    _cards.clear();
    for (var icon in icons) {
      _cards.add(_CardItem(icon));
      _cards.add(_CardItem(icon));
    }
    _cards.shuffle(Random());
  }

  void _generatePositions() {
    _positions.clear();
    int crossAxisCount = 4;
    double cardSize = 70;
    double spacing = 8;

    for (int i = 0; i < _cards.length; i++) {
      int row = i ~/ crossAxisCount;
      int col = i % crossAxisCount;
      _positions.add(Offset(
        col * (cardSize + spacing),
        row * (cardSize + spacing),
      ));
    }
  }

  void _startGameSequence() {
    setState(() {
      gameStarted = false;
      gameEnded = false;
      firstSelectedIndex = null;
      for (var card in _cards) {
        card.isFaceUp = true;
      }
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() {
        for (var card in _cards) {
          card.isFaceUp = false;
        }
      });

      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        _shuffleWithAnimation();
      });
    });
  }

  void _shuffleWithAnimation() {
    setState(() {
      isShuffling = true;
    });

    List<int> indices = List.generate(_cards.length, (i) => i);
    indices.shuffle(Random());

    List<Offset> newPositions = List.generate(
      _positions.length,
      (i) => _positions[indices[i]],
    );

    setState(() {
      for (int i = 0; i < _cards.length; i++) {
        _positions[i] = newPositions[i];
      }
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() {
        isShuffling = false;
        gameStarted = true;
      });
    });
  }

  Future<void> _giveDiscountToUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final expiryDate = DateTime.now().add(const Duration(days: 7));

      // ✅ Model kullanıyoruz
      final discount = GrantedDiscount(
        id: '',
        discountPercent: 15,
        used: false,
        expiryDate: expiryDate,
      );

      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .collection("discounts")
          .add(discount.toMap());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("%15 indirim kazandınız!")),
        );
      }
    }
  }

  void _onCardTap(int index) {
    if (!gameStarted || gameEnded || isShuffling) return;
    if (_cards[index].isFaceUp) return;

    setState(() {
      _cards[index].isFaceUp = true;
    });

    if (firstSelectedIndex == null) {
      firstSelectedIndex = index;
    } else {
      gameStarted = false;
      bool match = _cards[index].emoji == _cards[firstSelectedIndex!].emoji;

      Future.delayed(const Duration(seconds: 1), () async {
        if (!mounted) return;
        setState(() {
          if (!match) {
            _cards[index].isFaceUp = false;
            _cards[firstSelectedIndex!].isFaceUp = false;
          }
          gameEnded = true;
        });

        if (match) {
          await _giveDiscountToUser();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double cardSize = 70;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Eşleştir!"),
         foregroundColor: Colors.white,
      ),
      body: Center(
        child: SizedBox(
          width: 4 * (cardSize + 8),
          height: 3 * (cardSize + 8),
          child: Stack(
            children: [
              for (int i = 0; i < _cards.length; i++)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 800),
                  left: _positions[i].dx,
                  top: _positions[i].dy,
                  child: GestureDetector(
                    onTap: () => _onCardTap(i),
                    child: Container(
                      width: cardSize,
                      height: cardSize,
                      decoration: BoxDecoration(
                        color: _cards[i].isFaceUp
                            ? Colors.white
                            : Colors.blueGrey[200],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.black54),
                      ),
                      child: Center(
                        child: Text(
                          _cards[i].isFaceUp ? _cards[i].emoji : "❓",
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
   bottomNavigationBar: gameEnded
    ? Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _startNewGame,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            foregroundColor: Colors.black,   
            padding: const EdgeInsets.symmetric(vertical: 16), 
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          child: const Text("Tekrar Oyna"),
        ),
      )
    : null,

    );
  }
}

class _CardItem {
  final String emoji;
  bool isFaceUp;
  
  _CardItem(this.emoji, {this.isFaceUp = false});
}
