import 'package:flutter/material.dart';
import 'package:fluxa/discountpages/grantedcodes.dart';
import '/discountpages/game.dart';
import '/discountpages/usechancepage.dart';
import '/discountpages/granteddiscount.dart';
import '/models/animation.dart';

class ChancePage extends StatelessWidget {
  const ChancePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final bool isDarkMode = brightness == Brightness.dark;

    final Color iconColor = isDarkMode ? Colors.grey[500]! : Colors.grey.shade400;
    final Color textColor = isDarkMode ? Colors.grey[600]! : Colors.grey.shade600;

    
    Widget buildButton({
      required String title,
      required IconData icon,
      required Color backgroundColor,
      required Color foregroundColor,
      required Widget page,
    }) {
      return GestureDetector(
        onTap: () => Navigator.of(context).push(PageAnimations.slideFromRight(page)),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: foregroundColor),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: foregroundColor,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: foregroundColor.withOpacity(0.6),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                buildButton(
                  title: 'Şansını Dene',
                  icon: Icons.casino,
                  backgroundColor: const Color.fromARGB(255, 212, 255, 0),
                  foregroundColor: Colors.black,
                  page: const UseChancePage(),
                ),
                buildButton(
                  title: 'Eşleştir',
                  icon: Icons.catching_pokemon,
                  backgroundColor: const Color.fromARGB(255, 27, 255, 57),
                  foregroundColor: Colors.black,
                  page: const MemoryShuffleGamePage(),
                ),
                buildButton(
                  title: 'İndirim Kuponları',
                  icon: Icons.discount,
                  backgroundColor: const Color.fromARGB(255, 0, 247, 255),
                  foregroundColor: Colors.black,
                  page: const GrantedDiscountsPage(),
                ),
                buildButton(
                  title: 'Satın Alınan Kodlar',
                  icon: Icons.discount,
                  backgroundColor: const Color.fromARGB(255, 255, 90, 109),
                  foregroundColor: Colors.black,
                  page: const GrantedCodesPage(),
                ),
                const SizedBox(height: 20),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.card_giftcard, size: 100, color: iconColor),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'Buradan şansını deneyebilir ya da kazandığın indirimleri kullanabilirsin.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: textColor),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
