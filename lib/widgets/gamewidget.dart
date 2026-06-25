import 'package:flutter/material.dart';
import '/discountpages/game.dart';
import '/models/animation.dart';

class MatchGameWidget extends StatelessWidget {
  const MatchGameWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        PageAnimations.slideFromRight(const MemoryShuffleGamePage()),
      ),
      child: Container(
        height: 120, 
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Colors.amber,
              Color.fromARGB(255, 255, 85, 0),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.catching_pokemon, color: Colors.white, size: 36),
            SizedBox(height: 8),
            Text(
              "Eşleştir",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
